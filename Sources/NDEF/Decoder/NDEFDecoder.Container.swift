//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEFDecoder.Container

public extension NDEFDecoder {
    struct Container {
        // MARK: Lifecycle

        public init(
            options: DecodingOptions,
            typeNameFormat: NDEF.TypeNameFormat,
            type: ReadableBytesCollection,
            id: ReadableBytesCollection,
            payload: ReadableBytesCollection
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

        public let type: ReadableBytesCollection
        public let id: ReadableBytesCollection
        public let payload: ReadableBytesCollection
    }
}

// MARK: - NDEFDecoder.Container + Hashable

extension NDEFDecoder.Container: Hashable {}
