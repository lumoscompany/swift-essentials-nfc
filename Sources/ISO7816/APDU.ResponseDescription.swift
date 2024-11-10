//
//  Created by Adam Stragner
//

// MARK: - ISO7816.APDU.WellKnownResponseDescription

public extension ISO7816.APDU {
    struct WellKnownResponseDescription {
        public enum Level {
            case `default`
            case info
            case warning
            case error
        }

        public let level: Level
        public let text: String
    }
}

// MARK: - ISO7816.APDU.WellKnownResponseDescription + CustomStringConvertible

extension ISO7816.APDU.WellKnownResponseDescription: CustomStringConvertible {
    public var description: String {
        text
    }
}

public extension ISO7816.APDU.Response {
    var wellKnownDescription: ISO7816.APDU.WellKnownResponseDescription? {
        let words = [statusWord1, statusWord2].hexadecimalString.capitalized

        let pattern = "(\(words[0])|-)(\(words[1])|-)(\(words[2])|-)(\(words[3])|-) (E|I|W|U) (.+)"
        guard let regex = try? Regex(pattern)
        else {
            return nil
        }

        var matches = _status_words.matches(of: regex)
        guard !matches.isEmpty
        else {
            return nil
        }

        matches.sort(by: { lhs, rhs in
            let _lhs = _status_words[lhs.range]
            let _rhs = _status_words[rhs.range]
            return _lhs.components(separatedBy: "-").count < _rhs.components(separatedBy: "-").count
        })

        guard let match = matches.first,
              let levelRange = match[5].range,
              let messageRange = match[6].range
        else {
            return nil
        }

        let message = String(_status_words[messageRange])
        return switch _status_words[levelRange] {
        case "E": .init(level: .error, text: message)
        case "I": .init(level: .info, text: message)
        case "U": .init(level: .info, text: message)
        case "W": .init(level: .warning, text: message)
        default: .init(level: .default, text: message)
        }
    }
}

