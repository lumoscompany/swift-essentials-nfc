//
//  Created by Adam Stragner
//

import Essentials
import Logging

// MARK: - NDEFDecoder

public struct NDEFDecoder {
    // MARK: Lifecycle

    public init(_ options: DecodingOptions = .defaults) {
        self.options = options
    }

    // MARK: Public

    public let options: DecodingOptions

    public func decode(
        _ types: [DecodableType] = [],
        from bytes: [UInt8]
    ) throws -> [any NDEFDecodble] {
        let storage = ReadableByteCollection(bytes)
        let availableDataTypes = options.availableDataTypes

        var result: [any NDEFDecodble] = []
        while !storage.isEmpty {
            do {
                let header = try _header(from: storage)
                let decodableType = availableDataTypes.decodableType(
                    for: header.flags.typeNameFormat,
                    forType: header.type
                )

                try result.append(_decode(decodableType, with: header, from: storage))
                if header.flags[option: .isMessageEnd] {
                    break
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
        from bytes: [UInt8]
    ) throws -> T where T: NDEFDecodble {
        let storage = ReadableByteCollection(bytes)

        let header = try _header(from: storage)
        let value = try _decode(.init(type), with: header, from: storage)

        guard let value = value as? T
        else {
            fatalError("Couldn't match \(value) to expected type \(String(describing: T.self))")
        }

        return value
    }

    // MARK: Private

    private let log = Logger(label: "ndef-decoder")

    private func _decode(
        _ type: DecodableType,
        with header: Header,
        from storage: ReadableByteCollection
    ) throws -> any NDEFDecodble {
        if !type.isUnimplemented {
            try NDEFDecodingError
                .wrongTypeNameFormat
                .throwif(type.constrainedTypeNameFormat != header.flags.typeNameFormat)
        }

        if let dataType = type.dataType {
            try NDEFDecodingError.wrongType.throwif(dataType != header.type)
        }

        let bytes = try storage.read(header.payloadLength)
        return try type.decode(with: .init(
            options: options,
            typeNameFormat: header.flags.typeNameFormat,
            type: .init(header.type),
            id: .init(header.id),
            payload: .init(bytes)
        ))
    }

    private func _header(from storage: ReadableByteCollection) throws -> Header {
        let flags = try Header.Flags(rawValue: storage.read())

        let typeLength = try Int(storage.read())
        let payloadLength: Int
        let idLength: Int

        if flags[option: .isShortRecord] {
            payloadLength = try Int(storage.read())
        } else {
            payloadLength = try Int(UInt32(byteCollection: storage.read(4), .big))
        }

        if flags[option: .isIDLengthPresented] {
            idLength = try Int(storage.read())
        } else {
            idLength = 0
        }

        try NDEFEncodingError.chunksUnsupported.throwif(flags[option: .isChunkFlag])

        return try .init(
            flags: flags,
            type: storage.read(typeLength),
            id: storage.read(idLength),
            payloadLength: payloadLength
        )
    }
}

// MARK: Sendable

extension NDEFDecoder: Sendable {}

#if IS_APPLE

import Foundation.NSData

public extension NDEFDecoder {
    func decode(
        _ types: [DecodableType] = [],
        from bytes: any ContiguousBytes
    ) throws -> [any NDEFDecodble] {
        try decode(types, from: bytes.concreteBytes)
    }

    func decode<T>(
        _ type: T.Type,
        from bytes: any ContiguousBytes
    ) throws -> T where T: NDEFDecodble {
        try decode(type, from: bytes.concreteBytes)
    }
}

#endif
