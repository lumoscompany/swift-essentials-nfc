//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEF.URI

public extension NDEF {
    struct URI: NDEFCodable {
        // MARK: Lifecycle

        public init(identifier: [UInt8] = [], string: String) {
            self.identifier = identifier
            self.string = string
        }

        public init(with container: NDEFDecoder.Container) throws {
            var byteCollection = container.payload
            guard let prefix = try NDEF.URI.prefixCodeWithIndex(byteCollection.read()),
                  let utf8 = String(bytes: byteCollection.rawValue, encoding: .utf8)
            else {
                throw NDEFDecodingError.dataCorrupted("Couldn't decode URI")
            }
            self.init(identifier: container.id.rawValue, string: "\(prefix)\(utf8)")
        }

        // MARK: Public

        public static let dataType: [UInt8]? = [0x55]
        public static let typeNameFormatConstraint: NDEF.TypeNameFormat = .wellknown

        public let identifier: [UInt8]
        public let string: String

        public func encode(to container: inout NDEFEncoder.Container) throws {
            let info = NDEF.URI.prefixDataWithURL(string)

            container.id.append(contentsOf: identifier)
            container.payload.append(contentsOf: [info.code])
            container.payload.append(contentsOf: [UInt8](string.dropFirst(info.prefix.count).utf8))
        }
    }
}

public extension NDEF.URI {
    var value: String { string }
    var url: URL? { URL(string: value) }
}

private extension NDEF.URI {
    private static let prefixes: [String] = [
        "",
        "http://www.",
        "https://www.",
        "http://",
        "https://",
        "tel:",
        "mailto:",
        "ftp://anonymous:anonymous@",
        "ftp://ftp.",
        "ftps://",
        "sftp://",
        "smb://",
        "nfs://",
        "ftp://",
        "dav://",
        "news:",
        "telnet://",
        "imap:",
        "rtsp://",
        "urn:",
        "pop:",
        "sip:",
        "sips:",
        "tftp:",
        "btspp://",
        "btl2cap://",
        "btgoep://",
        "tcpobex://",
        "irdaobex://",
        "file://",
        "urn:epc:id:",
        "urn:epc:tag:",
        "urn:epc:pat:",
        "urn:epc:raw:",
        "urn:epc:",
        "urn:nfc:",
    ]

    static func prefixCodeWithIndex(_ index: UInt8) -> String? {
        prefixes[Int(index)]
    }

    static func prefixDataWithURL(_ string: String) -> (code: UInt8, prefix: String) {
        let index = prefixes
            .dropFirst() // remove ""
            .firstIndex(where: { string.starts(with: $0) })

        guard let index
        else {
            return (0x00, "")
        }

        return (UInt8(index), prefixes[index])
    }
}
