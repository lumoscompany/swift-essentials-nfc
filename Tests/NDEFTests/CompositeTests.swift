//
//  Created by Adam Stragner
//

import XCTest
import TLV
import Essentials

@testable import NDEF

final class EncodingTests: XCTestCase {
    // MARK: Internal

    func testRecords() throws {
        try {
            let record = records[0]

            let decoded = try NDEFDecoder().decode(NDEF.Message.self, from: record)
            XCTAssertEqual(decoded.encoding, .utf8)
            XCTAssertEqual(decoded.language, "en")
            XCTAssertEqual(decoded.string, "Test")

            var encoded = try NDEFEncoder().encode(decoded)
            updateMFME(in: &encoded, mf: true, me: false)

            XCTAssertEqual(record, encoded)
        }()

        try {
            let record = records[1]

            let decoded = try NDEFDecoder().decode(NDEF.URI.self, from: record)
            XCTAssertEqual(decoded.string, "mycomcustom")

            var encoded = try NDEFEncoder().encode(decoded)
            updateMFME(in: &encoded, mf: false, me: false)

            XCTAssertEqual(record, encoded)
        }()

        try {
            let record = records[2]

            let decoded = try NDEFDecoder().decode(NDEF.URI.self, from: record)
            XCTAssertEqual(decoded.string, "https://test.com")

            var encoded = try NDEFEncoder().encode(decoded)
            updateMFME(in: &encoded, mf: false, me: true)

            XCTAssertEqual(record, encoded)
        }()
    }

    func testComposite() throws {
        let data = records.flatMap({ $0 })

        let decoded = try NDEFDecoder().decode(from: data)
        XCTAssertEqual(decoded.count, 3)

        let encoded = try NDEFEncoder().encode(decoded as! [any NDEFCodable])
        XCTAssertEqual(data, encoded)
    }

    // MARK: Private

    private let records: [[UInt8]] = [
        // swiftformat:disable:next all
        [0x91, 0x01, 0x07, 0x54, 0x02, 0x65, 0x6e, 0x54, 0x65, 0x73, 0x74], // wlk;text;7;mf_1;me_0 - utf8 ; en;Test
        // swiftformat:disable:next all
        [0x11, 0x01, 0x0c, 0x55, 0x00, 0x6d, 0x79, 0x63, 0x6f, 0x6d, 0x63, 0x75, 0x73, 0x74, 0x6f, 0x6d], // wlk;uri;12;mf_0;me_0 - _ ; mycomcustom
        // swiftformat:disable:next all
        [0x51, 0x01, 0x09, 0x55, 0x04, 0x74, 0x65, 0x73, 0x74, 0x2e, 0x63, 0x6f, 0x6d], // wlk;uri;12;mf_0;mf_1 - https:// ; test.com
    ]

    private func updateMFME(in bytes: inout [UInt8], mf: Bool, me: Bool) {
        struct MFME: OptionByte {
            init(_ rawValue: UInt8) {
                self.rawValue = rawValue
            }

            enum OptionKeys: UInt8, OptionKey {
                case mf = 7 // 0b10000000
                case me = 6 // 0b01000000
            }

            var rawValue: UInt8
        }

        var mfme = MFME(bytes[0])
        mfme[option: .mf] = mf
        mfme[option: .me] = me

        bytes[0] = mfme.rawValue
    }
}
