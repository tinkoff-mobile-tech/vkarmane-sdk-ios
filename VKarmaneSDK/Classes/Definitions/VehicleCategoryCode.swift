//
//  VehicleCategoryCode.swift
//  VKarmaneSDK
//
//  Created by a.maksakov on 26/10/2018.
//

import Foundation

enum VehicleCategoryCode: Int {
    case a = 0
    case b = 1
    case c = 2
    case d = 3
    case trailer = 4
    case unknown
    
    static func fromInt(value: Int) -> VehicleCategoryCode {
        return self.init(rawValue: value) ?? .unknown
    }
}
