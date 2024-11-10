//
//  Created by Adam Stragner
//

// MARK: - NDEF.Unimplemented

extension NDEF {
    struct _Unimplemented: NDEFCodable {
        // MARK: Lifecycle

        init(with container: NDEFDecoder.Container) throws {
            self.typeNameFormat = container.typeNameFormat
            self.type = container.type.rawValue
            self.id = container.id.rawValue
            self.payload = container.payload.rawValue
        }

        // MARK: Internal

        static let dataType: [UInt8]? = nil
        static let typeNameFormatConstraint: NDEF.TypeNameFormat = .unknown

        let typeNameFormat: NDEF.TypeNameFormat

        func encode(to container: inout NDEFEncoder.Container) throws {
            container.id.append(contentsOf: id)
            container.type.append(contentsOf: type)
            container.payload.append(contentsOf: payload)
        }

        // MARK: Private

        private let type: [UInt8]
        private let id: [UInt8]
        private let payload: [UInt8]
    }
}
