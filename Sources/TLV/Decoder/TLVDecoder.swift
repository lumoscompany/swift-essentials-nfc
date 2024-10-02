//
//  Created by Adam Stragner
//

import Essentials
import Logging

// MARK: - TLVDecoder

public struct TLVDecoder {
    // MARK: Lifecycle

    public init(_ options: DecodingOptions = .defaults) {
        self.options = options
    }

    // MARK: Public

    public var options: DecodingOptions

    public func decode(from byteCollection: ByteCollection) throws -> [any TLVDecodble] {
        let byteCollection = ReadableByteCollection(byteCollection)
        let availableDataTypes = options.availableDataTypes

        var result: [any TLVDecodble] = []
        while !byteCollection.isEmpty {
            guard let fisrtByte = try? byteCollection.get(),
                  let decodableType = availableDataTypes[fisrtByte]
            else {
                let _ = try byteCollection.read()
                continue
            }

            do {
                let value = try _decode(decodableType, from: byteCollection)
                result.append(value)

                if value is TLV.TERMINATOR, options.shouldRespectTeriminateTLV {
                    throw BoundariesError(0, in: [])
                }
            } catch is BoundariesError {
                log.warning("Unexpectedly stopped parsing data because of BoundariesError")
                break
            } catch {
                throw error
            }
        }

        return result
    }

    public func decode<T>(
        _ type: T.Type,
        from byteCollection: ByteCollection
    ) throws -> T where T: TLVDecodble {
        let byteCollection = ReadableByteCollection(byteCollection)
        let value = try _decode(.init(type), from: byteCollection)

        guard let value = value as? T
        else {
            fatalError("Couldn't match \(value) to expected type \(String(describing: T.self))")
        }

        return value
    }

    // MARK: Private

    private let log = Logger(label: "tlv-decoder")

    private func _decode(
        _ type: DecodableType,
        from byteCollection: ReadableByteCollection
    ) throws -> any TLVDecodble {
        let firstByte = try byteCollection.read()
        guard type.dataType == firstByte
        else {
            throw TLVDecodingError.wrongType
        }

        let length = try type.constrainedLength.decode(from: byteCollection)
        if let constrainedLength = type.constrainedLength?.constraint {
            try TLVDecodingError
                .constrainedLengthInvalid
                .throwif(constrainedLength != length)
        }

        let container = try Container(options: options, storage: .init(byteCollection.read(length)))
        return try type.decode(with: container)
    }
}

#if IS_APPLE

import Foundation.NSData

public extension TLVDecoder {
    func decode(from contiguousBytes: any ContiguousBytes) throws -> [any TLVDecodble] {
        try decode(from: contiguousBytes.concreteBytes)
    }

    func decode<T>(
        _ type: T.Type,
        from contiguousBytes: any ContiguousBytes
    ) throws -> T where T: TLVDecodble {
        try decode(type, from: contiguousBytes.concreteBytes)
    }
}

#endif

// MARK: Sendable

extension TLVDecoder: Sendable {}
