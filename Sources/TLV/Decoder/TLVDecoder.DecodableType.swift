//
//  Created by Adam Stragner
//

// MARK: - TLVDecoder.DecodableType

public extension TLVDecoder {
    struct DecodableType {
        // MARK: Lifecycle

        public init<T>(_ type: T.Type) where T: TLVDecodble {
            self.dataType = type.dataType
            self.constrainedLength = type.constrainedLength

            self._type = String(describing: T.self)
            self._decode = { try T(with: $0) }
        }

        // MARK: Internal

        let dataType: UInt8
        let constrainedLength: TLVConstrainedLength?

        func decode(with container: TLVDecoder.Container) throws -> any TLVDecodble {
            try _decode(container)
        }

        // MARK: Private

        private let _type: String
        private let _decode: @Sendable (_ container: Container) throws -> any TLVDecodble
    }
}

// MARK: - TLVDecoder.DecodableType + CustomDebugStringConvertible

extension TLVDecoder.DecodableType: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(_type)"
    }
}

// MARK: - TLVDecoder.DecodableType + Equatable

extension TLVDecoder.DecodableType: Equatable {
    public static func == (lhs: TLVDecoder.DecodableType, rhs: TLVDecoder.DecodableType) -> Bool {
        lhs.dataType == rhs.dataType
    }
}

// MARK: - TLVDecoder.DecodableType + Hashable

extension TLVDecoder.DecodableType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataType)
    }
}

// MARK: - TLVDecoder.DecodableType + Sendable

extension TLVDecoder.DecodableType: Sendable {}
