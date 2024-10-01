//
//  Created by Adam Stragner
//

// MARK: - Header

struct Header {
    // MARK: Lifecycle

    init(flags: Flags, type: [UInt8], id: [UInt8], payloadLength: Int) {
        self.flags = flags
        self.type = type
        self.id = id
        self.payloadLength = payloadLength
    }

    // MARK: Internal

    var flags: Flags
    var type: [UInt8]
    var id: [UInt8]
    var payloadLength: Int
}

// MARK: Hashable

extension Header: Hashable {}
