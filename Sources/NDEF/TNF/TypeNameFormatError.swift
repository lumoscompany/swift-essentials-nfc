//
//  Created by Adam Stragner
//

import Essentials

// MARK: - TypeNameFormatError

public struct TypeNameFormatError: Error {}

// MARK: LocalizedError

extension TypeNameFormatError: LocalizedError {
    public var errorDescription: String? {
        "TypeNameFormat (TNF) value must be not greater than 3 bits"
    }
}
