//
//  Created by Adam Stragner
//

import Essentials

public extension TLVDecoder {
    struct Container {
        // MARK: Lifecycle

        init(options: DecodingOptions, storage: ReadableBytesCollection) {
            self.options = options
            self.storage = storage
        }

        // MARK: Public

        public let options: DecodingOptions
        public let storage: ReadableBytesCollection
    }
}