private let _status_words = """
06-- E Class not supported.
61-- I Response bytes still available.
61-- I Command successfully executed; __XX bytes of data are available and can be requested using GET RESPONSE.
62-- W State of non-volatile memory unchanged.
6200 W No information given (NV-RAM not changed).
6201 W NV-Ram not changed 1.
6281 W Part of returned data may be corrupted.
6282 W End of file/record reached before reading Le bytes.
6283 W Selected file invalidated.
6284 W Selected file is not valid. FCI not formated according to ISO.
6285 W No input data available from a sensor on the card. No Purse Engine enslaved for R3BC.
62A2 W Wrong R-MAC.
62A4 W Card locked (during reset).
62C- W Counter with value ___X (command dependent).
62F1 W Wrong C-MAC.
62F3 W Internal reset.
62F5 W Default agent locked.
62F7 W Cardholder locked.
62F8 W Basement is current agent.
62F9 W CALC Key Set not unblocked.
62-- W RFU.
63-- W State of non-volatile memory changed.
6300 W No information given (NV-RAM changed).
6381 W File filled up by the last write. Loading/updating is not allowed.
6382 W Card key not supported.
6383 W Reader key not supported.
6384 W Plaintext transmission not supported.
6385 W Secured transmission not supported.
6386 W Volatile memory is not available.
6387 W Non-volatile memory is not available.
6388 W Key number not valid.
6389 W Key length is not correct.
63C0 W Verify fail, no try left.
63C1 W Verify fail, 1 try left.
63C2 W Verify fail, 2 tries left.
63C3 W Verify fail, 3 tries left.
63C- W The counter has reached the value ___X (0 = x = 15) (command dependent).
63F1 W More data expected.
63F2 W More data expected and proactive command pending.
63-- W RFU.
64-- E State of non-volatile memory unchanged.
6400 E No information given (NV-RAM not changed).
6401 E Command timeout. Immediate response required by the card.
64-- E RFU.
65-- E State of non-volatile memory changed.
6500 E No information given.
6501 E Write error. Memory failure. There have been problems in writing or reading the EEPROM. Other hardware problems may also bring this error.
6581 E Memory failure.
65-- E RFU.
6600 E Error while receiving (timeout).
6601 E Error while receiving (character parity error).
6602 E Wrong checksum.
6603 E The current DF file without FCI.
6604 E No SF or KF under the current DF.
6669 E Incorrect Encryption/Decryption Padding.
6700 E Wrong length.
67-- E length incorrect (procedure)(ISO 7816-3)
68-- E Functions in CLA not supported.
6800 E No information given (the request function is not supported by the card).
6881 E Logical channel not supported.
6882 E Secure messaging not supported.
6883 E Last command of the chain expected.
6884 E Command chaining not supported.
68-- E RFU.
69-- E Command not allowed.
6900 E No information given (command not allowed).
6901 E Command not accepted (inactive state).
6981 E Command incompatible with file structure.
6982 E Security condition not satisfied.
6983 E Authentication method blocked.
6984 E Referenced data reversibly blocked (invalidated).
6985 E Conditions of use not satisfied.
6986 E Command not allowed (no current EF).
6987 E Expected secure messaging (SM) object missing.
6988 E Incorrect secure messaging (SM) data object.
698D U Reserved.
6996 E Data must be updated again.
69E1 E POL1 of the currently Enabled Profile prevents this action.
69F0 E Permission Denied.
69F1 E Permission Denied - Missing Privilege.
69-- E RFU.
6A-- E Wrong parameter(s) P1-P2.
6A00 E No information given (Bytes P1 and/or P2 are incorrect).
6A80 E The parameters in the data field are incorrect.
6A81 E Function not supported.
6A82 E File not found.
6A83 E Record not found.
6A84 E There is insufficient memory space in record or file.
6A85 E Lc inconsistent with TLV structure.
6A86 E Incorrect P1 or P2 parameter.
6A87 E Lc inconsistent with P1-P2.
6A88 E Referenced data not found.
6A89 E File already exists.
6A8A E DF name already exists.
6AF0 E Wrong parameter value.
6A-- E RFU.
6B00 E Wrong parameter(s) P1-P2
6B-- E Reference incorrect (procedure byte), (ISO 7816-3).
6C-- E Wrong length Le.
6C00 E Incorrect P3 length.
6C-- E Bad length value in Le; __XX is the correct exact Le.
6D00 E Instruction code not supported or invalid.
6D-- E Instruction code not programmed or invalid (procedure byte), (ISO 7816-3).
6E00 E Class not supported.
6E-- E Instruction class not supported (procedure byte), (ISO 7816-3).
6F-- E Internal exception.
6F00 E Command aborted - more exact diagnosis not possible (e.g., operating system error).
6FFF E Card dead (overuse, ...).
6F-- E No precise diagnosis (procedure byte), (ISO 7816-3).
9000 I Command successfully executed (OK).
9004 W PIN not succesfully verified, 3 or more PIN tries left.
9008 U Key/file not found.
9080 W Unblock Try Counter has reached zero.
9100 U OK.
9101 U States.activity, States.lock Status or States.lockable has wrong value.
9102 U Transaction number reached its limit.
910C U No changes.
910E U Insufficient NV-Memory to complete command.
911C U Command code not supported.
911E U CRC or MAC does not match data.
9140 U Invalid key number specified.
917E U Length of command string invalid.
919D U Not allow the requested command.
919E U Value of the parameter invalid.
91A0 U Requested AID not present on PICC.
91A1 U Unrecoverable error within application.
91AE U Authentication status does not allow the requested command.
91AF U Additional data frame is expected to be sent.
91BE U Out of boundary.
91C1 U Unrecoverable error within PICC.
91CA U Previous Command was not fully completed.
91CD U PICC was disabled by an unrecoverable error.
91CE U Number of Applications limited to 28.
91DE U File or application already exists.
91EE U Could not complete NV-write operation due to loss of power.
91F0 U Specified file number does not exist.
91F1 U Unrecoverable error within file.
920- I Writing to EEPROM successful after ___X attempts.
9210 E Insufficient memory. No more storage available.
9240 E Writing to EEPROM not successful.
9301 U Integrity error.
9302 U Candidate S2 invalid.
9303 E Application is permanently locked.
9400 E No EF selected.
9401 U Candidate currency code does not match purse currency.
9402 U Candidate amount too high.
9402 E Address range exceeded.
9403 U Candidate amount too low.
9404 E FID not found, record not found or comparison pattern not found.
9405 U Problems in the data field.
9406 E Required MAC unavailable.
9407 U Bad currency : purse engine has no slot with R3bc currency.
9408 U R3bc currency not supported in purse engine.
9408 E Selected file type does not match command.
9580 U Bad sequence.
9681 U Slave not found.
9700 U PIN blocked and Unblock Try Counter is 1 or 2
9702 U Main keys are blocked.
9704 U PIN not succesfully verified, 3 or more PIN tries left.
9784 U Base key.
9785 U Limit exceeded - C-MAC key.
9786 U SM error - Limit exceeded - R-MAC key.
9787 U Limit exceeded - sequence counter.
9788 U Limit exceeded - R-MAC length.
9789 U Service not available.
9802 E No PIN defined.
9804 E Access conditions not satisfied, authentication failed.
9835 E ASK RANDOM or GIVE RANDOM not executed.
9840 E PIN verification not successful.
9850 E INCREASE or DECREASE could not be executed because a limit has been reached.
9862 E Authentication Error, application specific (incorrect MAC).
9900 U 1 PIN try left.
9904 U PIN not succesfully verified, 1 PIN try left.
9985 U Wrong status - Cardholder lock.
9986 E Missing privilege.
9987 U PIN is not installed.
9988 U Wrong status - R-MAC state.
9A00 U 2 PIN try left.
9A04 U PIN not succesfully verified, 2 PIN try left.
9A71 U Wrong parameter value - Double agent AID.
9A72 U Wrong parameter value - Double agent Type.
9D05 E Incorrect certificate type.
9D07 E Incorrect session data size.
9D08 E Incorrect DIR file record size.
9D09 E Incorrect FCI record size.
9D0A E Incorrect code size.
9D10 E Insufficient memory to load application.
9D11 E Invalid AID.
9D12 E Duplicate AID.
9D13 E Application previously loaded.
9D14 E Application history list full.
9D15 E Application not open.
9D17 E Invalid offset.
9D18 E Application already loaded.
9D19 E Invalid certificate.
9D1A E Invalid signature.
9D1B E Invalid KTU.
9D1D E MSM controls not set.
9D1E E Application signature does not exist.
9D1F E KTU does not exist.
9D20 E Application not loaded.
9D21 E Invalid Open command data length.
9D30 E Check data parameter is incorrect (invalid start address)
9D31 E Check data parameter is incorrect (invalid length)
9D32 E Check data parameter is incorrect (illegal memory check area)
9D40 E Invalid MSM Controls ciphertext.
9D41 E MSM controls already set.
9D42 E Set MSM Controls data length less than 2 bytes.
9D43 E Invalid MSM Controls data length.
9D44 E Excess MSM Controls ciphertext.
9D45 E Verification of MSM Controls data failed.
9D50 E Invalid MCD Issuer production ID.
9D51 E Invalid MCD Issuer ID.
9D52 E Invalid set MSM controls data date.
9D53 E Invalid MCD number.
9D54 E Reserved field error.
9D55 E Reserved field error.
9D56 E Reserved field error.
9D57 E Reserved field error.
9D60 E MAC verification failed.
9D61 E Maximum number of unblocks reached.
9D62 E Card was not blocked.
9D63 E Crypto functions not available.
9D64 E No application loaded.
9E00 U PIN not installed.
9E04 U PIN not succesfully verified, PIN not installed.
9F00 U PIN blocked and Unblock Try Counter is 3.
9F04 U PIN not succesfully verified, PIN blocked and Unblock Try Counter is 3.
9F-- U Command successfully executed; __XX bytes of data are available and can be requested using GET RESPONSE.
9--- U Application related status, (ISO 7816-3).
"""
