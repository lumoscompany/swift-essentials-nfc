//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEFEncodingError

public enum NDEFEncodingError: Error {
    case messageTooLong
    case invalidTNF
    case idTooLong
    case typeTooLong
    case chunksUnsupported
    case dataTypeCorrupted
    case invalidPayload(Int)
    case dataCorrupted(String)
}

// MARK: LocalizedError

extension NDEFEncodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .messageTooLong: "NDEF message couldn't be greater that UInt16.max"
        case .invalidTNF: "TNF value MUST NOT be `reserved`"
        case .idTooLong: "ID couldn't be greater than UInt8.max"
        case .typeTooLong: "Type couldn't be greater than UInt8.max"
        case .chunksUnsupported: "Chunked payload are not supported"
        case .dataTypeCorrupted: "Constrained `dataType` differs from the received"
        case let .invalidPayload(size): "Invalid payload size: \(size); chunked payload are not supported"
        case let .dataCorrupted(message): message
        }
    }
}
