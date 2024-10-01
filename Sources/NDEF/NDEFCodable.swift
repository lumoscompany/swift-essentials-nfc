//
//  Created by Adam Stragner
//

public typealias NDEFCodable = NDEFDecodble & NDEFEncodable

// MARK: - NDEFDecodble

public protocol NDEFDecodble: _NDEFDataProtocol {
    init(with container: NDEFDecoder.Container) throws
}

// MARK: - NDEFEncodable

public protocol NDEFEncodable: _NDEFDataProtocol {
    func encode(to container: NDEFEncoder.Container) throws
}

// MARK: - _NDEFDataProtocol

public protocol _NDEFDataProtocol: Hashable, Sendable {
    static var dataType: [UInt8]? { get }
    static var typeNameFormatConstraint: NDEF.TypeNameFormat { get }
}
