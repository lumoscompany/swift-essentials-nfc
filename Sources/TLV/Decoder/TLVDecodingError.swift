//
//  Created by Adam Stragner
//

// MARK: - TLVDecodingError

public enum TLVDecodingError {
    case invalidLength
    case wrongType
    case constrainedLengthInvalid
    case dataCorrupted(String)
}

#if IS_APPLE

import Foundation.NSError

extension TLVDecodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLength: "TLV length couldn't more that 0xFFFF (UInt16.max)"
        case .wrongType: "Couldn't decode TLV data because data type mismatch"
        case .constrainedLengthInvalid: "Actual bytes length doesn't match to constrained length"
        case let .dataCorrupted(message): message
        }
    }
}

#endif
