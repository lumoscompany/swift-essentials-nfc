//
//  Created by Adam Stragner
//

import Essentials

// MARK: - TLVEncodingError

public enum TLVEncodingError: Error {
    case invalidLength
    case constrainedLengthInvalid
    case dataCorrupted(String)
}

// MARK: LocalizedError

extension TLVEncodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLength: "TLV length couldn't more that 0xFFFF (UInt16.max)"
        case .constrainedLengthInvalid: "TLV constrained length doesn't match to actual bytes length"
        case let .dataCorrupted(message): message
        }
    }
}
