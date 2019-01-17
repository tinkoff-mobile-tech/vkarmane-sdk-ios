//
//  Const.swift
//  VKarmaneSDK_Example
//
//  Created by a.kulabukhov on 13/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

enum Const {
    static let urlScheme = "vkarmanesdkexample"
    static let successPath = "documents_success"
    static let errorPath = "documents_error"
    static let cancelPath = "documents_cancel"
    
    static let xSuccessLink = "\(urlScheme)://\(successPath)"
    static let xErrorLink = "\(urlScheme)://\(errorPath)"
    static let xCancelLink = "\(urlScheme)://\(cancelPath)"
}
