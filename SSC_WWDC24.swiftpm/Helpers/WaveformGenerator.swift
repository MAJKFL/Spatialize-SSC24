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
    private static func generateWaveImage(
        _ audioUrl: URL,
        _ imageSize: CGSize,
        _ strokeColor: UIColor
    ) async -> UIImage? {
        let file = try! AVAudioFile(forReading: audioUrl)
        
        let audioFormat = file.processingFormat
        let audioFrameCount = UInt32(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
        else { return nil }
        do {
            try file.read(into: buffer)
        } catch {
            print(error)
        }

        let samples = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
        
        let drawingRect = CGRect(origin: .zero, size: imageSize)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        let middleY = imageSize.height / 2

        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(UIColor.clear.cgColor)
        context.setAlpha(1.0)
        context.fill(drawingRect)
        context.setLineWidth(1.5)

        let max: CGFloat = CGFloat(samples.max() ?? 0)
        let heightNormalizationFactor = imageSize.height / max / 2.5
        let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
        for index in stride(from: 0, through: samples.count, by: 50) {
            let pixel = CGFloat(samples[index]) * heightNormalizationFactor

            let x = CGFloat(index) * widthNormalizationFactor

            context.move(to: CGPoint(x: x, y: middleY - pixel))
            context.addLine(to: CGPoint(x: x, y: middleY + pixel))

            context.setStrokeColor(strokeColor.cgColor)
            context.strokePath()
        }
        
        context.move(to: CGPoint(x: 0, y: middleY))
        context.addLine(to: CGPoint(x: imageSize.width, y: middleY))
        
        context.setStrokeColor(strokeColor.cgColor)
        context.strokePath()
        
        guard let soundWaveImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()
        return soundWaveImage
    }

    /// Generates a waveform image for specified URL.
    static func generateWaveImage(from audioUrl: URL) async -> UIImage? {
        return await generateWaveImage(audioUrl, CGSize(width: getDuration(audioUrl) * Constants.fullBeatMarkerWidth * 10, height: 100), UIColor.white)
    }
}
