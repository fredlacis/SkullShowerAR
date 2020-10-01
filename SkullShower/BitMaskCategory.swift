//
//  BitMaskCategory.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 29/09/20.
//

import Foundation

public class BitMaskCategory {
    static var character:Int = 1//0x1 << 0
    static var rainDrop:Int = 2//0x1 << 1
    static var plane:Int = 4//0x1 << 2
    static var all:Int = Int.max
    static func allBut(_ categories:Int...)->Int {
        return categories.reduce(Self.all, { a, b in a-b})
    }
}
