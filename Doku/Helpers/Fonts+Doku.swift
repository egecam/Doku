//
//  Fonts+Doku.swift
//  Doku
//
//  Created by Ege Çam on 9.08.2024.
//

import Foundation
import SwiftUI
import VFont

extension Font {
    static func vollkorn(
        size: CGFloat,
        width: CGFloat = 0,
        weight: CGFloat = 0) -> Font {
        return .vFont("Vollkorn", size: size, axes: [
            2003265652: weight
        ])
    }
    
    static func literata(
        size: CGFloat,
        width: CGFloat = 0,
        weight: CGFloat = 0) -> Font {
            return .vFont("Literata", size: size, axes: [
                2003265652: weight
            ])
        }
    
    static func raleway(
        size: CGFloat,
        width: CGFloat = 0,
        weight: CGFloat = 0) -> Font {
            return .vFont("Raleway", size: size, axes: [
                2003265652: weight
            ])
        }
    
    static func inter(
        size: CGFloat,
        width: CGFloat = 0,
        weight: CGFloat = 0) -> Font {
            return .vFont("Inter", size: size, axes: [
                2003265652: weight
            ])
        }
}
