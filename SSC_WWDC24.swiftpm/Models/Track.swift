//
//  Track.swift
//
//
//  Created by Jakub Florek on 21/11/2023.
//

import Foundation
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers

@Model
class Track: Identifiable {
    var id = UUID()
    var fileName: String
    var ext: String
    var start: Double = 0
    var trackLength: Double = 0
    
    init(id: UUID = UUID(), fileName: String, ext: String, trackLength: Double = 0, start: Double = 0) {
        self.id = id
        self.fileName = fileName
        self.ext = ext
        self.trackLength = trackLength
        self.start = start
    }
    
    var fileURL: URL {        
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: id.uuidString)
            .appendingPathExtension(ext)
    }
}
