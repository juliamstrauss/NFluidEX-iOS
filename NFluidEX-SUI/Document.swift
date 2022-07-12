//
//  Document.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/30/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct Document : FileDocument {
    
    static var readableContentTypes: [UTType] {[.plainText]}
    var message: String
    
    init(message: String) {
        self.message = message
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents, let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
    
}
