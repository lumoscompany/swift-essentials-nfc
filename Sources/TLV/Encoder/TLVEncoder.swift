//
//  Created by Adam Stragner
//

import Essentials

// MARK: - TLVEncoder

public struct TLVEncoder {
    // MARK: Lifecycle

    public init(_ options: EncodingOptions = .defaults) {
        self.options = options
    }

    // MARK: Public

    public let options: EncodingOptions

    public func encode(_ value: [any TLVEncodable]) throws -> ByteCollection {
        var byteCollection = ReadableByteCollection()
        var index = 0

        try value.forEach({
            try _encode($0, to: &byteCollection)

            if index == value.count - 1,
               options.isAppendingTerminateTLVIfNecessary,
               !($0 is TLV.TERMINATOR)
            {
                try _encode(TLV.TERMINATOR(), to: &byteCollection)
            }

            index += 1
        })

        return byteCollection.rawValue
    }

    public func encode<T>(_ value: T) throws -> ByteCollection where T: TLVEncodable {
        var byteCollection = ReadableByteCollection()
        try _encode(value, to: &byteCollection)
        return byteCollection.rawValue
    }

    // MARK: Private

    private func _encode<T>(
        _ value: T,
        to byteCollection: inout ReadableByteCollection
    ) throws where T: TLVEncodable {
        var container = Container(options: options, storage: .init())
        try value.encode(to: &container)
        let bytes = container.storage.rawValue

        byteCollection.append(contentsOf: [T.dataType])
        try T.constrainedLength.encode(to: &byteCollection, withActualLength: bytes.count)

        byteCollection.append(contentsOf: bytes)
    }
}

// MARK: Sendable

extension TLVEncoder: Sendable {}
