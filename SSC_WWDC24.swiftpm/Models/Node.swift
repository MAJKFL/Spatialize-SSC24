//
//  File.swift
//  
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI
import SwiftData
import SceneKit

@Model
class Node: Identifiable {
    var id = UUID()
    var position: Int
    var name: String
    var volume: Double = 1
    var isPlaying = true
    var isSolo = false
    
    var tracks = [Track]()
    var transforms = [TransformModel]()
    var colorData: Data?
    
    var uiColor: UIColor? {
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
    
    var startingPosition: SCNVector3 {
        let x: Float = cos(.pi * Float(position) / 5)
        let z: Float = sin(.pi * Float(position) / 5)
        
        return SCNVector3(x, 13, z)
    }
    
    init(position: Int, name: String, color: UIColor) {
        self.position = position
        self.name = name
        self.colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
}
