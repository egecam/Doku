//
//  EmptyStateView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Text("Your Doku is empty.")
                .font(.title.bold())
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Saved Dokus will be shown here")
                .font(.subheadline)
            
            Text("Share anything on any app with Doku.")
                .font(.headline)
                .padding(.top, 20)
                .multilineTextAlignment(.center)
            
        }
        .padding()
        .frame(alignment: .center)
    }
}

#Preview {
    EmptyStateView()
}
