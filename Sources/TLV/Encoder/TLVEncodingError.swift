//
//  Created by Adam Stragner
//

// MARK: - TLVEncodingError

public enum TLVEncodingError {
    case invalidLength
    case constrainedLengthInvalid
    case dataCorrupted(String)
}

#if IS_APPLE

import Foundation.NSError

extension TLVEncodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLength: "TLV length couldn't more that 0xFFFF (UInt16.max)"
        case .constrainedLengthInvalid: "TLV constrained length doesn't match to actual bytes length"
        case let .dataCorrupted(message): message
        }
    }
}

#endif
