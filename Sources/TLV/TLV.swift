//
//  Created by Adam Stragner
//

// MARK: - TLV

public enum TLV {}

// MARK: TLV.NULL

public extension TLV {
    struct NULL: TLVCodable {
        // MARK: Lifecycle

        public init() {}
        public init(with container: TLVDecoder.Container) throws {}

        // MARK: Public

        public static let dataType: UInt8 = 0x0
        public static let constrainedLength: TLVConstrainedLength? = .init(0, .ephemeral)

        public func encode(to container: inout TLVEncoder.Container) throws {}
    }
}

// MARK: TLV.LOCK_CONTROL

public extension TLV {
    struct LOCK_CONTROL: TLVCodable {
        // MARK: Lifecycle

        public init(bytes: [UInt8]) {
            self.bytes = bytes
        }

        public init(with container: TLVDecoder.Container) throws {
            self.init(bytes: container.storage.rawValue)
        }

        // MARK: Public

        public static let dataType: UInt8 = 0x01
        public static let constrainedLength: TLVConstrainedLength? = .init(4, .ephemeral)

        public var bytes: [UInt8]

        public func encode(to container: inout TLVEncoder.Container) throws {
            container.storage.append(contentsOf: bytes)
        }
    }
}

// MARK: TLV.MEMORY_CONTROL

public extension TLV {
    struct MEMORY_CONTROL: TLVCodable {
        // MARK: Lifecycle

        public init(bytes: [UInt8]) {
            self.bytes = bytes
        }

        public init(with container: TLVDecoder.Container) throws {
            self.init(bytes: container.storage.rawValue)
        }

        // MARK: Public

        public static let dataType: UInt8 = 0x02
        public static let constrainedLength: TLVConstrainedLength? = .init(4, .ephemeral)

        public var bytes: [UInt8]

        public func encode(to container: inout TLVEncoder.Container) throws {
            container.storage.append(contentsOf: bytes)
        }
    }
}

// MARK: TLV.NDEF

public extension TLV {
    struct NDEF: TLVCodable {
        // MARK: Lifecycle

        public init(bytes: [UInt8]) {
            self.bytes = bytes
        }

        public init(with container: TLVDecoder.Container) throws {
            self.init(bytes: container.storage.rawValue)
        }

        // MARK: Public

        public static let dataType: UInt8 = 0x03
        public static let constrainedLength: TLVConstrainedLength? = nil

        public var bytes: [UInt8]

        public func encode(to container: inout TLVEncoder.Container) throws {
            container.storage.append(contentsOf: bytes)
        }
    }
}

// MARK: TLV.PROPRIETARY

public extension TLV {
    struct PROPRIETARY: TLVCodable {
        // MARK: Lifecycle

        public init(bytes: [UInt8]) {
            self.bytes = bytes
        }

        public init(with container: TLVDecoder.Container) throws {
            self.init(bytes: container.storage.rawValue)
        }

        // MARK: Public

        public static let dataType: UInt8 = 0xFD
        public static let constrainedLength: TLVConstrainedLength? = nil

        public var bytes: [UInt8]

        public func encode(to container: inout TLVEncoder.Container) throws {
            container.storage.append(contentsOf: bytes)
        }
    }
}

// MARK: TLV.TERMINATOR

public extension TLV {
    struct TERMINATOR: TLVCodable {
        // MARK: Lifecycle

        public init() {}
        public init(with container: TLVDecoder.Container) throws {}

        // MARK: Public

        public static let dataType: UInt8 = 0xFE
        public static let constrainedLength: TLVConstrainedLength? = .init(0, .ephemeral)

        public func encode(to container: inout TLVEncoder.Container) throws {}
    }
}
