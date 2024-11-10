//
//  Created by Adam Stragner
//

// MARK: - NDEFDecoder.DecodingOptions

public extension NDEFDecoder {
    struct DecodingOptions {
        // MARK: Lifecycle

        public init(additionalDataTypes: [DecodableType] = []) {
            self.additionalDataTypes = additionalDataTypes
        }

        // MARK: Public

        public let additionalDataTypes: [DecodableType]
    }
}

public extension NDEFDecoder.DecodingOptions {
    static let defaults = NDEFDecoder.DecodingOptions()
}

// MARK: - NDEFDecoder.DecodingOptions + Hashable

extension NDEFDecoder.DecodingOptions: Hashable {}

// MARK: - NDEFDecoder.DecodingOptions + Sendable

extension NDEFDecoder.DecodingOptions: Sendable {}

extension Array where Element == NDEFDecoder.DecodableType {
    static let knownTypes: [NDEFDecoder.DecodableType] = []
}

public extension NDEFDecoder.DecodingOptions {
    static let knownDataTypes: [NDEFDecoder.DecodableType] = [
        .init(NDEF.URI.self),
        .init(NDEF.Message.self),
    ]
}

extension NDEFDecoder.DecodingOptions {
    var availableDataTypes: NDEFDecoder.DecodableTypeRegister {
        .init(with: Self.knownDataTypes + additionalDataTypes)
    }
}
