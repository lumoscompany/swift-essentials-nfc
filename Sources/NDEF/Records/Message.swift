//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEF.Message

public extension NDEF {
    struct Message: NDEFCodable {
        // MARK: Lifecycle

        public init(
            identifier: ByteCollection = [],
            encoding: Encoding = .utf8,
            language: String,
            string: String
        ) {
            self.identifier = identifier
            self.encoding = encoding
            self.language = language
            self.string = string
        }

        public init(with container: NDEFDecoder.Container) throws {
            var byteCollection = container.payload

            let flags = try Flags(rawValue: byteCollection.read())
            let lang = try String(
                bytes: byteCollection.read(Int(flags.languageCodeLength)),
                encoding: .utf8
            )

            let string = String(bytes: byteCollection.rawValue, encoding: flags.encoding._encoding)
            guard let lang, let string
            else {
                throw NDEFDecodingError.dataCorrupted("Couldn't decode text message")
            }

            self.init(
                identifier: container.id.rawValue,
                encoding: flags.encoding,
                language: lang,
                string: string
            )
        }

        // MARK: Public

        public static let dataType: ByteCollection? = [0x54]
        public static let typeNameFormatConstraint: NDEF.TypeNameFormat = .wellknown

        public let identifier: ByteCollection
        public let encoding: Encoding
        public let language: String
        public let string: String

        public func encode(to container: inout NDEFEncoder.Container) throws {
            var flags = Flags(rawValue: 0)
            switch encoding {
            case .utf8: flags[option: .isUTF16] = false
            case .utf16: flags[option: .isUTF16] = true
            }

            let language = language.utf8
            guard language.count <= 0b0011_1111
            else {
                throw NDEFDecodingError.dataCorrupted("Message's language value too long")
            }

            flags.languageCodeLength = UInt8(language.count)

            container.id.append(contentsOf: identifier)

            container.payload.append(contentsOf: [flags.rawValue])
            container.payload.append(contentsOf: [UInt8](language))
            container.payload.append(contentsOf: [UInt8](string.utf8))
        }
    }
}

// MARK: - NDEF.Message + Codable

extension NDEF.Message: Codable {}

// MARK: - NDEF.Message.Encoding

public extension NDEF.Message {
    enum Encoding {
        case utf8
        case utf16
    }
}

// MARK: - NDEF.Message.Encoding + Hashable

extension NDEF.Message.Encoding: Hashable {}

// MARK: - NDEF.Message.Encoding + Codable

extension NDEF.Message.Encoding: Codable {}

// MARK: - NDEF.Message.Encoding + Sendable

extension NDEF.Message.Encoding: Sendable {}

private extension NDEF.Message.Encoding {
    var _encoding: String.Encoding {
        switch self {
        case .utf8: .utf8
        case .utf16: .utf16
        }
    }
}

// MARK: - NDEF.Message.Flags

private extension NDEF.Message {
    struct Flags: OptionByte, BitmaskByte {
        // MARK: Lifecycle

        init(rawValue: UInt8) {
            self.rawValue = rawValue
            self.languageCodeLength = rawValue & BitmaskKeys.languageCodeLength.rawValue
        }

        // MARK: Public

        public enum OptionKeys: UInt8, OptionKey {
            case isUTF16 = 7 // 0b10000000
            case reserved = 6 // 0b01000000
        }

        public enum BitmaskKeys: UInt8, BitmaskKey {
            case languageCodeLength = 0b0011_1111
        }

        public var rawValue: UInt8

        public var encoding: Encoding {
            if self[option: .isUTF16] {
                return .utf16
            } else {
                return .utf8
            }
        }

        /// Language code length
        public var languageCodeLength: UInt8 {
            didSet { self[mask: .languageCodeLength] = languageCodeLength }
        }
    }
}
