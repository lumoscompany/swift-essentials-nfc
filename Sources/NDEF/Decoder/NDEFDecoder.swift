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
        from contiguousBytes: any ContiguousBytes
    ) throws -> [any NDEFDecodble] {
        var byteCollection = ReadableByteCollection(contiguousBytes)
        let availableDataTypes = options.availableDataTypes

        var result: [any NDEFDecodble] = []
        while !byteCollection.isEmpty {
            do {
                let header = try _header(from: &byteCollection)
                let decodableType = availableDataTypes.decodableType(
                    for: header.flags.typeNameFormat,
                    forType: header.type
                )

                try result.append(_decode(decodableType, with: header, from: &byteCollection))
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
        from contiguousBytes: any ContiguousBytes
    ) throws -> T where T: NDEFDecodble {
        var byteCollection = ReadableByteCollection(contiguousBytes)

        let header = try _header(from: &byteCollection)
        let value = try _decode(.init(type), with: header, from: &byteCollection)

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
        from byteCollection: inout ReadableByteCollection
    ) throws -> any NDEFDecodble {
        if !type.isUnimplemented {
            try NDEFDecodingError
                .wrongTypeNameFormat
                .throwif(type.constrainedTypeNameFormat != header.flags.typeNameFormat)
        }

        if let dataType = type.dataType {
            try NDEFDecodingError.wrongType.throwif(dataType != header.type)
        }

        return try type.decode(with: .init(
            options: options,
            typeNameFormat: header.flags.typeNameFormat,
            type: .init(header.type),
            id: .init(header.id),
            payload: .init(byteCollection.read(header.payloadLength))
        ))
    }

    private func _header(from byteCollection: inout ReadableByteCollection) throws -> Header {
        let flags = try Header.Flags(rawValue: byteCollection.read())

        let typeLength = try Int(byteCollection.read())
        let payloadLength: Int
        let idLength: Int

        if flags[option: .isShortRecord] {
            payloadLength = try Int(byteCollection.read())
        } else {
            payloadLength = try Int(UInt32(byteCollection: byteCollection.read(4), .big))
        }

        if flags[option: .isIDLengthPresented] {
            idLength = try Int(byteCollection.read())
        } else {
            idLength = 0
        }

        try NDEFEncodingError.chunksUnsupported.throwif(flags[option: .isChunkFlag])

        return try .init(
            flags: flags,
            type: byteCollection.read(typeLength),
            id: byteCollection.read(idLength),
            payloadLength: payloadLength
        )
    }
}

// MARK: Sendable

extension NDEFDecoder: Sendable {}
