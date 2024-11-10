//
//  Created by Adam Stragner
//

import XCTest

@testable import TLV

final class DecodingTests: XCTestCase {
    func testDecodeSingle() throws {
        let bytes0: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        try XCTAssertEqual(
            TLVDecoder().decode(TLV.LOCK_CONTROL.self, from: [0x01] + bytes0),
            TLV.LOCK_CONTROL(bytes: bytes0)
        )
        
        let bytes1: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        try XCTAssertEqual(
            TLVDecoder().decode(TLV.MEMORY_CONTROL.self, from: [0x02] + bytes1),
            TLV.MEMORY_CONTROL(bytes: bytes0)
        )
        
        let bytes2: [UInt8] = [0x42, 0x42]
        try XCTAssertEqual(
            TLVDecoder().decode(TLV.PROPRIETARY.self, from: [0xFD, 0x02] + bytes2),
            TLV.PROPRIETARY(bytes: bytes2)
        )
    }

    func testDecodeArray() throws {
        let data: [UInt8] = [
            0x00,
            0x00,
            0x00,
            0x01, 0x00, 0x00, 0x00, 0x00,
            0x02, 0x00, 0x00, 0x00, 0x00,
            0xFD, 0x02, 0x42, 0x42,
            0xFE,
        ]

        let result = try TLVDecoder().decode(from: data)
        XCTAssertTrue(result.count == 7)
        XCTAssertTrue(result[0] is TLV.NULL)
        XCTAssertTrue(result[1] is TLV.NULL)
        XCTAssertTrue(result[2] is TLV.NULL)

        XCTAssertTrue(result[3] is TLV.LOCK_CONTROL)
        XCTAssertEqual((result[3] as? TLV.LOCK_CONTROL)?.bytes, [0x00, 0x00, 0x00, 0x00])

        XCTAssertTrue(result[4] is TLV.MEMORY_CONTROL)
        XCTAssertEqual((result[4] as? TLV.MEMORY_CONTROL)?.bytes, [0x00, 0x00, 0x00, 0x00])

        XCTAssertTrue(result[5] is TLV.PROPRIETARY)
        XCTAssertEqual((result[5] as? TLV.PROPRIETARY)?.bytes, [0x42, 0x42])

        XCTAssertTrue(result[6] is TLV.TERMINATOR)
    }
}
