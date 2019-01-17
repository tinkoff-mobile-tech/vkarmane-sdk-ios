//
//  VKarmaneSDKError.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 13/09/2018.
//

import Foundation

public enum VKarmaneSDKError: Int, Error {
    case unsupportedVersion = 1
    case unknownAction = 2
    case badXCallbackParameters = 3
    case badActionParameters = 4
    case internalError = 5
    case unauthorized = 6
    case cryptographyError = 7
}
