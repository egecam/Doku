//
//  LoadingScreen.swift
//  Doku
//
//  Created by Ege Çam on 22.07.2024.
//

import SwiftUI

@ViewBuilder
public func LoadingScreen() -> some View {
    ZStack {
        Rectangle()
            .fill(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        
        ProgressView()
            .background(.background, in: .rect(cornerRadius: 5))
            .frame(width: 45, height: 45)
    }
    .frame(width: 100, height: 100)
}
