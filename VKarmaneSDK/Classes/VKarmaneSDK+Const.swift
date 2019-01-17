//
//  VKarmaneSDK+Const.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 13/09/2018.
//

import Foundation

extension VKarmaneSDK {
    
    enum Const {
        static let vkarmaneAppScheme = "vkarmaneapp"
        static let protocolVersion = "v3"
        
        static let queriesSchemesKey = "LSApplicationQueriesSchemes"
        static let urlTypesKey = "CFBundleURLTypes"
        static let urlSchemesKey = "CFBundleURLSchemes"
        
        static let actionName = "get_documents"
        static let kindsParamName = "kinds"
        static let publicKeyParamName = "publicKey"
        static let isMultichoiceParamName = "isMultichoice"
        static let xSourceKey = "x-source"
        static let xSuccessKey = "x-success"
        static let xErrorKey = "x-error"
        static let xCancelKey = "x-cancel"
        
        static let host = "x-callback-url"
        
        static let dataKey = "data"
        static let sessionKeyKey = "sessionKey"
        static let codeKey = "code"
    }
    
}
