//
//  Created by Adam Stragner
//

// MARK: - TypeNameFormatError

public struct TypeNameFormatError: Error {}

#if IS_APPLE

import Foundation.NSError

extension TypeNameFormatError: LocalizedError {
    public var errorDescription: String? {
        "TypeNameFormat (TNF) value must be not greater than 3 bits"
    }
}

#endif
