//
//  Node.swift
//
//
//  Created by Jakub Florek on 11/11/2023.
//

import Foundation
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers
import SceneKit
import SwiftUI

/// Type of the transform.
enum TransformType: String, CaseIterable, Codable {
    case move, orbit, spiral, random
    
    /// Name displayed in the interface of the transform type.
    var displayName: String {
        switch self {
        case .move:
            "Move"
        case .orbit:
            "Orbit"
        case .spiral:
            "Spiral"
        case .random:
            "Random"
        }
    }
    
    /// Name of the icon associated with the transform type.
    var iconName: String {
        switch self {
        case .move:
            "move.3d"
        case .orbit:
            "globe.europe.africa"
        case .spiral:
            "tornado"
        case .random:
            "die.face.5"
        }
    }
    
    /// Description associated with the transform type.
    var displayDescription: String {
        switch self {
        case .move:
            """
            This transform moves the node to the specified coordinates.
            """
        case .orbit:
            """
            This transform moves the node circularly around the origin.
            """
        case .spiral:
            """
            This transform moves the node circularly around the origin, towards the end point, with smaller radius over time.
            """
        case .random:
            """
            This transform moves the node to random points within the specified cube radius.
            """
        }
    }
    
    var parameterDescription: LocalizedStringKey {
        switch self {
        case .move:
            """
            - **x**, **y**, **z** - Destination point components
            - **Interpolate** - Indicate whether to linearly interpolate between source and destination
            """
        case .orbit:
            """
            - **h** - Base height of the node
            - **r** - Radius of the orbit
            - **rev** - Number of revolutions
            - **hMod** - Height modulation
            """
        case .spiral:
            """
            - **hStart** - Starting height of the node
            - **hEnd** - Finish height of the node
            - **rev** - Number of revolutions
            - **rBase** - Initial radius of a revolution
            """
        case .random:
            """
            - **r** - Radius of the cube
            - **freq** - How many times should transform randomly change the node's position
            """
        }
    }
}

/// Swift Data representation of a transform.
@Model
class TransformModel {
    /// Unique identifier.
    var id: UUID
    /// Start displacment of the transfer on the display.
    var start: Double
    /// On screen length of the transform.
    var length: Double
    /// Type of the transform.
    var type: TransformType
    /// Numeric properties of the transform.
    var doubleFields: [ String: Double ]
    /// Boolean properties of the transform.
    var booleanFields: [ String: Bool ]
    
    /// Creates a new Swift Data representation of the transform with given properties.
    init(id: UUID = UUID(), start: Double, length: Double, type: TransformType, doubleFields: [String: Double], booleanFields: [String: Bool]) {
        self.id = id
        self.start = start
        self.length = length
        self.type = type
        self.doubleFields = doubleFields
        self.booleanFields = booleanFields
    }
    
    /// Creates a new Swift Data representation of the transform from the given transfer representation.
    init(transfer: TransformTransfer) {
        self.id = transfer.id
        self.start = transfer.start
        self.length = transfer.length
        self.type = transfer.type
        self.doubleFields = transfer.doubleFields
        self.booleanFields = transfer.booleanFields
    }
    
    /// Final position of the node after the transform.
    var endPosition: SCNVector3 {
        switch type {
        case .move:
            SCNVector3(doubleFields["x"] ?? 0, doubleFields["y"] ?? 0, doubleFields["z"] ?? 0)
        case .orbit:
            SCNVector3(0, doubleFields["height"] ?? 0, 0)
        case .spiral:
            SCNVector3(0, doubleFields["hEnd"] ?? 0, 0)
        case .random:
            SCNVector3(0, (doubleFields["radius"] ?? 0) / 2, 0)
        }
    }
    
    /// Default transforms for given type.
    static func defaultModel(for type: TransformType) -> TransformModel {
        var doubleFields: [ String: Double ] = [:]
        var booleanFields: [ String: Bool ] = [:]
        
        switch type {
        case .move:
            doubleFields = ["x": 20, "y": 20, "z": 20]
            booleanFields = ["interp": true]
        case .orbit:
            doubleFields = ["height": 30, "radius": 25, "rev": 1, "hMod": 0]
        case .spiral:
            doubleFields = ["hStart": 10, "hEnd": 40, "rev": 3, "rBase": 40]
        case .random:
            doubleFields = ["radius": 30, "frequency": 6]
        }
        
        return TransformModel(start: 0, length: Constants.fullBeatWidth * 4, type: type, doubleFields: doubleFields, booleanFields: booleanFields)
    }
    
