//
//  EntryDetailView.swift
//  Doku
//
//  Created by Ege Çam on 13.07.2024.
//

import SwiftUI

struct EntryDetailView: View {
    let entry: DokuEntry
    
    var body: some View {
        Text(entry.title)
    }
}
