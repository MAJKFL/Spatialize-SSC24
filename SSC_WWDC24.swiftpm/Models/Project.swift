//
//  Project.swift
//  PHASing
//
//  Created by Jakub Florek on 11/11/2023.
//

import Foundation
import SwiftData

@Model
class Project: Identifiable {
    var id = UUID()
    var name: String
    var lastEdited: Date
    var bpm = 80
    var timeSignature = TimeSignature.ts44
    var nodes = [Node]()
    
    init(name: String, lastEdited: Date = Date()) {
        self.name = name
        self.lastEdited = lastEdited
    }
}
