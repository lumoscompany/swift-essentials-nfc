//
//  Created by Adam Stragner
//

import Essentials

// MARK: - TLVConstrainedLength

public struct TLVConstrainedLength {
    // MARK: Lifecycle

    public init(_ constraint: UInt16, _ type: ConstraintType) {
        self.constraint = constraint
        self.type = type
    }

    // MARK: Public

    public enum ConstraintType: Hashable, Sendable {
        case ephemeral
        case ordinary
    }

    public let constraint: UInt16
    public let type: ConstraintType
}

// MARK: Hashable

extension TLVConstrainedLength: Hashable {}

// MARK: Sendable

extension TLVConstrainedLength: Sendable {}

extension Optional where Wrapped == TLVConstrainedLength {
    func decode(from byteCollection: inout ReadableByteCollection) throws -> Int {
        switch self {
        case .none:
            return try Int(UInt16(tlvEncodedLengthBytes: &byteCollection))
        case let .some(wrapped):
            let length = wrapped.constraint
            return switch wrapped.type {
            case .ephemeral: Int(length)
            case .ordinary: try Int(UInt16(tlvEncodedLengthBytes: &byteCollection))
            }
        }
    }

    func encode(
        to byteCollection: inout ReadableByteCollection,
        withActualLength actualLength: Int
    ) throws {
        try TLVEncodingError.invalidLength.throwif(actualLength > 0xFFFF)

        let actualLength = UInt16(actualLength)
        switch self {
        case .none:
            byteCollection.append(contentsOf: actualLength.tlvEncodedLengthBytes)
        case let .some(wrapped):
            let length = wrapped.constraint
            switch wrapped.type {
            case .ephemeral:
                try TLVEncodingError.constrainedLengthInvalid.throwif(length != actualLength)
            case .ordinary:
                try TLVEncodingError.constrainedLengthInvalid.throwif(length != actualLength)
                byteCollection.append(contentsOf: actualLength.tlvEncodedLengthBytes)
            }
        }
    }
}

private extension UInt16 {
    init(
        tlvEncodedLengthBytes byteCollection: inout ReadableByteCollection
    ) throws (BoundariesError) {
        let byte = try byteCollection.read()
        self = switch byte {
        case 0x00 ..< 0xFF: UInt16(byteCollection: [byte], .big)
        case 0xFF: try UInt16(byteCollection: byteCollection.read(2), .big)
        default: fatalError("UInt16.tlvEncodedLengthBytes.init")
        }
    }

    var tlvEncodedLengthBytes: [UInt8] {
        switch self {
        case 0 ..< 0xFF: [UInt8(self)]
        case 0xFF ..< 0xFFFF: [0xFF] + byteCollection(with: .big)
        default: fatalError("UInt16.tlvEncodedLengthBytes")
        }
    }
}
