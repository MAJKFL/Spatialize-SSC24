//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI
import AVFoundation
import SceneKit

/// Represents audio files and transforms associated with a node on the timeline.
struct NodeTimelineView: View {
    /// Swift Data context.
    @Environment(\.modelContext) var context
    
    /// Current project.
    @Bindable var project: Project
    /// Node represented by this timeline.
    @Bindable var node: Node
    
    /// Transform the user is currently editing size.
    @Binding var selectedTransform: TransformModel?
    
    var body: some View {
        ZStack {
            Color.secondary
                .opacity(0.05)
                .dropDestination(for: TimelineDropItem.self) { items, location in
                    guard let item = items.first else { return false }
                    
                    switch item {
                    case .audio(let audio):
                        handleFileDrop(audio.file, at: location)
                    case .transform(let transform):
                        handleTransformDrop(transform, at: location)
                    default:
                        return false
                    }
                    
                    return true
                }
            
            VStack {
                Spacer()
                    .frame(height: Constants.nodeViewHeight * 0.4)
                
                Color.secondary
                    .opacity(0.1)
                    .frame(height: 1)
                
                Spacer()
                    .frame(height: Constants.nodeViewHeight * 0.6)
            }
            
            VStack(spacing: -3) {
                ZStack {
                    ForEach(node.transforms) { transformModel in
                        HStack {
                            TransformTimelineView(project: project, node: node, transformModel: transformModel, selectedTransform: $selectedTransform)
                                .offset(x: transformModel.start)
                            
                            
                            Spacer()
                        }
                    }
                }
                .frame(height: Constants.nodeViewHeight * 0.4)
                .zIndex(1)
                
                ZStack {
                    ForEach(node.tracks) { track in
                        HStack {
                            TrackTimelineView(project: project, node: node, track: track)
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
                .frame(height: Constants.nodeViewHeight * 0.6)
            }
        }
    }
    
    /// Used for changing position and creating transforms.
    private func handleTransformDrop(_ transfer: TransformTransfer, at location: CGPoint) {
        let transform = TransformModel(transfer: transfer)
        
        if let otherNode = project.nodes.first(where: { $0.transforms.contains(where: { $0.id == transform.id }) }),
           let originalTransform = otherNode.transforms.first(where: { $0.id == transfer.id }) {
            context.delete(originalTransform)
            
            otherNode.transforms.removeAll(where: { $0.id == transform.id })
        }
        
        transform.start = location.x - location.x.truncatingRemainder(dividingBy: Constants.fullBeatWidth / 4)
        node.transforms.append(transform)
        node.transforms.sort(by: { $0.start > $1.start })
        
        selectedTransform = transform
    }
    
    /// Used for importing audio files and rearranging them.
    private func handleFileDrop(_ url: URL, at location: CGPoint) {
        if let otherNode = project.nodes.first(where: { $0.tracks.contains(where: { $0.fileURL == url }) }),
           let otherTrack = otherNode.tracks.first(where: { $0.fileURL == url }) {
            otherNode.tracks.removeAll(where: { $0.id == otherTrack.id })
            otherTrack.start = location.x - location.x.truncatingRemainder(dividingBy: Constants.fullBeatWidth / 4)
            
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
                              start: location.x - location.x.truncatingRemainder(dividingBy: Constants.fullBeatWidth / 4))
            
            node.tracks.append(track)
        }
    }
}

enum TimelineDropItem: Transferable {
    case none
    case transform(TransformTransfer)
    case audio(AudioFile)
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { TimelineDropItem.audio($0) }
        ProxyRepresentation { TimelineDropItem.transform($0) }
    }
}
