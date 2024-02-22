//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import Foundation

/// Specifies the time signature of a project.
enum TimeSignature: String, Codable, CaseIterable, Identifiable {
    /// Unique identifier.
    var id: String {
        self.rawValue
    }
    
    case ts34, ts44, ts54
    
    /// First digit of the time signature.
    var firstDigit: Int {
        switch self {
        case .ts34:
            3
        case .ts44:
            4
        case .ts54:
            5
        }
    }
    
    /// Second digit of the time signature.
    var secondDigit: Int {
        4
    }
    
    /// String representation for displaying.
    var stringRepresentation: String {
        switch self {
        case .ts34:
            "3/4"
        case .ts44:
            "4/4"
        case .ts54:
            "5/4"
        }
    }
}
