//
//  Created by Adam Stragner
//

// MARK: - TLVEncoder.EncodingOptions

public extension TLVEncoder {
    struct EncodingOptions {
        // MARK: Lifecycle

        public init(isAppendingTerminateTLVIfNecessary: Bool) {
            self.isAppendingTerminateTLVIfNecessary = isAppendingTerminateTLVIfNecessary
        }

        // MARK: Public

        public let isAppendingTerminateTLVIfNecessary: Bool
    }
}

public extension TLVEncoder.EncodingOptions {
    static let defaults = TLVEncoder.EncodingOptions(isAppendingTerminateTLVIfNecessary: true)
}

// MARK: - TLVEncoder.EncodingOptions + Hashable

extension TLVEncoder.EncodingOptions: Hashable {}

// MARK: - TLVEncoder.EncodingOptions + Sendable

extension TLVEncoder.EncodingOptions: Sendable {}
