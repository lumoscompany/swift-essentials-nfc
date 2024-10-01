//
//  Created by Adam Stragner
//

// MARK: - NDEFDecoder.DecodableTypeRegister

extension NDEFDecoder {
    struct DecodableTypeRegister {
        // MARK: Lifecycle

        init(with decodableTypes: [NDEFDecoder.DecodableType]) {
            var records: [NDEF.TypeNameFormat: Record] = [:]
            decodableTypes.forEach({
                let record = records[$0.constrainedTypeNameFormat] ?? .init()
                record.register($0, forType: $0.dataType)
                records[$0.constrainedTypeNameFormat] = record
            })
            self.records = records
        }

        // MARK: Internal

        func decodableType(
            for typeNameFormat: NDEF.TypeNameFormat,
            forType type: [UInt8]
        ) -> NDEFDecoder.DecodableType {
            guard let decodableType = records[typeNameFormat]?.get(forType: type)
            else {
                return .init(NDEF._Unimplemented.self)
            }
            return decodableType
        }

        // MARK: Private

        private let records: [NDEF.TypeNameFormat: Record]
    }
}

// MARK: - NDEFDecoder.DecodableTypeRegister.Record

private extension NDEFDecoder.DecodableTypeRegister {
    final class Record {
        // MARK: Internal

        func get(forType type: [UInt8]) -> NDEFDecoder.DecodableType? {
            guard let decodableType = decodableTypes[type]
            else {
                return omnivorous
            }
            return decodableType
        }

        func register(_ decodableType: NDEFDecoder.DecodableType, forType type: [UInt8]?) {
            guard let type
            else {
                omnivorous = decodableType
                return
            }
            decodableTypes[type] = decodableType
        }

        // MARK: Private

        private var omnivorous: NDEFDecoder.DecodableType?
        private var decodableTypes: [[UInt8]: NDEFDecoder.DecodableType] = [:]
    }
}
