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
    
    var initX = Float.random(in: -5 ..< 5)
    var initY = Float.random(in: 1 ..< 5)
    var initZ = Float.random(in: -5 ..< 5)
    
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
    
    var initLocation: SCNVector3 {
        SCNVector3(x: initX, y: initY, z: initZ)
    }
    
    init(position: Int, name: String, color: UIColor) {
        self.position = position
        self.name = name
        self.colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
}

extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
