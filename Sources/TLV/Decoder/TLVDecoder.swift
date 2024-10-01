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

    public func decode(from bytes: [UInt8]) throws -> [any TLVDecodble] {
        let storage = ReadableBytesCollection(bytes)
        let availableDataTypes = options.availableDataTypes

        var result: [any TLVDecodble] = []
        while !storage.isEmpty {
            guard let fisrtByte = try? storage.get(),
                  let decodableType = availableDataTypes[fisrtByte]
            else {
                let _ = try storage.read()
                continue
            }

            do {
                let value = try _decode(decodableType, from: storage)
                result.append(value)

                if value is TLV.TERMINATOR, options.shouldRespectTeriminateTLV {
                    throw ReadableBytesCollection.BoundariesError()
                }
            } catch is ReadableBytesCollection.BoundariesError {
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
        from bytes: [UInt8]
    ) throws -> T where T: TLVDecodble {
        let storage = ReadableBytesCollection(bytes)
        let value = try _decode(.init(type), from: storage)

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
        from storage: ReadableBytesCollection
    ) throws -> any TLVDecodble {
        let firstByte = try storage.read()
        guard type.dataType == firstByte
        else {
            throw TLVDecodingError.wrongType
        }

        let length = try type.constrainedLength.decode(from: storage)
        if let constrainedLength = type.constrainedLength?.constraint {
            try TLVDecodingError
                .constrainedLengthInvalid
                .throwif(constrainedLength != length)
        }

        let container = try Container(options: options, storage: .init(storage.read(length)))
        return try type.decode(with: container)
    }
}

#if IS_APPLE

import Foundation.NSData

public extension TLVDecoder {
    func decode(from bytes: any ContiguousBytes) throws -> [any TLVDecodble] {
        try decode(from: bytes.concreteBytes)
    }

    func decode<T>(
        _ type: T.Type,
        from bytes: any ContiguousBytes
    ) throws -> T where T: TLVDecodble {
        try decode(type, from: bytes.concreteBytes)
    }
}

#endif

// MARK: Sendable

extension TLVDecoder: Sendable {}
