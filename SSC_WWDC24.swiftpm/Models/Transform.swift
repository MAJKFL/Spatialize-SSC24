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

protocol Transform {
    var id: UUID { get set }
    var start: Double { get set }
    var length: Double { get set }
    
    var type: TransformType { get set }
    var doubleFields: [ String: Double ] { get set }
    var booleanFields: [ String: Bool ] { get set }
}

enum TransformType: String, CaseIterable, Codable {
    case move, orbit
    
    var displayName: String {
        switch self {
        case .move:
            "Move"
        case .orbit:
            "Orbit"
        }
    }
    
    var iconName: String {
        switch self {
        case .move:
            "arrow.up.right.circle"
        case .orbit:
            "arrow.clockwise.circle"
        }
    }
    
    var displayDescription: LocalizedStringKey {
        switch self {
        case .move:
            """
            This transform moves the node to the specified coordinates.
            Parameters:
            - **x**, **y**, **z** - Destination point components
            - **Interpolate** - Indicate whether to linearly interpolate between source and destination
            """
        case .orbit:
            """
            This transform moves the node circularly around the origin.
            Parameters:
            - **h** - Base height of the node
            - **r** - Radius of the orbit
            - **rev** - Number of revolutions
            - **hMod** - Height modulation
            """
        }
    }
}

@Model
class TransformModel: Transform {
    var id: UUID
    var start: Double
    var length: Double
    
    var type: TransformType
    var doubleFields: [ String: Double ]
    var booleanFields: [ String: Bool ]
    
    init(id: UUID = UUID(), start: Double, length: Double, type: TransformType, doubleFields: [String: Double], booleanFields: [String: Bool]) {
        self.id = id
        self.start = start
        self.length = length
        self.type = type
        self.doubleFields = doubleFields
        self.booleanFields = booleanFields
    }
    
    init(transfer: TransformTransfer) {
        self.id = transfer.id
        self.start = transfer.start
        self.length = transfer.length
        self.type = transfer.type
        self.doubleFields = transfer.doubleFields
        self.booleanFields = transfer.booleanFields
    }
    
    var endPosition: SCNVector3 {
        switch type {
        case .move:
            SCNVector3(doubleFields["x"] ?? 0, doubleFields["y"] ?? 0, doubleFields["z"] ?? 0)
        case .orbit:
            SCNVector3(0, doubleFields["height"] ?? 0, 0)
        }
    }
    
    static func defaultModel(for type: TransformType) -> TransformModel {
        var doubleFields: [ String: Double ] = [:]
        var booleanFields: [ String: Bool ] = [:]
        
        switch type {
        case .move:
            doubleFields = ["x": 0, "y": 0, "z": 0]
            booleanFields = ["interp": false]
        case .orbit:
            doubleFields = ["height": 0, "radius": 0, "rev": 1, "hMod": 0]
        }
        
        return TransformModel(start: 0, length: Constants.fullBeatWidth * 4, type: type, doubleFields: doubleFields, booleanFields: booleanFields)
    }
    
    func getPositionFor(playheadOffset offset: Double, source: SCNVector3, mockT: Float? = nil) -> SCNVector3 {
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
            
            return SCNVector3(x: (1 - t) * source.x + t * destination.x, y: (1 - t) * source.y + t * destination.y, z: (1 - t) * source.z + t * destination.z)
        case .orbit:
            let radius: Float = Float(doubleFields["radius"] ?? 0)
            let heigth: Float = Float(doubleFields["height"] ?? 0)
            let numberOfRevolutions: Float = Float(doubleFields["rev"] ?? 1)
            let heightModulation: Float = Float(doubleFields["hMod"] ?? 0)
            
            return SCNVector3(x: cos(numberOfRevolutions * t * 2 * .pi - .pi / 2) * radius,
                              y: heigth + sin(t * 10 * .pi - .pi / 2) * heightModulation,
                              z: sin(numberOfRevolutions * t * 2 * .pi - .pi / 2) * radius)
        }
    }
}

struct TransformTransfer: Transform, Codable, Transferable {
    var id: UUID
    var start: Double
    var length: Double
    var type: TransformType
    var doubleFields: [ String: Double ]
    var booleanFields: [ String: Bool ]
    
    init(model: TransformModel) {
        id = model.id
        start = model.start
        length = model.length
        type = model.type
        doubleFields = model.doubleFields
        booleanFields = model.booleanFields
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .content)
    }
}
