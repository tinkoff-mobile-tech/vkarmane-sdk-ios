//
//  RusDriverCategory.swift
//  VKarmaneSDK
//
//  Created by a.maksakov on 26/10/2018.
//

import Foundation

enum RusDriverCategory: Int {
    
    case a = 0
    case b = 1
    case c = 2
    case d = 3
    case be = 4
    case ce = 5
    case de = 6
    case tm = 7
    case tb = 8
    case a1 = 9
    case b1 = 10
    case c1 = 11
    case d1 = 12
    case c1e = 13
    case d1e = 14
    case am = 16
    case unknown
    
    static func fromInt(value: Int) -> RusDriverCategory {
        return self.init(rawValue: value) ?? .unknown
    }
}
