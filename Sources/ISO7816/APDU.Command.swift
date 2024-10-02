//
//  Created by Adam Stragner
//

import Essentials

// MARK: - ISO7816.APDU.Command

// +------+---------+------------------------------------------------------------------------------+
// | name | bytes   |                             description                                      |
// +------+---------+------------------------------------------------------------------------------+
// | CLA  |    1    | Instruction class - indicates the type of command, e.g.,                     |
// |      |         | interindustry or proprietary                                                 |
// +------+---------+------------------------------------------------------------------------------+
// | INS  |    1    | Instruction code - indicates the specific command, e.g.,                     |
// |      |         | "select", "write data"                                                       |
// +------+---------+------------------------------------------------------------------------------+
// |  P1  |    1    | Instruction parameters for the command, e.g.,                                |
// |      |         | offset into file at which to write the data                                  |
// +------+---------+------------------------------------------------------------------------------+
// |  P2  |    1    | Instruction parameters for the command, e.g.,                                |
// |      |         | offset into file at which to write the data                                  |
// +------+---------+------------------------------------------------------------------------------+
// |  LC  |  0|1|3  | Encodes the number (Nc) of bytes of command data to follow                   |
// |      |         | - 0 bytes denotes Nc=0                                                       |
// |      |         | - 1 byte with a value from 1 to 255 denotes Nc with the same length          |
// |      |         | - 3 bytes, the first of which must be 0,                                     |
// |      |         |     denotes Nc in the range 1 to 65 535 (all three bytes may not be zero)    |
// +------+---------+------------------------------------------------------------------------------+
// | BODY |    N    | Bytes of data                                                                |
// +------+---------+------------------------------------------------------------------------------+
// |  LE  | 0|1|2|3 | Encodes the maximum number (Ne) of response bytes expected                   |
// |      |         | - 0 bytes denotes Ne=0                                                       |
// |      |         | - 1 byte in the range 1 to 255 denotes that value of Ne, or 0 denotes Ne=256 |
// |      |         | - 2 bytes (if extended Lc was present in the command)                        |
// |      |         |     in the range 1 to 65 535 denotes Ne of that value,                       |
// |      |         |     or two zero bytes denotes 65 536                                         |
// |      |         | - 3 bytes (if Lc was not present in the command),                            |
// |      |         |     the first of which must be 0, denote Ne in the same way as two-byte Le   |
// +------+---------+------------------------------------------------------------------------------+

public extension ISO7816.APDU {
    struct Command: RawRepresentable {
        // MARK: Lifecycle

        public init?(rawValue: ByteCollection) {
            try? self.init(rawValue)
        }

        public init(_ byteCollection: ByteCollection) throws (ISO7816.APDU.Error) {
            let command = try Coder().decode(byteCollection)
            self.init(
                instructionClass: command.instructionClass,
                instructionCode: command.instructionCode,
                p1Parameter: command.p1Parameter,
                p2Parameter: command.p2Parameter,
                data: command.data,
                expectedResponseLength: command.expectedResponseLength,
                rawValue: byteCollection
            )
        }

        public init(
            instructionClass: Byte,
            instructionCode: Byte,
            p1Parameter: Byte,
            p2Parameter: Byte,
            data: ByteCollection?,
            expectedResponseLength: Int?
        ) throws (ISO7816.APDU.Error) {
            let byteCollection = try Coder().encode((
                instructionClass,
                instructionCode,
                p1Parameter,
                p2Parameter,
                data,
                expectedResponseLength
            ))
            try self.init(byteCollection)
        }

        init(
            instructionClass: Byte,
            instructionCode: Byte,
            p1Parameter: Byte,
            p2Parameter: Byte,
            data: ByteCollection?,
            expectedResponseLength: Int?,
            rawValue: ByteCollection
        ) {
            self.instructionClass = instructionClass
            self.instructionCode = instructionCode
            self.p1Parameter = p1Parameter
            self.p2Parameter = p2Parameter
            self.data = data
            self.expectedResponseLength = expectedResponseLength
            self.rawValue = rawValue
        }

        // MARK: Public

        /// Class (CLA) byte.
        public let instructionClass: Byte

        /// Instruction (INS) byte.
        public let instructionCode: Byte

        /// P1 parameter.
        public let p1Parameter: Byte

        /// P2 parameter.
        public let p2Parameter: Byte

        /// Data field; nil if data field is absent
        public let data: ByteCollection?

        /// Le (Expected response length);  `nil` means no response data field is expected.
        public let expectedResponseLength: Int?

        public let rawValue: ByteCollection
    }
}

// MARK: - ISO7816.APDU.Command + Hashable

extension ISO7816.APDU.Command: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - ISO7816.APDU.Command + LosslessStringConvertible

extension ISO7816.APDU.Command: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let rawValue = ByteCollection(hexadecimalString: description)
        else {
            return nil
        }
        self.init(rawValue: rawValue)
    }

    public var description: String {
        rawValue.hexadecimalString
    }
}

// MARK: - ISO7816.APDU.Command + ExpressibleByStringLiteral

extension ISO7816.APDU.Command: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let rawValue = ByteCollection(hexadecimalString: value),
              let value = ISO7816.APDU.Command(rawValue: rawValue)
        else {
            fatalError("Couldn't parse hexadecimal string literal")
        }
        self = value
    }
}

extension ISO7816.APDU.Command {
    init?(_ contiguousBytes: any ContiguousBytes) {
        self.init(rawValue: contiguousBytes.concreteBytes)
    }
}
