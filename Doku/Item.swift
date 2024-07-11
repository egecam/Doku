//
//  Item.swift
//  Doku
//
//  Created by Ege Çam on 11.07.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
