//
//  Created by Adam Stragner
//

import Essentials

// MARK: - ISO7816.APDU.Error

public extension ISO7816.APDU {
    enum Error: Swift.Error {
        case invalidHeader
        case invalidBody
        case bodyTooLarge
        case notEnoughResponseData
        case expectedResponseLengthOutOfBounds
        case apduResponse(Byte, Byte, String?)
    }
}

// MARK: - ISO7816.APDU.Error + LocalizedError

extension ISO7816.APDU.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidHeader: "CLA or INS or P1 or P2 are invalid"
        case .invalidBody: "LC or Body are invalid"
        case .bodyTooLarge: "Body larger than 65535"
        case .notEnoughResponseData: "Not enough data to parse APDU response"
        case .expectedResponseLengthOutOfBounds: "Expected length of response is out of bounds (0, 65536)"
        case let .apduResponse(
            sw1,
            sw2,
            description
        ): "APDU: [\(sw1.hexadecimalString)\(sw2.hexadecimalString)]: \(description ?? "")"
        }
    }
}
