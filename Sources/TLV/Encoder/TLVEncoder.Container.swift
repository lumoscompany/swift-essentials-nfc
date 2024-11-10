//
//  Created by Adam Stragner
//

import Essentials

public extension TLVEncoder {
    struct Container {
        // MARK: Lifecycle

        init(options: EncodingOptions, storage: ReadableByteCollection) {
            self.options = options
            self.storage = storage
        }

        // MARK: Public

        public let options: EncodingOptions
        public var storage: ReadableByteCollection
    }
}
