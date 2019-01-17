//
//  DataExtensions.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 10/01/2019.
//

import Foundation
import CommonCrypto

extension Data {
    
    static func random(count: Int) throws -> Data {
        var generatedBytes = [UInt8](repeating: 0, count: count)
        let result = SecRandomCopyBytes(kSecRandomDefault, generatedBytes.count, &generatedBytes)
        guard result == errSecSuccess else { throw NSError(domain: "SecRandomCopyBytes", code: Int(exactly: result) ?? 0, userInfo: nil) }
        return Data(generatedBytes)
    }
    
}

public extension SecKey {
    
    func getData() throws -> Data {
        if #available(iOS 10.0, *) {
            var error: Unmanaged<CFError>? = nil
            let data = SecKeyCopyExternalRepresentation(self, &error)
            guard let unwrappedData = data as Data? else {
                throw error?.takeRetainedValue() ?? NSError(domain: "SecKeyCopyExternalRepresentation", code: 0, userInfo: nil)
            }
            return unwrappedData
        } else {
            // On iOS 9, we have to export key data through keychain
            let temporaryTag = UUID().uuidString
            let addParams: [CFString: Any] = [
                kSecValueRef: self,
                kSecReturnData: true,
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: temporaryTag
            ]
            
            var data: AnyObject?
            let addStatus = SecItemAdd(addParams as CFDictionary, &data)
            guard let unwrappedData = data as? Data else {
                throw NSError(domain: "SecItemAdd", code: Int(exactly: addStatus) ?? 0, userInfo: nil)
            }
            
            let deleteParams: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: temporaryTag
            ]
            
            _ = SecItemDelete(deleteParams as CFDictionary)
            
            return unwrappedData
        }
    }
    
    static func makeRSAPublicKey(from data: Data) throws -> SecKey {
        if #available(iOS 10.0, *) {
            let attributes: [CFString: Any] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                               kSecAttrKeyClass: kSecAttrKeyClassPublic,
                                               kSecAttrKeySizeInBits: 2048]
            
            var error: Unmanaged<CFError>? = nil
            guard let publicKey = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
                throw error?.takeRetainedValue() ?? NSError(domain: "SecKeyCreateWithData", code: 0, userInfo: nil)
            }
            return publicKey
        }
        else {
            // On iOS 9, we have to import key data through keychain
            // https://stackoverflow.com/questions/38097824/retrieve-seckey-from-nsdata
            let temporaryTag = UUID().uuidString
            let addParams: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecValueData: data,
                kSecAttrApplicationTag: temporaryTag,
                kSecReturnPersistentRef: true
            ]
            
            let addStatus = SecItemAdd(addParams as CFDictionary, nil)
            guard addStatus == noErr else {
                throw NSError(domain: "SecItemAdd", code: Int(exactly: addStatus) ?? 0, userInfo: nil)
            }
            
            let fetchParams: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: temporaryTag,
                kSecReturnRef: true
            ]
            
            var object: AnyObject?
            let fetchStatus = SecItemCopyMatching(fetchParams as CFDictionary, &object)
            guard fetchStatus == noErr, let secKey = object else {
                throw NSError(domain: "SecItemCopyMatching", code: Int(exactly: fetchStatus) ?? 0, userInfo: nil)
            }
            
            let deleteParams: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: temporaryTag
            ]
            
            _ = SecItemDelete(deleteParams as CFDictionary)
            
            return secKey as! SecKey
        }
    }
    
}
