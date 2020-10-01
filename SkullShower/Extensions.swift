//
//  Extensions.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 25/09/20.
//

import Foundation
import CoreGraphics

extension BinaryInteger {
    var deg2rad: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var deg2rad: Self { self * .pi / 180 }
    var rad2deg: Self { self * 180 / .pi }
    
    func map(minRange:Self, maxRange:Self, minDomain:Self, maxDomain:Self) -> Self {
        return minDomain + (maxDomain - minDomain) * (self - minRange) / (maxRange - minRange)
    }
}
