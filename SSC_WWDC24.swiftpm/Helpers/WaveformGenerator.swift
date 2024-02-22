//
//  WaveformGenerator.swift
//  PHASing
//
//  Created by Jakub Florek on 12/11/2023.
//

import UIKit
import AVFoundation

extension AVAudioFile{
    /// Duration in seconds.
    var duration: Double {
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }
}

/// Generates waveform images for audio files.
class WaveGenerator {
    /// Returns audio file duration for the file at specified URL.
    private static func getDuration(_ audioUrl: URL) -> Double {
        let file = try! AVAudioFile(forReading: audioUrl)
        
        return file.duration
    }
    
    /// Generates waveform image for given parameters.
    private static func generateWaveImage(audioUrl: URL, imageSize: CGSize) async -> UIImage? {
        guard let file = try? AVAudioFile(forReading: audioUrl),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: UInt32(file.length)) 
              else { return nil }
        
        do {
            try file.read(into: buffer)
        } catch {
            print(error)
            return nil
        }

        let samples = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
        
        let rect = CGRect(origin: .zero, size: imageSize)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        let midY = imageSize.height / 2

        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }

        context.setAlpha(1.0)
        context.setLineWidth(1.5)

        let max: CGFloat = CGFloat(samples.max() ?? 0)
        let heightNormalizationFactor = imageSize.height / max / 2.5
        let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
        
        for index in stride(from: 0, through: samples.count, by: 50) {
            let pixel = CGFloat(samples[index]) * heightNormalizationFactor

            let x = CGFloat(index) * widthNormalizationFactor

            context.move(to: CGPoint(x: x, y: midY - pixel))
            context.addLine(to: CGPoint(x: x, y: midY + pixel))

            context.setStrokeColor(UIColor.white.cgColor)
            context.strokePath()
        }
        
        context.move(to: CGPoint(x: 0, y: midY))
        context.addLine(to: CGPoint(x: imageSize.width, y: midY))
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()
        
        return result
    }

    /// Generates a waveform image for specified URL.
    static func generateWaveImage(from audioUrl: URL) async -> UIImage? {
        return await generateWaveImage(audioUrl: audioUrl, imageSize: CGSize(width: getDuration(audioUrl) * Constants.fullBeatMarkerWidth * 10, height: 100))
    }
}
