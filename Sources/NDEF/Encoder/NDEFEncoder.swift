//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEFEncoder

public struct NDEFEncoder {
    // MARK: Lifecycle

    public init(_ options: EncodingOptions = .defaults) {
        self.options = options
    }

    // MARK: Public

    public let options: EncodingOptions

    public func encode(_ value: [any NDEFEncodable]) throws -> [UInt8] {
        let storage = ReadableBytesCollection()

        let range = 0 ..< value.count
        var index = 0

        try value.forEach({
            try _encode($0, to: storage, withIndex: index, in: range)
            index += 1
        })

        try NDEFEncodingError.messageTooLong.throwif(storage.value.count > UInt16.max)
        return storage.value
    }

    public func encode<T>(_ value: T) throws -> [UInt8] where T: NDEFEncodable {
        let storage = ReadableBytesCollection()
        try _encode(value, to: storage, withIndex: 0, in: 0 ..< 1)

        try NDEFEncodingError.messageTooLong.throwif(storage.value.count > UInt16.max)
        return storage.value
    }

    // MARK: Private

    private func _encode<T>(
        _ value: T,
        to storage: ReadableBytesCollection,
        withIndex index: Int,
        in range: Range<Int>
    ) throws where T: NDEFEncodable {
        let container = Container(
            options: options,
            type: .init(T.dataType ?? []),
            id: [],
            payload: []
        )

        try value.encode(to: container)

        let dataType = container.type.value
        let payload = container.payload.value

        if let _dataType = T.dataType {
            try NDEFEncodingError
                .dataTypeCorrupted
                .throwif(_dataType != dataType)
        }

        var typeNameFormat = T.typeNameFormatConstraint
        if let _unimplemented = value as? NDEF._Unimplemented {
            typeNameFormat = _unimplemented.typeNameFormat
        }

        let header = try _header(
            id: container.id.value,
            typeNameFormat: typeNameFormat,
            dataType: dataType,
            payload: payload,
            withIndex: index,
            in: range
        )

        storage.append(contentsOf: header)
        storage.append(contentsOf: payload)
    }

    private func _header(
        id: [UInt8],
        typeNameFormat: NDEF.TypeNameFormat,
        dataType: [UInt8],
        payload: [UInt8],
        withIndex index: Int,
        in range: Range<Int>
    ) throws -> [UInt8] {
        var result: [UInt8] = []

        try NDEFEncodingError.idTooLong.throwif(id.count > 0xFF)
        try NDEFEncodingError.typeTooLong.throwif(dataType.count > 0xFF)

        try NDEFEncodingError.invalidTNF.throwif(typeNameFormat == .reserved)
        try NDEFEncodingError.invalidTNF.throwif(
            typeNameFormat == .empty && (!dataType.isEmpty || !id.isEmpty || !payload.isEmpty)
        )

        var flags = try Header.Flags(rawValue: 0)
        flags.typeNameFormat = typeNameFormat

        flags[option: .isMessageBegin] = index == range.lowerBound
        flags[option: .isMessageEnd] = index == range.upperBound - 1
        flags[option: .isShortRecord] = payload.count < 0xFF
        flags[option: .isChunkFlag] = false
        flags[option: .isIDLengthPresented] = !id.isEmpty

        result.append(flags.rawValue)
        result.append(UInt8(dataType.count))

        let payloadLength = switch payload.count {
        case 0 ..< 0xFF: [UInt8(payload.count)]
        case 0x0000_01FF ... 0xFFFF_FFFF: UInt32(payload.count).bytes(with: .big)
        default: throw NDEFEncodingError.invalidPayload(payload.count)
        }

        result.append(contentsOf: payloadLength)
        if flags[option: .isIDLengthPresented] {
            result.append(UInt8(id.count))
        }

        result.append(contentsOf: dataType)
        result.append(contentsOf: id)

        return result
    }
}

// MARK: Sendable

extension NDEFEncoder: Sendable {}
