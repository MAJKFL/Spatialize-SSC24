//
//  Project.swift
//  PHASing
//
//  Created by Jakub Florek on 11/11/2023.
//

import Foundation
import SwiftData

/// Represents the project and it's settings.
@Model
class Project: Identifiable {
    /// Unique identifier.
    var id = UUID()
    /// Name of the project..
    var name: String
    /// Date when the project was created.
    var dateCreated = Date()
    /// BPM of the project.
    var bpm = 80
    /// Time signature of the project.
    var timeSignature = TimeSignature.ts44
    
    /// Nodes associated with the project.
    var nodes = [Node]()
    
    /// Creates a new empty project with specified name.
    init(name: String) {
        self.name = name
    }
}
