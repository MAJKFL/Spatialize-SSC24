//
//  AudioFile.swift
//
//
//  Created by Jakub Florek on 24/11/2023.
//

import Foundation
import CoreTransferable

/// Used for importing audio files.
struct AudioFile: Transferable {
    /// File URL.
    let file: URL
    
    /// Transfer representation of the file.
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .audio) {
            SentTransferredFile($0.file)
        } importing: { received in
            let destination = try Self.copyVideoFile(source: received.file)
            return Self.init(file: destination)
        }
    }
  
    /// Copies file to the document directory.
    static func copyVideoFile(source: URL) throws -> URL {
        let audioDirectory = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )
        var destination = audioDirectory.appendingPathComponent(
            source.lastPathComponent, isDirectory: false)
        if FileManager.default.fileExists(atPath: destination.path) {
            let pathExtension = destination.pathExtension
            let fileName = destination.deletingPathExtension().lastPathComponent
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
