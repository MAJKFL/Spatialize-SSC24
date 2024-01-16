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
        
        return TransformModel(start: 0, length: 200, type: type, doubleFields: doubleFields, booleanFields: booleanFields)
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
