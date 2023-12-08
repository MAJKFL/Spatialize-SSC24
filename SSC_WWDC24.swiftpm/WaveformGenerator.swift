//
//  WaveformGenerator.swift
//  PHASing
//
//  Created by Jakub Florek on 12/11/2023.
//

import UIKit
import AVFoundation

extension AVAudioFile{
    var duration: Double {
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }
}

class WaveGenerator {
    static func getDuration(_ audioUrl: URL) -> Double {
        let file = try! AVAudioFile(forReading: audioUrl)
        
        return file.duration
    }
    
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

//        let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
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
        let heightNormalizationFactor = imageSize.height / max
        let widthNormalizationFactor = imageSize.width / CGFloat(samples.count)
        for index in stride(from: 100, through: samples.count, by: 100) {
            let subrange = samples[(index - 100)...index]
            let average: Float = subrange.reduce(0.0) { return $0 + $1/Float(subrange.count) }
            
            let pixel = CGFloat(average) * heightNormalizationFactor

            let x = CGFloat(index) * widthNormalizationFactor

            context.move(to: CGPoint(x: x, y: middleY - pixel))
            context.addLine(to: CGPoint(x: x, y: middleY + pixel))

            context.setStrokeColor(strokeColor.cgColor)
            context.strokePath()
        }
        guard let soundWaveImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }

        UIGraphicsEndImageContext()
        return soundWaveImage
    }

    static func generateWaveImage(from audioUrl: URL) async -> UIImage? {
        return await generateWaveImage(audioUrl, CGSize(width: getDuration(audioUrl) * 100, height: 100), UIColor.white)
    }
}
