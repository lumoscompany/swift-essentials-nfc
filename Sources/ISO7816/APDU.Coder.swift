//
//  Created by Adam Stragner
//

import Essentials

// MARK: - ISO7816.APDU.Coder

extension ISO7816.APDU {
    struct Coder {}
}

// MARK: - ISO7816.APDU.Coder.Command

extension ISO7816.APDU.Coder {
    typealias Command = (
        instructionClass: Byte,
        instructionCode: Byte,
        p1Parameter: Byte,
        p2Parameter: Byte,
        data: ByteCollection?,
        expectedResponseLength: Int?
    )
}

extension ISO7816.APDU.Coder {
    func encode(
        _ request: Command
    ) throws (ISO7816.APDU.Error) -> ByteCollection {
        let encodedDataLength: ByteCollection
        let encodedBody: ByteCollection
        let encodedExpectedLength: ByteCollection

        if let body = request.data, !body.isEmpty {
            switch body.count {
            case 0:
                encodedDataLength = []
            case 1 ..< ISO7816.maximumLengthShort:
                encodedDataLength = [UInt8(body.count)]
            case ISO7816.maximumLengthShort:
                encodedDataLength = [0x0]
            case ISO7816.maximumLengthShort + 1 ..< ISO7816.maximumLengthLong:
                encodedDataLength = [0x0] + UInt16(body.count).byteCollection(with: .big)
            case ISO7816.maximumLengthLong:
                encodedDataLength = [0x0, 0x0, 0x0]
            default:
                throw ISO7816.APDU.Error.bodyTooLarge
            }

            encodedBody = body
        } else {
            encodedDataLength = []
            encodedBody = []
        }

        if let expectedResponseLength = request.expectedResponseLength {
            switch expectedResponseLength {
            case .min ..< 0:
                throw ISO7816.APDU.Error.expectedResponseLengthOutOfBounds
            case 0:
                encodedExpectedLength = []
            case 1 ..< ISO7816.maximumLengthShort:
                encodedExpectedLength = [UInt8(expectedResponseLength)]
            case ISO7816.maximumLengthShort:
                encodedExpectedLength = [0x0]
            case ISO7816.maximumLengthShort + 1 ..< ISO7816.maximumLengthLong:
                let le = UInt16(expectedResponseLength).byteCollection(with: .big)
                encodedExpectedLength = encodedDataLength.count > 1 ? le : [0x0] + le
            case ISO7816.maximumLengthLong:
                encodedExpectedLength = encodedDataLength.count > 1 ? [0x0, 0x0] : [
                    0x0,
                    0x0,
                    0x0,
                ]
            default:
                throw ISO7816.APDU.Error.expectedResponseLengthOutOfBounds
            }
        } else {
            encodedExpectedLength = []
        }

        return [
            request.instructionClass,
            request.instructionCode,
            request.p1Parameter,
            request.p2Parameter,
        ] + encodedDataLength + encodedBody + encodedExpectedLength
    }
}

extension ISO7816.APDU.Coder {
    func decode(_ byteCollection: ByteCollection) throws (ISO7816.APDU.Error) -> Command {
        var byteCollection = ReadableByteCollection(byteCollection)

        func _le(_ bytes: ByteCollection) throws (ISO7816.APDU.Error) -> Int? {
            switch bytes.count {
            case 0:
                return nil
            case 1 where bytes[0] == 0x0:
                return ISO7816.maximumLengthShort
            case 1:
                return Int(bytes[0])
            case 2 where bytes[0] == 0x0 && bytes[1] == 0x0:
                return ISO7816.maximumLengthLong
            case 2:
                return Int(Int16(byteCollection: [bytes[0], bytes[1]], .big))
            case 3 where bytes[0] == 0x0 && bytes[1] == 0x0 && bytes[2] == 0x0:
                return ISO7816.maximumLengthLong
            case 3 where bytes[0] == 0x0:
                return Int(Int16(byteCollection: [bytes[1], bytes[2]], .big))
            default:
                throw ISO7816.APDU.Error.expectedResponseLengthOutOfBounds
            }
        }

        let header = try? byteCollection.read(4)
        guard let header
        else {
            throw ISO7816.APDU.Error.invalidHeader
        }

        let data: [UInt8]?
        let expectedResponseLength: Int?

        let remainig = byteCollection.rawValue
        switch remainig.count {
        case 0, 1,
             3 where remainig[0] == 0x0:
            data = nil
            expectedResponseLength = try _le(remainig)
        default:
            var collection = ReadableByteCollection(remainig)
            let dataLength: Int

            do {
                if remainig[0] == 0x0 {
                    try collection.read()
                    dataLength = try Int(Int16(byteCollection: collection.read(2), .big))
                } else {
                    dataLength = try Int(collection.read())
                }

                data = try collection.read(dataLength)
            } catch {
                throw ISO7816.APDU.Error.invalidBody
            }

            expectedResponseLength = try _le(collection.rawValue)
        }

        return (
            header[0],
            header[1],
            header[2],
            header[3],
            data,
            expectedResponseLength
        )
    }
}
