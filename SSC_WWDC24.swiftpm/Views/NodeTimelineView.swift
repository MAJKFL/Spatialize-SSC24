//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI
import AVFoundation

struct NodeTimelineView: View {
    @Bindable var project: Project
    @Bindable var node: Node
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.05)
                .frame(height: 60)
                .dropDestination(for: AudioFile.self) { items, location in
                    guard let item = items.first else { return false }
                    
                    handleFileDrop(item.file, at: location)
                    
                    return true
                }
            
            ForEach(node.tracks) { track in
                HStack {
                    WaveformAsyncImage(project: project, node: node, track: track)
                        .offset(x: track.start)
                        .draggable(AudioFile(file: track.fileURL)) {
                            Image(systemName: "waveform")
                                .foregroundStyle(Color.white)
                                .font(.largeTitle)
                                .padding()
                                .background {
                                    node.color.opacity(0.8)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    
                    
                    Spacer()
                }
            }
        }
    }
    
    func handleFileDrop(_ url: URL, at location: CGPoint) {
        if let otherNode = project.nodes.first(where: { $0.tracks.contains(where: { $0.fileURL == url }) }),
           let otherTrack = otherNode.tracks.first(where: { $0.fileURL == url }) {
            otherNode.tracks.removeAll(where: { $0.id == otherTrack.id })
            otherTrack.start = location.x - location.x.truncatingRemainder(dividingBy: 25)
            
            node.tracks.append(otherTrack)
        } else {
            let id = UUID()
            
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: id.uuidString).appendingPathExtension(url.pathExtension)
            
            try! FileManager.default.copyItem(at: url, to: directory)
            
            let audioFile = try! AVAudioFile(forReading: directory)
            
            let track = Track(id: id,
                              fileName: url.deletingPathExtension().lastPathComponent,
                              ext: url.pathExtension,
                              trackLength: audioFile.duration,
                              start: location.x - location.x.truncatingRemainder(dividingBy: 25))
            
            node.tracks.append(track)
        }
    }
}
