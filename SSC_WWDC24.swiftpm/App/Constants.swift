//
//  Constants.swift
//  PHASing
//
//  Created by Jakub Florek on 10/12/2023.
//

import Foundation

/// Constants commonly used in the app.
class Constants {
    /// Speaker node timeline row height.
    static let nodeViewHeight: Double = 120
    /// Full beat width.
    static let fullBeatWidth: Double = 60
    /// Full vertical beat marker width.
    static let fullBeatMarkerWidth: Double = 10
    
    /// Spaces between beat dependant on time signature.
    static func beatSpacingFor(timeSingature: TimeSignature) -> Double {
        (fullBeatWidth - fullBeatMarkerWidth) / distanceMultiplierFor(timeSignature: timeSingature)
    }
    
    /// Beat marker width adjusted for time signature.
    static func beatMarkerWidthFor(timeSignature: TimeSignature) -> Double {
        fullBeatMarkerWidth / distanceMultiplierFor(timeSignature: timeSignature)
    }
    
    /// Distance multiplier for time signature.
    static func distanceMultiplierFor(timeSignature: TimeSignature) -> Double {
        Double(timeSignature.secondDigit / 4)
    }
    
    /// Number of beats for maximum track length and time signature
    static func getNumberOfBeatsFor(_ x: Double, with timeSignature: TimeSignature) -> Int {
        var result = Int(x / fullBeatWidth + 10 + Double(timeSignature.firstDigit))
        result -= result % timeSignature.firstDigit
        return result * Int(distanceMultiplierFor(timeSignature: timeSignature))
    }
    
    /// Display width for track adjusted for bpm
    static func trackWidth(_ track: Track, bpm: Int) -> Double {
        Double(bpm) * (track.trackLength / 60) * fullBeatWidth
    }
}
