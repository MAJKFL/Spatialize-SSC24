//
//  AudioFile.swift
//
//
//  Created by Jakub Florek on 24/11/2023.
//

import Foundation
import CoreTransferable

struct AudioFile: Transferable {
    let file: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .audio) {
            SentTransferredFile($0.file)
        } importing: { received in
            let destination = try Self.copyVideoFile(source: received.file)
            return Self.init(file: destination)
        }
    }
  
    static func copyVideoFile(source: URL) throws -> URL {
        let audioDirectory = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )
        var destination = audioDirectory.appendingPathComponent(
            source.lastPathComponent, isDirectory: false)
        if FileManager.default.fileExists(atPath: destination.path) {
            let pathExtension = destination.pathExtension
            var fileName = destination.deletingPathExtension().lastPathComponent
            destination = destination
                .deletingLastPathComponent()
                .appendingPathComponent(fileName)
                .appendingPathExtension(pathExtension)
        }
        
        do {
            try FileManager.default.copyItem(at: source, to: destination)
        } catch {
            return destination
        }
        
        return destination
    }
}
