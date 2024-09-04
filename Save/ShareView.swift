//
//  ShareView.swift
//  Save
//
//  Created by Ege Çam on 21.07.2024.
//

import SwiftUI
import UniformTypeIdentifiers
import os.log

struct ShareView: View {
    @State private var isLoading: Bool = false
    @State private var title: String = ""
    @State private var tags: String = ""
    let url: URL?
    let text: String?
    let contentType: ContentType
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var saveAction: (URL?, String?, String, [String], ContentType) -> Void
    var cancelAction: () -> Void
    
    init(url: URL?, text: String?, contentType: ContentType, saveAction: @escaping (URL?, String?, String, [String], ContentType) -> Void, cancelAction: @escaping () -> Void) {
        self.url = url
        self.text = text
        self.contentType = contentType
        self.saveAction = saveAction
        self.cancelAction = cancelAction
        
        // Suggest initial title and tags based on content type
        _title = State(initialValue: suggestInitialTitle())
        _tags = State(initialValue: suggestInitialTags())
    }
    
    
    private let logger = Logger()
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.alabaster.ignoresSafeArea() : Color.jet
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                HStack {
                    Spacer()

                    Text("Save to Doku")
                        .font(.vollkorn(size: 26, weight: 500))
                        .padding(.top)
                    
                    Spacer()
                    
                    Button(action: cancelAction) {
                        Text("Cancel")
                            .foregroundStyle(.auburn)
                    }
                    .padding()
                }
                
                
                VStack(alignment: .leading) {
                    
                    switch contentType {
                    case .article, .tweet:
                        if let url = url {
                            Text("URL: \(url.absoluteString)")
                        }
                    case .passage:
                        if let text = text {
                            Text("Passage: \(text.prefix(100))...")
                        }
                    case .unknown:
                        Text("Unknown content type")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.0)
                            .stroke(colorScheme == .light ? .gray.opacity(0.2) : .davysGray, lineWidth: 3)
                            .fill(.outerSpace.opacity(0.4))
                            .frame(height: 50)
                        
                        TextField(text: $title) {
                            Text("Title")
                        }
                        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
                        .padding(13)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.0)
                            .stroke(colorScheme == .light ? .gray.opacity(0.2) : .davysGray, lineWidth: 3)
                            .fill(.outerSpace.opacity(0.4))
                            .frame(height: 50)
                        
                        TextField(text: $tags) {
                            Text("Tags (comma-separated)")
                        }
                        .foregroundStyle(colorScheme == .light ? .jet : .alabaster)
                        .padding(13)
                    }
                    
                }
                .padding()
                
                
                Button {
                    saveContent()
                } label: {
                    Text("Save")
                        .font(.raleway(size: 22, weight: 600))
                        .foregroundStyle(.asparagus)
                        .frame(width: 250, height: 50)
                }
                .background(.celadon)
                .cornerRadius(12.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(.asparagus, lineWidth: 3)
                )
                .padding()
                
            }
            .font(.literata(size: 18, weight: 400))
            .foregroundStyle(colorScheme == .light ? Color.jet : Color.alabaster)
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
    }
    
    private func saveContent() {
        isLoading = true
        
        let processedTags = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        saveAction(url, text, title, processedTags, contentType)

        // logger.log("Attempting to save entry: \(title), URL: \(url.absoluteString), Content Type: \(contentType.rawValue), Tags: \(processedTags.joined(separator: ", "))")
        
        isLoading = false
        presentationMode.wrappedValue.dismiss()
    }
    
    private func suggestInitialTitle() -> String {
        switch contentType {
        case .article:
            return url?.lastPathComponent ?? "New Article"
        case .tweet:
            guard let username = url?.path.split(separator: "/").first.map(String.init) else {
                return "a user"
            }
            
            return "Tweet by \(String(describing: username))"
        case .passage:
            return "New Passage"
        case .unknown:
            return "New Entry"
        }
    }
    
    private func suggestInitialTags() -> String {
        switch contentType {
        case .article:
            return "article, read-later"
        case .tweet:
            return "tweet, social-media"
        case .passage:
            return "passage, notes"
        case .unknown:
            return ""
        }
    }
    
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
}
