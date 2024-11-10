//
//  Created by Adam Stragner
//

// Layout [LONG]:
// | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  |
// +----+----+----+----+----+----+----+----+
// | MB | ME | CF | SR | IL | TNF          |
// +----+----+----+----+----+----+----+----+
// | TYPE LENGTH                           |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD LENGTH 3                      |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD LENGTH 2                      |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD LENGTH 1                      |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD LENGTH 0                      |
// +----+----+----+----+----+----+----+----+
// | ID LENGTH                             |
// +----+----+----+----+----+----+----+----+
// | TYPE                                  |
// +----+----+----+----+----+----+----+----+
// | ID                                    |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD                               |
// +----+----+----+----+----+----+----+----+
//
//
// Layout [SHORT]:
// | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  |
// +----+----+----+----+----+----+----+----+
// | MB | ME | CF | SR | IL | TNF          |
// +----+----+----+----+----+----+----+----+
// | TYPE LENGTH                           |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD LENGTH                        |
// +----+----+----+----+----+----+----+----+
// | ID LENGTH                             |
// +----+----+----+----+----+----+----+----+
// | TYPE                                  |
// +----+----+----+----+----+----+----+----+
// | ID                                    |
// +----+----+----+----+----+----+----+----+
// | PAYLOAD                               |
// +----+----+----+----+----+----+----+----+
//
// Record layout requirements:
// - NDEF parsers MUST accept both normal and short record layouts.
// - NDEF parsers MUST accept single NDEF messages composed of both normal and short records.
// - If the IL flag is 1, the ID_LENGTH field MUST be present.
// - If the IL flag is 0, the ID_LENGTH field MUST NOT be present.
// - If the IL flag is 0, the ID field MUST NOT be present.
// - The TNF field MUST have a value between 0x00 and 0x06.
// - If the TNF value is 0x00, the TYPE_LENGTH, ID_LENGTH, and PAYLOAD_LENGTH
//   fields MUST be zero and the TYPE, ID, and PAYLOAD fields MUST be omitted from the
//   record.
// - If the TNF value is 0x05 (Unknown), the TYPE_LENGTH field MUST be 0 and the TYPE
//   field MUST be omitted from the NDEF record.
// - If the TNF value is 0x06 (Unchanged), the TYPE_LENGTH field MUST be 0 and the TYPE
//   field MUST be omitted from the NDEF record.
// - The TNF value MUST NOT be 0x07.
// - If the ID_LENGTH field has a value 0, the ID field MUST NOT be present.
// - If the SR flag is 0, the PAYLOAD_LENGTH field is four octets, representing a 32-bit
//   unsigned integer, and the transmission order of the octets is MSB-first.
// - If the SR flag is 1, the PAYLOAD_LENGTH field is a single octet representing an 8-bit
//   unsigned integer.
// - If the PAYLOAD_LENGTH field value is 0, the PAYLOAD field MUST NOT be present.
// - The value of the TYPE field MUST follow the structure, encoding, and format implied by the
//   value of the TNF field.
// - Middle and terminating record chunks MUST NOT have an ID field.

public enum NDEF {}