    /// Returns position at specific offset adjusted by this transform.
    func getPositionFor(playheadOffset offset: Double, currentPosition: SCNVector3, source: SCNVector3, mockT: Float? = nil) -> SCNVector3 {
        var t: Float
        
        if let mockT {
            t = mockT
        } else {
            t = Float((offset - start) / length)
        }
        
        switch type {
        case .move:
            let destination = SCNVector3(doubleFields["x"] ?? 0, doubleFields["y"] ?? 0, doubleFields["z"] ?? 0)
            
            if !(booleanFields["interp"] ?? false) {
                return destination
            }
            
            return SCNVector3(x: (1 - t) * source.x + t * destination.x,
                              y: (1 - t) * source.y + t * destination.y,
                              z: (1 - t) * source.z + t * destination.z)
        case .orbit:
            let radius: Float = Float(doubleFields["radius"] ?? 0)
            let heigth: Float = Float(doubleFields["height"] ?? 0)
            let numberOfRevolutions: Float = Float(doubleFields["rev"] ?? 1)
            let heightModulation: Float = Float(doubleFields["hMod"] ?? 0)
            
            return SCNVector3(x: cos(numberOfRevolutions * t * 2 * .pi - .pi / 2) * radius,
                              y: heigth + sin(t * 10 * .pi - .pi / 2) * heightModulation,
                              z: sin(numberOfRevolutions * t * 2 * .pi - .pi / 2) * radius)
        case .spiral:
            let tComp = 1 - t
            let startHeight: Float = Float(doubleFields["hStart"] ?? 0)
            let endHeight: Float = Float(doubleFields["hEnd"] ?? 0)
            let numberOfRevolutions: Float = Float(doubleFields["rev"] ?? 1)
            let baseRadius: Float = Float(doubleFields["rBase"] ?? 0)
            
            return SCNVector3(x: cos(numberOfRevolutions * t * 2 * .pi - .pi / 2) * baseRadius * tComp,
                              y: startHeight + (endHeight - startHeight) * t,
                              z: sin(numberOfRevolutions * t * 2 * .pi - .pi / 2) * baseRadius * tComp)
        case .random:
            let frequency = doubleFields["frequency"] ?? 1
            let radius: Float = Float(doubleFields["radius"] ?? 0)
            
            let periodLength = length / frequency
            
            let remainder = offset.truncatingRemainder(dividingBy: periodLength)
            
            if remainder <= 1.5 && remainder >= 0.2 {
                var result = SCNVector3(x: Float.random(in: -radius...radius), y: Float.random(in: 0...(radius / 2)), z: Float.random(in: -radius...radius))
                
                while simd_distance(simd_float3(result), simd_float3(SCNVector3(0, 4.5, 0))) < 8 {
                    result = SCNVector3(x: Float.random(in: -radius...radius), y: Float.random(in: 0...(radius / 2)), z: Float.random(in: -radius...radius))
                }
                
                return result
            } else {
                return currentPosition
            }
        }
    }
}

/// Transferable representation of a transform.
struct TransformTransfer: Codable, Transferable {
    /// Unique identifier.
    var id: UUID
    /// Start displacment of the transfer on the display.
    var start: Double
    /// On screen length of the transform.
    var length: Double
    /// Type of the transform.
    var type: TransformType
    /// Numeric properties of the transform.
    var doubleFields: [ String: Double ]
    /// Boolean properties of the transform.
    var booleanFields: [ String: Bool ]
    
    /// Creates a new transfer from a model.
    init(model: TransformModel) {
        id = model.id
        start = model.start
        length = model.length
        type = model.type
        doubleFields = model.doubleFields
        booleanFields = model.booleanFields
    }
    
    /// Transfer representation.
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .content)
    }
}
