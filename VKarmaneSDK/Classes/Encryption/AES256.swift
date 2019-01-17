//
//  AES256.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 10/01/2019.
//

import Foundation
import CommonCrypto

public enum AES256 {
    
    public enum Error: Swift.Error {
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }
    
    public static func makeKey() throws -> Data {
        return try .random(count: kCCKeySizeAES256)
    }
    
    public static func archive(_ data: Data, key: Data) throws -> Data {
        // https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Initialization_vector_.28IV.29
        // IV usually does not need to be secret but
        // it is important that an initialization vector is never reused under the same key
        let iv: Data = try .random(count: kCCBlockSizeAES128)
        let encryptedData = try encrypt(data, key: key, iv: iv)
        return iv + encryptedData
    }
    
    public static func unarchive(_ data: Data, key: Data) throws -> Data {
        guard data.count > kCCBlockSizeAES128 else { throw Error.badInputVectorLength }
        let iv = data.prefix(kCCBlockSizeAES128)
        let encryptedData = data.suffix(from: kCCBlockSizeAES128)
        return try decrypt(encryptedData, key: key, iv: iv)
    }
    
    public static func encrypt(_ data: Data, key: Data, iv: Data) throws -> Data {
        try validate(key: key, iv: iv)
        return try crypt(data, key: key, iv: iv, operation: CCOperation(kCCEncrypt))
    }
    
    public static func decrypt(_ data: Data, key: Data, iv: Data) throws -> Data {
        try validate(key: key, iv: iv)
        return try crypt(data, key: key, iv: iv, operation: CCOperation(kCCDecrypt))
    }
    
    private static func crypt(_ data: Data, key: Data, iv: Data, operation: CCOperation) throws -> Data {
        let dataBytes = [UInt8](data)
        let ivBytes = [UInt8](iv)
        let keyBytes = [UInt8](key)
        
        let cryptLength = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128).count
        var cryptBytes = [UInt8](repeating: 0, count: cryptLength)
        var bytesLength = 0
        
        let status = CCCrypt(operation,
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             keyBytes, key.count,
                             ivBytes,
                             dataBytes, data.count,
                             &cryptBytes, cryptLength,
                             &bytesLength)
        
        guard status == kCCSuccess else { throw Error.cryptoFailed(status: status) }
        
        cryptBytes.removeSubrange(bytesLength..<cryptBytes.count)
        return Data(cryptBytes)
    }
    
    private static func validate(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256 else { throw Error.badKeyLength }
        guard iv.count == kCCBlockSizeAES128 else { throw Error.badInputVectorLength }
    }
    
}
