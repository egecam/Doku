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
    let image: UIImage?
    let text: String?
    let contentType: ContentType
    @Environment(\.presentationMode) var presentationMode
    
    var saveAction: (URL?, UIImage?, String?, String, [String], ContentType) -> Void
    
    init(url: URL?, image: UIImage?, text: String?, contentType: ContentType, saveAction: @escaping (URL?, UIImage?, String?, String, [String], ContentType) -> Void) {
        self.url = url
        self.image = image
        self.text = text
        self.contentType = contentType
        self.saveAction = saveAction
        
        // Suggest initial title and tags based on content type
        _title = State(initialValue: suggestInitialTitle())
        _tags = State(initialValue: suggestInitialTags())
    }
    
    
    private let logger = Logger()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Save to Doku")) {
                    TextField("Title", text: $title)
                    TextField("Tags (comma-separated)", text: $tags)
                    
                    switch contentType {
                    case .article, .tweet:
                        if let url = url {
                            Text("URL: \(url.absoluteString)")
                        }
                    case .passage:
                        if let text = text {
                            Text("Passage: \(text.prefix(100))...")
                        }
                    case .image:
                        if image != nil {
                            Text("Image will be saved")
                        }
                    case .unknown:
                        Text("Unknown content type")
                    }
                }
                
                Button("Save") {
                    logger.log("Save button pressed")
                    saveContent()
                }
            }
            .overlay {
                if isLoading {
                    LoadingScreen()
                }
            }
            .navigationTitle("Save to Doku")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveContent() {
        isLoading = true
        
        let processedTags = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        saveAction(url, image, text, title, processedTags, contentType)

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
        case .image:
            return "Image"
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
        case .image:
            return "image, visual"
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
