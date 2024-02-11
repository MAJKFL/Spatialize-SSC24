//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI
import AVFoundation
import SceneKit

struct NodeTimelineView: View {
    @Environment(\.modelContext) var context
    @Bindable var project: Project
    @Bindable var node: Node
    
    @Binding var selectedTransform: TransformModel?
    
    let editTransform: Bool
    
    let updateSpeaker: (ObjectIdentifier, Double) -> ()
    
    var body: some View {
        ZStack {
            if !editTransform {
                Color.secondary
                    .opacity(0.05)
                    .frame(height: Constants.nodeViewHeight)
                    .dropDestination(for: AudioFile.self) { items, location in
                        guard let item = items.first else { return false }
                        
                        handleFileDrop(item.file, at: location)
                        
                        return true
                    }
            }
            
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
                        .disabled(editTransform)
                    
                    Spacer()
                }
            }
            
            if editTransform {
                Color.secondary
                    .opacity(0.05)
                    .frame(height: Constants.nodeViewHeight)
                    .dropDestination(for: TransformTransfer.self) { items, location in
                        guard let item = items.first else { return false }
                        
                        handleTransformDrop(item, at: location)
                        
                        return true
                    }
            }
            
            ForEach(node.transforms) { transformModel in
                HStack {
                    TransformTimelineView(project: project, node: node, transformModel: transformModel, selectedTransform: $selectedTransform, updateSpeaker: updateSpeaker)
                        .offset(x: transformModel.start)
                        .disabled(!editTransform)
                    
                    
                    Spacer()
                }
            }
        }
    }
    
    private func handleTransformDrop(_ transfer: TransformTransfer, at location: CGPoint) {
        let transform = TransformModel(transfer: transfer)
        
        if let otherNode = project.nodes.first(where: { $0.transforms.contains(where: { $0.id == transform.id }) }),
           let originalTransform = otherNode.transforms.first(where: { $0.id == transfer.id }) {
            context.delete(originalTransform)
            
            otherNode.transforms.removeAll(where: { $0.id == transform.id })
            
            updateSpeaker(otherNode.id, originalTransform.start)
        }
        
        transform.start = location.x - location.x.truncatingRemainder(dividingBy: Constants.fullBeatWidth / 4)
        node.transforms.append(transform)
        node.transforms.sort(by: { $0.start > $1.start })
        
        updateSpeaker(node.id, transform.start)
    }
    
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
