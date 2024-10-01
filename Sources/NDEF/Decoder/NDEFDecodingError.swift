//
//  Created by Adam Stragner
//

// MARK: - NDEFDecodingError

public enum NDEFDecodingError: Error {
    case wrongType
    case wrongTypeNameFormat
    case dataCorrupted(String)
}

#if IS_APPLE

import Foundation.NSError

extension NDEFDecodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongType: "Couldn't decode NDEF data because data type mismatch"
        case .wrongTypeNameFormat: "Couldn't decode NDEF data because data TNF mismatch"
        case let .dataCorrupted(message): message
        }
    }
}

#endif
