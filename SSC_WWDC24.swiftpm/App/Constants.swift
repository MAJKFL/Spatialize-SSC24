//
//  Constants.swift
//  PHASing
//
//  Created by Jakub Florek on 10/12/2023.
//

import Foundation

class Constants {
    static let fullBeatWidth: Double = 60
    static let fullBeatMarkerWidth: Double = 10
    
    static func beatSpacingFor(timeSingature: TimeSignature) -> Double {
        (fullBeatWidth - fullBeatMarkerWidth) / distanceMultiplierFor(timeSignature: timeSingature)
    }
    
    static func beatMarkerWidthFor(timeSignature: TimeSignature) -> Double {
        fullBeatMarkerWidth / distanceMultiplierFor(timeSignature: timeSignature)
    }
    
    static func singleBeatWidthFor(timeSignature: TimeSignature) -> Double {
        timeSignature.secondDigit == 4 ? fullBeatWidth : fullBeatWidth / 2
    }
    
    static func distanceMultiplierFor(timeSignature: TimeSignature) -> Double {
        Double(timeSignature.secondDigit / 4)
    }
    
    static func timelineLeadingPaddingFor(timeSignature: TimeSignature) -> Double {
        timeSignature.secondDigit == 4 ? 0 : 2
    }
    
    static func getNumberOfBeatsFor(_ x: Double, with timeSignature: TimeSignature) -> Int {
        var result = Int(x / fullBeatWidth + 10 + Double(timeSignature.firstDigit))
        result -= result % timeSignature.firstDigit
        return result * Int(distanceMultiplierFor(timeSignature: timeSignature))
    }
    
    static func trackWidth(_ track: Track, bpm: Int) -> Double {
        Double(bpm) * (track.trackLength / 60) * fullBeatWidth
    }
}
