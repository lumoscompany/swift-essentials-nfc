//
//  Created by Adam Stragner
//

import Essentials

// MARK: - NDEFDecodble

public protocol NDEFDecodble: _NDEFDataProtocol {
    init(with container: NDEFDecoder.Container) throws
}

// MARK: - NDEFEncodable

public protocol NDEFEncodable: _NDEFDataProtocol {
    func encode(to container: inout NDEFEncoder.Container) throws
}

public typealias NDEFCodable = NDEFDecodble & NDEFEncodable

// MARK: - _NDEFDataProtocol

public protocol _NDEFDataProtocol: Hashable, Sendable {
    static var dataType: ByteCollection? { get }
    static var typeNameFormatConstraint: NDEF.TypeNameFormat { get }
}
