//
//  LinkBuilder.swift
//  VKarmaneSDK_Example
//
//  Created by a.kulabukhov on 13/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import VKarmaneSDK

final class LinkBuilder {
    
    static func buildUrl(source: String, kinds: [DocumentKind], publicKey: String, isMultichoice: Bool) throws -> URL {
        return try VKarmaneSDK.GetDocumentsLinkBuilder(xSource: source,
                                                       xSuccessLink: Const.xSuccessLink,
                                                       xErrorLink: Const.xErrorLink,
                                                       xCancelLink: Const.xCancelLink,
                                                       kinds: kinds,
                                                       publicKey: publicKey,
                                                       isMultichoice: isMultichoice)
                                                       .build()
    }
    
}
