//
//  VKarmaneSDK+GetDocumentsLinkBuilder.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 13/09/2018.
//

import Foundation

public extension VKarmaneSDK {
    
    public struct GetDocumentsLinkBuilder {
        public let xSource: String
        public let xSuccessLink: String
        public let xErrorLink: String
        public let xCancelLink: String
        public let kinds: [DocumentKind]
        public let publicKey: String
        public let isMultichoice: Bool?
        
        public init(xSource: String, xSuccessLink: String, xErrorLink: String, xCancelLink: String, kinds: [DocumentKind], publicKey: String, isMultichoice: Bool? = nil) {
            self.xSource = xSource
            self.xSuccessLink = xSuccessLink
            self.xErrorLink = xErrorLink
            self.xCancelLink = xCancelLink
            self.kinds = kinds
            self.publicKey = publicKey
            self.isMultichoice = isMultichoice
        }
        
        public func build() throws -> URL {
            try validate()
            guard !kinds.isEmpty else { throw GetDocumentsLinkBuilderError.kindsIsEmpty }
            let url = makeURL()
            return url
        }
        
        private func makeURL() -> URL {
            var components = URLComponents()
            components.scheme = Const.vkarmaneAppScheme
            components.host = Const.host
            components.path = "/\(Const.protocolVersion)/\(Const.actionName)"
            var parameters = [Const.kindsParamName: kinds.map { $0.rawValue }.joined(separator: ","),
                              Const.publicKeyParamName: publicKey,
                              Const.xSourceKey: xSource,
                              Const.xSuccessKey: xSuccessLink,
                              Const.xErrorKey: xErrorLink,
                              Const.xCancelKey: xCancelLink]
            isMultichoice.flatMap { parameters[Const.isMultichoiceParamName] = String($0) }
            
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            
            return components.url!
        }
        
        private func validate() throws {
            let xSuccessUrl = try validateLink(xSuccessLink, type: Const.xSuccessKey)
            let xErrorUrl = try validateLink(xErrorLink, type: Const.xErrorKey)
            let xCancelUrl = try validateLink(xCancelLink, type: Const.xCancelKey)
            
            let allSchemes = [xSuccessUrl, xErrorUrl, xCancelUrl].compactMap { $0.scheme }
            let uniqueSchemes = Set(allSchemes)
            
            guard uniqueSchemes.count < 2 else { throw GetDocumentsLinkBuilderError.differentSchemes }
            guard let scheme = uniqueSchemes.first else { throw GetDocumentsLinkBuilderError.emptySchemes }
            
            let appSchemes = getHostAppRegisteredSchemes().map { $0.lowercased() }
            
            guard appSchemes.contains(scheme) else { throw GetDocumentsLinkBuilderError.schemeIsNotRegistered(scheme, appSchemes: appSchemes) }
            
        }
        
        @discardableResult
        private func validateLink(_ link: String, type: String) throws -> URL {
            guard let url = URL(string: link) else { throw GetDocumentsLinkBuilderError.malformedURL(link, type: type) }
            return url
        }
        
        private func makeError(_ text: String) -> Error {
            return VKarmaneSDK.makeError(text)
        }
        
        private func getHostAppRegisteredSchemes() -> [String] {
            guard let urlTypes = Bundle.main.infoDictionary?[Const.urlTypesKey] as? [[String: Any]] else { return [] }
            return urlTypes.flatMap { $0[Const.urlSchemesKey] as! [String] }
        }
 
    }
    
}

extension VKarmaneSDK {
    
    public enum GetDocumentsLinkBuilderError: LocalizedError {
        case kindsIsEmpty
        case malformedURL(String, type: String)
        case emptySchemes
        case differentSchemes
        case schemeIsNotRegistered(String, appSchemes: [String])
        
        public var errorDescription: String? {
            switch self {
            case .kindsIsEmpty: return "Не указаны типы документов для заполнения - kinds"
            case .malformedURL(let url, let type): return "Ссылка для \(type) имеет невалидный формат - \(url)"
            case .emptySchemes: return "Указанные ссылки не содержат url-схем"
            case .differentSchemes: return "Указанные ссылки содержат разные url-схемы"
            case .schemeIsNotRegistered(let scheme, let appSchemes): return "Схема \(scheme) не зарегистрирована в вашем приложении. Зарегистрированы: \(appSchemes)"
            }
        }
        
    }
    
}
