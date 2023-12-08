//
//  File.swift
//  
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI
import SwiftData

@Model
class Node: Identifiable {
    var id = UUID()
    var position: Int
    var name: String
    var volume: Double = 1
    var isPlaying = true
    var tracks = [Track]()
    var transforms = [Transform]()
    private var colorData: Data?
    
    private var uiColor: UIColor? {
        get {
            colorData.flatMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: $0) }
        }
        set(value) {
            colorData = value.flatMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
        }
    }
    
    var color: Color {
        get {
            uiColor.flatMap { Color($0) } ?? .green
        }
        set(value) {
            uiColor = UIColor(value)
        }
    }
    
    
    init(position: Int, name: String, color: UIColor) {
        self.position = position
        self.name = name
        self.colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
}
