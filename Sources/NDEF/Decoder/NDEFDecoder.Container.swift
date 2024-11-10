//
//  Created by Adam Stragner
//

import ReadableByteCollection

// MARK: - NDEFDecoder.Container

public extension NDEFDecoder {
    struct Container {
        // MARK: Lifecycle

        public init(
            options: DecodingOptions,
            typeNameFormat: NDEF.TypeNameFormat,
            type: ReadableByteCollection,
            id: ReadableByteCollection,
            payload: ReadableByteCollection
        ) {
            self.options = options
            self.typeNameFormat = typeNameFormat
            self.type = type
            self.id = id
            self.payload = payload
        }

        // MARK: Public

        public let options: DecodingOptions

        public let typeNameFormat: NDEF.TypeNameFormat

        public let type: ReadableByteCollection
        public let id: ReadableByteCollection
        public let payload: ReadableByteCollection
    }
}

// MARK: - NDEFDecoder.Container + Hashable

extension NDEFDecoder.Container: Hashable {}
