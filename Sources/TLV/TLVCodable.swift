//
//  Created by Adam Stragner
//

public typealias TLVCodable = TLVDecodble & TLVEncodable

// MARK: - TLVDecodble

public protocol TLVDecodble: _TLVDataProtocol {
    init(with container: TLVDecoder.Container) throws
}

// MARK: - TLVEncodable

public protocol TLVEncodable: _TLVDataProtocol {
    func encode(to container: inout TLVEncoder.Container) throws
}

// MARK: - _TLVDataProtocol

public protocol _TLVDataProtocol: Sendable, Hashable {
    static var dataType: UInt8 { get }
    static var constrainedLength: TLVConstrainedLength? { get }
}

public extension _TLVDataProtocol {
    static var constrainedLength: TLVConstrainedLength? { nil }
}
