//
//  File.swift
//  
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI
import SwiftData

/// Speaker node represented in the editor.
@Model
class Node: Identifiable {
    /// Unique identifier.
    var id = UUID()
    /// Position in the timeline left bar.
    var position: Int
    /// Name of the speaker node.
    var name: String
    /// Gain of the speaker.
    var volume: Double = 1
    /// Determines whether the speaker should play.
    var isPlaying = true
    /// Determines whether the speaker should play solo.
    var isSolo = false
    
    /// Audio files associated with the speaker node.
    var tracks = [Track]()
    /// Position transforms associated with the speaker node.
    var transforms = [TransformModel]()
    /// Color encoded.
    var colorData: Data?
    
    /// UIColor of the speaker node.
    var uiColor: UIColor? {
        get {
            colorData.flatMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: $0) }
        }
        set(value) {
            colorData = value.flatMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
        }
    }
    
    /// SwiftUI color of the speaker node.
    var color: Color {
        get {
            uiColor.flatMap { Color($0) } ?? .green
        }
        set(value) {
            uiColor = UIColor(value)
        }
    }
    
    /// Initializes a new speaker node.
    init(position: Int, name: String, color: UIColor) {
        self.position = position
        self.name = name
        self.colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
}
