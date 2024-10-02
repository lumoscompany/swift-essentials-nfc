//
//  Created by Adam Stragner
//

import ReadableByteCollection

// MARK: - NDEFDecoder.DecodableType

public extension NDEFEncoder {
    struct Container {
        // MARK: Lifecycle

        public init(
            options: EncodingOptions,
            type: ReadableByteCollection,
            id: ReadableByteCollection,
            payload: ReadableByteCollection
        ) {
            self.options = options
            self.type = type
            self.id = id
            self.payload = payload
        }

        // MARK: Public

        public let options: EncodingOptions

        public var type: ReadableByteCollection
        public var id: ReadableByteCollection
        public var payload: ReadableByteCollection
    }
}
