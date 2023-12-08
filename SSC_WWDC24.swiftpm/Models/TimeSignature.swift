//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import Foundation

enum TimeSignature: String, Codable, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case ts34, ts44, ts54, ts68, ts78
    
    var firstDigit: Int {
        switch self {
        case .ts34:
            3
        case .ts44:
            4
        case .ts54:
            5
        case .ts68:
            6
        case .ts78:
            7
        }
    }
    
    var secondDigit: Int {
        switch self {
        case .ts34:
            4
        case .ts44:
            4
        case .ts54:
            4
        case .ts68:
            8
        case .ts78:
            8
        }
    }
    
    var stringRepresentation: String {
        switch self {
        case .ts34:
            "3/4"
        case .ts44:
            "4/4"
        case .ts54:
            "5/4"
        case .ts68:
            "6/8"
        case .ts78:
            "7/8"
        }
    }
}
