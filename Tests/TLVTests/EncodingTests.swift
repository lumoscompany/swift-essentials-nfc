//
//  Created by Adam Stragner
//

import XCTest

@testable import TLV

final class EncodingTests: XCTestCase {
    func testAll() throws {
        try XCTAssertEqual(TLVEncoder().encode([
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
            TLV.TERMINATOR(),
        ]), [0x00, 0x00, 0x00, 0x00, 0xFE])

        try XCTAssertEqual(TLVEncoder().encode([
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
        ]), [0x00, 0x00, 0x00, 0x00, 0xFE])

        try XCTAssertEqual(TLVEncoder(.init(isAppendingTerminateTLVIfNecessary: false)).encode([
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
        ]), [0x00, 0x00, 0x00, 0x00])
        
        try XCTAssertNotEqual(TLVEncoder(.init(isAppendingTerminateTLVIfNecessary: true)).encode([
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
            TLV.NULL(),
        ]), [0x00, 0x00, 0x00, 0x00])
        
        try XCTAssertEqual(TLVEncoder().encode([
            TLV.LOCK_CONTROL(bytes: [0x00, 0x00, 0x00, 0x00]),
        ]), [0x01, 0x00, 0x00, 0x00, 0x00, 0xFE])
        
        try XCTAssertEqual(TLVEncoder().encode([
            TLV.MEMORY_CONTROL(bytes: [0x00, 0x00, 0x00, 0x00]),
        ]), [0x02, 0x00, 0x00, 0x00, 0x00, 0xFE])
        
        try XCTAssertEqual(TLVEncoder().encode([
            TLV.PROPRIETARY(bytes: [0x42, 0x42]),
        ]), [0xFD, 0x02, 0x42, 0x42, 0xFE])
    }
}
