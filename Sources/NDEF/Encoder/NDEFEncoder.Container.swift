//
//  Created by Adam Stragner
//

import ReadableBytesCollection

// MARK: - NDEFDecoder.DecodableType

public extension NDEFEncoder {
    struct Container {
        // MARK: Lifecycle

        public init(
            options: EncodingOptions,
            type: ReadableBytesCollection,
            id: ReadableBytesCollection,
            payload: ReadableBytesCollection
        ) {
            self.options = options
            self.type = type
            self.id = id
            self.payload = payload
        }

        // MARK: Public

        public let options: EncodingOptions

        public let type: ReadableBytesCollection
        public let id: ReadableBytesCollection
        public let payload: ReadableBytesCollection
    }
}
