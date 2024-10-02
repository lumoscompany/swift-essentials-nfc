//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEF.AbsoluteURI

public extension NDEF {
    struct AbsoluteURI: NDEFCodable {
        // MARK: Lifecycle

        public init(identifier: [UInt8] = [], string: String) {
            self.identifier = identifier
            self.string = string
        }

        public init(with container: NDEFDecoder.Container) throws {
            let type = container.type
            guard let utf8 = String(bytes: type.rawValue, encoding: .utf8)
            else {
                throw NDEFDecodingError.dataCorrupted("Couldn't decode AbsoluteURI")
            }
            self.init(identifier: container.id.rawValue, string: utf8)
        }

        // MARK: Public

        public static let dataType: [UInt8]? = nil
        public static let typeNameFormatConstraint: NDEF.TypeNameFormat = .absoluteURI

        public let identifier: [UInt8]
        public let string: String

        public func encode(to container: inout NDEFEncoder.Container) throws {
            container.id.append(contentsOf: identifier)
            container.type.append(contentsOf: [UInt8](string.utf8))
        }
    }
}

public extension NDEF.AbsoluteURI {
    var value: String { string }
    var url: URL? { URL(string: value) }
}
