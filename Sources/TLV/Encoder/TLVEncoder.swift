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

    public func encode(_ value: [any TLVEncodable]) throws -> [UInt8] {
        let storage = ReadableBytesCollection()
        var index = 0

        try value.forEach({
            try _encode($0, to: storage)

            if index == value.count - 1,
               options.isAppendingTerminateTLVIfNecessary,
               !($0 is TLV.TERMINATOR)
            {
                try _encode(TLV.TERMINATOR(), to: storage)
            }

            index += 1
        })

        return storage.value
    }

    public func encode<T>(_ value: T) throws -> [UInt8] where T: TLVEncodable {
        let storage = ReadableBytesCollection()
        try _encode(value, to: storage)
        return storage.value
    }

    // MARK: Private

    private func _encode<T>(
        _ value: T,
        to storage: ReadableBytesCollection
    ) throws where T: TLVEncodable {
        let container = Container(options: options, storage: .init())
        try value.encode(to: container)
        let bytes = container.storage.value

        storage.append(contentsOf: [T.dataType])
        try T.constrainedLength.encode(to: storage, withActualLength: bytes.count)

        storage.append(contentsOf: bytes)
    }
}

// MARK: Sendable

extension TLVEncoder: Sendable {}
