//
//  Created by Adam Stragner
//

@_exported import ISO7816
@_exported import TLV
@_exported import NDEF

public extension NDEFDecoder {
    func decode(from tlv: TLV.NDEF) throws -> [any NDEFDecodble] {
        try tlv.decode(with: self)
    }
}

public extension TLV.NDEF {
    func decode(
        with options: NDEFDecoder.DecodingOptions = .defaults
    ) throws -> [any NDEFDecodble] {
        try decode(with: .init(options))
    }

    func decode(with decoder: NDEFDecoder) throws -> [any NDEFDecodble] {
        try decoder.decode(from: bytes)
    }
}

public extension NDEFEncoder {
    func encode(_ values: [any NDEFEncodable], to ndef: inout TLV.NDEF) throws {
        try ndef.encode(values, with: self)
    }
}

public extension TLV.NDEF {
    init(
        _ values: [any NDEFEncodable],
        with options: NDEFEncoder.EncodingOptions = .defaults
    ) throws {
        try self.init(values, with: NDEFEncoder(options))
    }

    init(_ values: [any NDEFEncodable], with encoder: NDEFEncoder) throws {
        let bytes = try encoder.encode(values)
        self.init(bytes: bytes)
    }

    mutating func encode(
        _ values: [any NDEFEncodable],
        with options: NDEFEncoder.EncodingOptions = .defaults
    ) throws {
        try encode(values, with: .init(options))
    }

    mutating func encode(
        _ values: [any NDEFEncodable],
        with encoder: NDEFEncoder
    ) throws {
        let bytes = try encoder.encode(values)
        self.bytes = bytes
    }
}
