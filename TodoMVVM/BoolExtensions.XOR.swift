//
//  BoolExtensions.XOR.swift
//  TodoMVVM
//
//  Created by KODAK on 9/17/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation

infix operator ^^
extension Bool {
    static func ^^(lhs:Bool, rhs:Bool) -> Bool {
        if (lhs && !rhs) || (!lhs && rhs) {
            return true
        }
        return false
    }
}
