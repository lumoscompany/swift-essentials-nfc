//
//  Created by Adam Stragner
//

// MARK: - NDEFEncoder.EncodingOptions

public extension NDEFEncoder {
    struct EncodingOptions: OptionSet {
        // MARK: Lifecycle

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public let rawValue: UInt
    }
}

public extension NDEFEncoder.EncodingOptions {
    static let defaults: NDEFEncoder.EncodingOptions = []
}

// MARK: - NDEFEncoder.EncodingOptions + Hashable

extension NDEFEncoder.EncodingOptions: Hashable {}

// MARK: - NDEFEncoder.EncodingOptions + Sendable

extension NDEFEncoder.EncodingOptions: Sendable {}
