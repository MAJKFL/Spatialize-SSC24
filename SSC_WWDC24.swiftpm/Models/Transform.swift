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

protocol Transform {
    var id: UUID { get set }
    var start: Double { get set }
    var finish: Double { get set }
    
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
}

@Model
class TransformModel: Transform {
    var id: UUID
    var start: Double
    var finish: Double
    
    var type: TransformType
    var doubleFields: [ String: Double ]
    var booleanFields: [ String: Bool ]
    
    init(id: UUID = UUID(), start: Double, finish: Double, type: TransformType, doubleFields: [String: Double], booleanFields: [String: Bool]) {
        self.id = id
        self.start = start
        self.finish = finish
        self.type = type
        self.doubleFields = doubleFields
        self.booleanFields = booleanFields
    }
    
    var length: Double {
        finish - start
    }
    
    static func defaultModel(for type: TransformType) -> TransformModel {
        var doubleFields: [ String: Double ] = [:]
        var booleanFields: [ String: Bool ] = [:]
        
        switch type {
        case .move:
            doubleFields = ["x": 0, "y": 0, "z": 0]
            booleanFields = ["interp": false]
        case .orbit:
            doubleFields = ["height": 0, "radius": 0]
        }
        
        return TransformModel(start: 0, finish: 200, type: type, doubleFields: doubleFields, booleanFields: booleanFields)
    }
}

struct TransformTransfer: Transform, Codable, Transferable {
    var id: UUID
    var start: Double
    var finish: Double
    var type: TransformType
    var doubleFields: [ String: Double ]
    var booleanFields: [ String: Bool ]
    
    init(model: TransformModel) {
        id = model.id
        start = model.start
        finish = model.finish
        type = model.type
        doubleFields = model.doubleFields
        booleanFields = model.booleanFields
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .content)
    }
}
