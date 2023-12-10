//
//  Constants.swift
//  PHASing
//
//  Created by Jakub Florek on 10/12/2023.
//

import Foundation

class Constants {
    static let fullBeatWidth: Double = 100
    static let fullBeatMarkerWidth: Double = 10
    
    static func beatSpacing(forTimeSingature timeSingature: TimeSignature) -> Double {
        (fullBeatWidth - fullBeatMarkerWidth) / distanceMultiplier(forTimeSingature: timeSingature)
    }
    
    static func beatMarkerWidth(forTimeSingature timeSingature: TimeSignature) -> Double {
        fullBeatMarkerWidth / distanceMultiplier(forTimeSingature: timeSingature)
    }
    
    static func singleBeatWidth(forTimeSingature timeSignature: TimeSignature) -> Double {
        timeSignature.secondDigit == 4 ? fullBeatWidth : fullBeatWidth / 2
    }
    
    static func distanceMultiplier(forTimeSingature timeSignature: TimeSignature) -> Double {
        Double(timeSignature.secondDigit / 4)
    }
    
    static func timelineLeadingPadding(forTimeSingature timeSignature: TimeSignature) -> Double {
        timeSignature.secondDigit == 4 ? 0 : 2
    }
    
    static func getNumberOfBeatsFor(_ x: Double, with timeSignature: TimeSignature) -> Int {
        var result = Int(x / fullBeatWidth + 10 + Double(timeSignature.firstDigit))
        result -= result % timeSignature.firstDigit
        return result * Int(distanceMultiplier(forTimeSingature: timeSignature))
    }
    
    static func trackWidth(_ track: Track, bpm: Int) -> Double {
        Double(bpm) * (track.trackLength / 60) * fullBeatWidth
    }
}
