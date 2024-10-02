//
//  Created by Adam Stragner
//

import Essentials

// MARK: - Header.Flags

extension Header {
    struct Flags: OptionByte, BitmaskByte {
        // MARK: Lifecycle

        init(rawValue: UInt8) throws {
            let typeNameFormat = NDEF.TypeNameFormat(
                rawValue: rawValue & BitmaskKeys.typeNameFormat.rawValue
            )

            guard let typeNameFormat
            else {
                throw TypeNameFormatError()
            }

            self.rawValue = rawValue
            self.typeNameFormat = typeNameFormat
        }

        // MARK: Internal

        var rawValue: UInt8

        var typeNameFormat: NDEF.TypeNameFormat {
            didSet { self[mask: .typeNameFormat] = typeNameFormat.rawValue }
        }
    }
}

// MARK: - Header.Flags.BitFlagKeys

extension Header.Flags {
    enum OptionKeys: UInt8, OptionKey {
        /// The `MB` flag is a 1-bit field that when set indicates the start of an NDEF message
        case isMessageBegin = 7 // 0b10000000

        /// The `ME` flag is a 1-bit field that when set indicates the end of an NDEF message.
        /// Note, that in case of a chunked payload, the ME flag is set only in the terminating record chunk of that chunked payload
        case isMessageEnd = 6 // 0b01000000

        /// The `CF` flag is a 1-bit field indicating that this is either the first record chunk or a middle record chunk of a chunked payload
        case isChunkFlag = 5 // 0b00100000

        /// The `SR` flag is a 1-bit field indicating, if set, that the `PAYLOAD_LENGTH` field is a single octet.
        /// This short record layout is intended for compact encapsulation of small payloads which will fit within `PAYLOAD` fields of size ranging between 0 to 255 octets.
        case isShortRecord = 4 // 0b00010000

        /// The `IL` flag is a 1-bit field indicating, if set, that the `ID_LENGTH` field is present in the header as a single octet.
        /// If the `IL` flag is zero, the `ID_LENGTH` field is omitted from the record header and the `ID` field is also omitted from the record
        case isIDLengthPresented = 3 // 0b00001000
    }
}

// MARK: - Header.Flags.BitMaskKeys

extension Header.Flags {
    enum BitmaskKeys: UInt8, BitmaskKey {
        case typeNameFormat = 0b0000_0111
    }
}

// MARK: - Header.Flags + Hashable

extension Header.Flags: Hashable {}
