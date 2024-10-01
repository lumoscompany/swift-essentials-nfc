//
//  Created by Adam Stragner
//

// MARK: - TLVDecoder.DecodingOptions

public extension TLVDecoder {
    struct DecodingOptions {
        // MARK: Lifecycle

        public init(
            shouldRespectTeriminateTLV: Bool = true,
            additionalDataTypes: [DecodableType] = []
        ) {
            self.shouldRespectTeriminateTLV = shouldRespectTeriminateTLV
            self.additionalDataTypes = additionalDataTypes
        }

        // MARK: Public

        public var shouldRespectTeriminateTLV: Bool
        public var additionalDataTypes: [DecodableType]
    }
}

public extension TLVDecoder.DecodingOptions {
    static let defaults = TLVDecoder.DecodingOptions()
}

// MARK: - TLVDecoder.DecodingOptions + Hashable

extension TLVDecoder.DecodingOptions: Hashable {}

// MARK: - TLVDecoder.DecodingOptions + Sendable

extension TLVDecoder.DecodingOptions: Sendable {}

public extension TLVDecoder.DecodingOptions {
    static let knownDataTypes: [TLVDecoder.DecodableType] = [
        .init(TLV.NULL.self),
        .init(TLV.LOCK_CONTROL.self),
        .init(TLV.MEMORY_CONTROL.self),
        .init(TLV.NDEF.self),
        .init(TLV.PROPRIETARY.self),
        .init(TLV.TERMINATOR.self),
    ]
}

extension TLVDecoder.DecodingOptions {
    var availableDataTypes: [UInt8: TLVDecoder.DecodableType] {
        let knownTypes = Self.knownDataTypes
        var result = Dictionary(uniqueKeysWithValues: knownTypes.map({ ($0.dataType, $0) }))
        additionalDataTypes.forEach({ result[$0.dataType] = $0 })
        return result
    }
}
