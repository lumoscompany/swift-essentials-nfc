//
//  Created by Adam Stragner
//

import Essentials

// MARK: - ISO7816.APDU.Response

// -------------------------------------------------------------------------------------------------
// | DATA |    N    | Response data                                                                |
// +------+---------+------------------------------------------------------------------------------+
// | SW1  |    1    | Command processing status                                                    |
// +------+---------+------------------------------------------------------------------------------+
// | SW2  |    1    | Command processing status                                                    |
// +------+---------+------------------------------------------------------------------------------+

public extension ISO7816.APDU {
    struct Response: RawRepresentable {
        // MARK: Lifecycle

        public init?(rawValue: ByteCollection) {
            try? self.init(rawValue)
        }

        public init(_ byteCollection: ByteCollection) throws (ISO7816.APDU.Error) {
            guard byteCollection.count >= 2
            else {
                throw ISO7816.APDU.Error.notEnoughResponseData
            }

            let data: ByteCollection = if byteCollection.count > 2 {
                ByteCollection(byteCollection[0 ..< (byteCollection.count - 2)])
            } else {
                []
            }

            let sws = Array(byteCollection[(byteCollection.count - 2) ..< (byteCollection.count)])
            self.init(
                data: data,
                statusWord1: sws[0],
                statusWord2: sws[1]
            )
        }

        public init(data: ByteCollection, statusWord1: Byte, statusWord2: Byte) {
            self.data = data
            self.statusWord1 = statusWord1
            self.statusWord2 = statusWord2
            self.rawValue = data + [statusWord1, statusWord2]
        }

        // MARK: Public

        /// Response data
        public let data: ByteCollection

        /// SW1 parameter
        public let statusWord1: Byte

        /// SW2 parameter
        public let statusWord2: Byte

        public let rawValue: ByteCollection
    }
}

// MARK: - ISO7816.APDU.Response + Hashable

extension ISO7816.APDU.Response: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - ISO7816.APDU.Response + LosslessStringConvertible

extension ISO7816.APDU.Response: LosslessStringConvertible {
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

// MARK: - ISO7816.APDU.Response + ExpressibleByStringLiteral

extension ISO7816.APDU.Response: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        guard let rawValue = ByteCollection(hexadecimalString: value),
              let value = ISO7816.APDU.Response(rawValue: rawValue)
        else {
            fatalError("Couldn't parse hexadecimal string literal")
        }
        self = value
    }
}

extension ISO7816.APDU.Response {
    init?(_ contiguousBytes: any ContiguousBytes) {
        self.init(rawValue: contiguousBytes.concreteBytes)
    }
}

public extension ISO7816.APDU.Response {
    func checkError() throws (ISO7816.APDU.Error) {
        guard !isWellKnownSuccess
        else {
            return
        }

        let wellKnownDescription = wellKnownDescription
        if let wellKnownDescription, wellKnownDescription.level != .error {
            return
        }

        throw .apduResponse(statusWord1, statusWord2, wellKnownDescription?.text)
    }
}

public extension ISO7816.APDU.Response {
    var isWellKnownSuccess: Bool {
        switch (statusWord1, statusWord2) {
        case (0x90, 0x00), (0x91, 0x00): true
        default: false
        }
    }
}
