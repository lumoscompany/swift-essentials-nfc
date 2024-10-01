//
//  Created by Adam Stragner
//

// MARK: - NDEFDecoder.DecodableType

public extension NDEFDecoder {
    struct DecodableType {
        // MARK: Lifecycle

        public init<T>(_ type: T.Type) where T: NDEFDecodble {
            self.dataType = type.dataType
            self.isUnimplemented = T.self is NDEF._Unimplemented.Type
            self.constrainedTypeNameFormat = type.typeNameFormatConstraint
            self._decode = { try T(with: $0) }
        }

        // MARK: Internal

        let dataType: [UInt8]?
        let constrainedTypeNameFormat: NDEF.TypeNameFormat
        let isUnimplemented: Bool

        func decode(with container: NDEFDecoder.Container) throws -> any NDEFDecodble {
            try _decode(container)
        }

        // MARK: Private

        private let _decode: @Sendable (_ container: Container) throws -> any NDEFDecodble
    }
}

// MARK: - NDEFDecoder.DecodableType + Equatable

extension NDEFDecoder.DecodableType: Equatable {
    public static func == (lhs: NDEFDecoder.DecodableType, rhs: NDEFDecoder.DecodableType) -> Bool {
        lhs.dataType == rhs.dataType
    }
}

// MARK: - NDEFDecoder.DecodableType + Hashable

extension NDEFDecoder.DecodableType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dataType)
    }
}

// MARK: - NDEFDecoder.DecodableType + Sendable

extension NDEFDecoder.DecodableType: Sendable {}
