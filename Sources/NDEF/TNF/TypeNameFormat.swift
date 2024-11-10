//
//  Created by Adam Stragner
//

// MARK: - NDEF.TypeNameFormat

public extension NDEF {
    enum TypeNameFormat: UInt8 {
        case empty = 0x00

        /// NFC Forum well-known type [NFC RTD]
        case wellknown = 0x01

        /// Media-type as defined in RFC 2046
        case mediaType = 0x02

        /// Absolute URI as defined in RFC 3986
        case absoluteURI = 0x03

        /// NFC Forum external type [NFC RTD]
        case external = 0x04

        case unknown = 0x05
        case unchanged = 0x06
        case reserved = 0x07
    }
}

// MARK: - NDEF.TypeNameFormat + Hashable

extension NDEF.TypeNameFormat: Hashable {}

// MARK: - NDEF.TypeNameFormat + Sendable

extension NDEF.TypeNameFormat: Sendable {}

// MARK: - NDEF.TypeNameFormat + ExpressibleByIntegerLiteral

extension NDEF.TypeNameFormat: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        let errorMessage = TypeNameFormatError().errorDescription ?? ""
        precondition(value <= UInt8.max, errorMessage)
        guard let value = NDEF.TypeNameFormat(rawValue: UInt8(value))
        else {
            fatalError(errorMessage)
        }
        self = value
    }
}
