//
//  VKarmaneSDK+Parsing.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 14/09/2018.
//

import Foundation

public extension VKarmaneSDK {
    
    public static func makeKeys() throws -> RSA.KeyPair {
        return try RSA.makeKeyPair()
    }
    
    public static func getJsonFromLink(_ url: URL, privateKey: SecKey) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw makeError("Невалидный URL: \(url)")
        }
        
        guard
            let encryptedData = Data(base64Encoded: try getQueryItemValue(forKey: Const.dataKey, in: components)),
            let encryptedSessionKey = Data(base64Encoded: try getQueryItemValue(forKey: Const.sessionKeyKey, in: components))
            else {
                throw makeError("Данные получены в неверном формате")
            }
        
        let data = try decryptData(encryptedData, with: encryptedSessionKey, privateKey: privateKey)
        guard isValidJSON(data), let string = String(data: data, encoding: .utf8) else { throw makeError("Данные получены в неверном формате") }
        
        return string
    }
    
    public static func getErrorFromLink(_ url: URL) -> VKarmaneSDKError {
        return parseErrorFromLink(url) ?? .internalError
    }
    
    private static func getQueryItemValue(forKey key: String, in components: URLComponents) throws -> String {
        guard let value = components.queryItems?[key] else {
            throw parseErrorFromComponents(components) ?? makeError("Не найден обязательный параметр \(key)")
        }
        return value
    }
    
    private static func parseErrorFromLink(_ url: URL) -> VKarmaneSDKError? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        return parseErrorFromComponents(components)
    }
    
    private static func parseErrorFromComponents(_ components: URLComponents) -> VKarmaneSDKError? {
        guard let errorCode = components.queryItems?[Const.codeKey].flatMap({ Int($0) }) else { return nil }
        return VKarmaneSDKError(rawValue: errorCode)
    }
    
    private static func decryptData(_ encryptedData: Data, with encryptedSessionKey: Data, privateKey: SecKey) throws -> Data {
        do {
            let sessionKey = try RSA.decrypt(encryptedSessionKey, privateKey: privateKey)
            return try AES256.unarchive(encryptedData, key: sessionKey)
        }
        catch {
            throw VKarmaneSDKError.cryptographyError
        }
    }
    
    private static func isValidJSON(_ data: Data) -> Bool {
        return (try? JSONSerialization.jsonObject(with: data, options: [])) != nil
    }
    
}

fileprivate extension Array where Element == URLQueryItem {
    subscript(key: String) -> String? {
        return first(where: { $0.name.caseInsensitiveCompare(key) == .orderedSame })?.value
    }
}
