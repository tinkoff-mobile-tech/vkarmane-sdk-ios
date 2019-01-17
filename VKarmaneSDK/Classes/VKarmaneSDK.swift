//
//  VKarmaneSDK.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 13/09/2018.
//

import Foundation

public enum VKarmaneSDK {
    
    static public var isAppInstalled: Bool {
        guard isAppSupportsScheme(scheme: Const.vkarmaneAppScheme) else {
            fatalError("Для работы с SDK добавьте \(Const.vkarmaneAppScheme) в \(Const.queriesSchemesKey) вашего Info.plist")
        }
        let url = URL(scheme: Const.vkarmaneAppScheme)!
        return UIApplication.shared.canOpenURL(url)
    }
    
    fileprivate static func isAppSupportsScheme(scheme: String) -> Bool {
        guard
            let dictionary = Bundle.main.infoDictionary,
            let schemes = (dictionary[Const.queriesSchemesKey] as? [String])?.map({ $0.lowercased() }),
            schemes.contains(scheme)
            else { return false }
        return true
    }
    
    internal static func makeError(_ text: String, code: Int = 1) -> Error {
        return NSError(domain: String(describing: type(of: self)),
                       code: code,
                       userInfo: [NSLocalizedDescriptionKey: text])
    }
    
}

fileprivate extension URL {
    init?(scheme: String) {
        var components = URLComponents()
        components.scheme = scheme
        guard let url = components.url else { return nil }
        self = url
    }
}
