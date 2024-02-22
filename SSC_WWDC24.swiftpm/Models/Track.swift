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

/// Represents an audio file associated with a speaker node.
@Model
class Track: Identifiable {
    /// Unique identifier.
    var id = UUID()
    /// File name of the file.
    var fileName: String
    /// Extension of the file.
    var ext: String
    /// Start offset of the track. Uses the display units.
    var start: Double = 0
    /// File length in seconds.
    var trackLength: Double = 0
    
    /// Creates a new track with specified parameters.
    init(id: UUID = UUID(), fileName: String, ext: String, trackLength: Double = 0, start: Double = 0) {
        self.id = id
        self.fileName = fileName
        self.ext = ext
        self.trackLength = trackLength
        self.start = start
    }
    
    /// Reference to the audio file the track represents.
    var fileURL: URL {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: id.uuidString)
            .appendingPathExtension(ext)
    }
}
