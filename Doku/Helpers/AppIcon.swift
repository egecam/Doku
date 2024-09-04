//
//  AppIcon.swift
//  Doku
//
//  Created by Ege Çam on 2.09.2024.
//

import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case `default`
    case coralIcon
    case greenIcon
    
    var name: String? {
        switch self {
        case .default:
            return nil
        case .coralIcon:
            return "CoralAppIcon"
        case .greenIcon:
            return "GreenAppIcon"
        }
    }
    
    var description: String {
        switch self {
        case .default:
            return "Default"
        case .coralIcon:
            return "Coral Doku"
        case .greenIcon:
            return "Archiver"
        }
    }
    
    var icon: Image {
        switch self {
        case .default:
            return Image("AppIcon")
        case .coralIcon:
            return Image("CoralAppIcon")
        case .greenIcon:
            return Image("GreenAppIcon")
        }
    }
}

extension AppIcon {
    init(from name: String) {
        switch name {
        case "CoralAppIcon": self = .coralIcon
        case "GreenAppIcon": self = .greenIcon
        default: self = .default
        }
    }
}
