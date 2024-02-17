//
//  TimelineGenerator.swift
//
//
//  Created by Jakub Florek on 16/02/2024.
//

import SwiftUI

/// Used for generating timeline components.
class TimelineGenerator {
    
    /// Generates timeline for given parameters.
    static func generateTimeline(numberOfBeats: Int, timeSignature: TimeSignature, imageHeight: Double) async -> UIImage? {
        let imageSize = CGSize(width: Double((numberOfBeats - timeSignature.firstDigit)) * (Constants.beatMarkerWidthFor(timeSignature: timeSignature) + Constants.beatSpacingFor(timeSingature: timeSignature)), height: imageHeight)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }

        context.setAlpha(1.0)
        context.setLineWidth(1)
        
        for i in 0...(numberOfBeats - timeSignature.firstDigit) {
            let x = Double(i) * (Constants.beatMarkerWidthFor(timeSignature: timeSignature) + Constants.beatSpacingFor(timeSingature: timeSignature))
            
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: imageSize.height))

            context.setStrokeColor(UIColor.secondarySystemFill.withAlphaComponent(i % timeSignature.firstDigit == 0 ? 1 : 0.3).cgColor)
            context.strokePath()
        }
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()
        return result
    }
    
    /// Generates timeline labels for given parameters.
    static func generateTimelineLabels(numberOfBeats: Int, timeSignature: TimeSignature, imageHeight: Double) async -> UIImage? {
        let imageSize = CGSize(width: Double((numberOfBeats - timeSignature.firstDigit)) * (Constants.beatMarkerWidthFor(timeSignature: timeSignature) + Constants.beatSpacingFor(timeSingature: timeSignature)), height: imageHeight)
        
        let drawingRect = CGRect(origin: .zero, size: imageSize)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }

        context.setAlpha(1.0)
        context.setLineWidth(1)
        
        let midY = drawingRect.height / 4
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let font = UIFont.systemFont(ofSize: 15)
        
        for i in 0...(numberOfBeats - 1 - timeSignature.firstDigit) {
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.label.withAlphaComponent(i % timeSignature.firstDigit == 0 ? 0.7 : 0.3),
                .paragraphStyle: paragraphStyle
            ]
            
            let labelText = getBeatStr(i + timeSignature.firstDigit, timeSignature: timeSignature)
            
            let x = Double(i) * (Constants.beatMarkerWidthFor(timeSignature: timeSignature) + Constants.beatSpacingFor(timeSingature: timeSignature) - 0.09)
        
            (labelText as NSString).draw(at: CGPoint(x: x, y: midY), withAttributes: textAttributes)
        }
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        UIGraphicsEndImageContext()
        return result
    }
    
    /// Returns the string representation of the beat number.
    private static func getBeatStr(_ x: Int, timeSignature: TimeSignature) -> String {
        return String(x / timeSignature.firstDigit) + "." + String(x % timeSignature.firstDigit + 1)
    }
}
