//
//  RSA.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 10/01/2019.
//

import Foundation
import CommonCrypto

public enum RSA {
    
    public struct KeyPair {
        public let privateKey: SecKey
        public let publicKey: SecKey
    }
    
    public enum Error: Swift.Error {
        case cryptoFailed(status: OSStatus)
        case keyCreationFailed(status: OSStatus)
    }
    
    public static func makeKeyPair() throws -> KeyPair {
        let attributes: [CFString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                           kSecAttrKeySizeInBits: 2048]
        if #available(iOS 10.0, *) {
            var error: Unmanaged<CFError>?
            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
                let errorToThrow: Swift.Error = error?.takeRetainedValue() ?? Error.keyCreationFailed(status: errSecFunctionFailed)
                throw errorToThrow
            }
            guard let publicKey = SecKeyCopyPublicKey(privateKey) else { throw Error.keyCreationFailed(status: errSecFunctionFailed) }
            return KeyPair(privateKey: privateKey, publicKey: publicKey)
        } else {
            var _privateKey: SecKey?, _publicKey: SecKey?
            let result = SecKeyGeneratePair(attributes as CFDictionary, &_publicKey, &_privateKey)
            guard result == errSecSuccess, let privateKey = _privateKey, let publicKey = _publicKey else { throw Error.keyCreationFailed(status: result) }
            return KeyPair(privateKey: privateKey, publicKey: publicKey)
        }
    }
    
    public static func encrypt(_ data: Data, publicKey: SecKey) throws -> Data {
        let blockSize = SecKeyGetBlockSize(publicKey)
        
        // When PKCS1 padding is performed, the maximum length of data that can be encrypted is 11 bytes less than the value returned by the SecKeyGetBlockSize(_:) function (secKeyGetBlockSize() - 11).
        // https://developer.apple.com/documentation/security/1617956-seckeyencrypt
        let maxChunkSize = blockSize - 11
        
        let decryptedDataAsArray = [UInt8](data)
        
        var encryptedData = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while idx < decryptedDataAsArray.count {
            var idxEnd = idx + maxChunkSize
            if idxEnd > decryptedDataAsArray.count {
                idxEnd = decryptedDataAsArray.count
            }
            var chunkData = [UInt8](repeating: 0, count: maxChunkSize)
            for i in idx..<idxEnd {
                chunkData[i-idx] = decryptedDataAsArray[i]
            }
            
            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize
            
            let status = SecKeyEncrypt(publicKey, .PKCS1, chunkData, idxEnd-idx, &encryptedDataBuffer, &encryptedDataLength)
            if status != noErr { throw Error.cryptoFailed(status: status) }
            encryptedData += encryptedDataBuffer
            
            idx += maxChunkSize
        }
        return Data(encryptedData)
    }
    
    public static func decrypt(_ data: Data, privateKey: SecKey) throws -> Data {
        let blockSize = SecKeyGetBlockSize(privateKey)
        
        let encryptedDataAsArray = [UInt8](data)
        
        var decryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while idx < encryptedDataAsArray.count {
            
            let idxEnd = min(idx + blockSize, encryptedDataAsArray.count)
            let chunkData = [UInt8](encryptedDataAsArray[idx..<idxEnd])
            
            var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var decryptedDataLength = blockSize
            
            let status = SecKeyDecrypt(privateKey, .PKCS1, chunkData, idxEnd-idx, &decryptedDataBuffer, &decryptedDataLength)
            guard status == noErr else { throw Error.cryptoFailed(status: status) }
            
            decryptedDataBytes += [UInt8](decryptedDataBuffer[0..<decryptedDataLength])
            
            idx += blockSize
        }
        
        return Data(decryptedDataBytes)
    }
    
}
