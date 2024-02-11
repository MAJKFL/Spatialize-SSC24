//
//  EditorView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI
import SceneKit
import Combine

struct EditorView: View {
    @Bindable var project: Project
    @State var playheadManager: PlayheadManager
    
    @ObservedObject var viewModel: EditorViewModel
    
    @State private var shouldSeek = true
    
    let updateSpeaker: (ObjectIdentifier, Double) -> ()
    
    var body: some View {
        ZStack {
            ForEach(project.nodes) { node in
                Text(node.name)
                    .foregroundStyle(.background)
                    .onChange(of: node.color) { oldValue, newValue in
                        viewModel.onNodeColorChange(node)
                    }
                    .onChange(of: node.isSolo) { oldValue, newValue in
                        viewModel.soloMode = project.nodes.contains(where: { $0.isSolo })
                    }
            }
            
            EditorViewRepresentable(viewModel: viewModel)
                .onChange(of: project.nodes) { oldValue, newValue in
                    viewModel.setSpeakerNodes(for: newValue)
                    
                    if let newNode = newValue.first(where: { n in
                        !oldValue.contains(where: { $0.id == n.id })
                    }) {
                        updateSpeaker(newNode.id, 0)
                    }
                }
                .onChange(of: playheadManager.offset) { oldValue, newValue in
                    if !playheadManager.isPlaying {
                        shouldSeek = true
                    }
                    
                    viewModel.updateSpeakerNodePosition(playheadOffset: newValue)
                }
                .onChange(of: playheadManager.isPlaying) { oldValue, newValue in
                    if newValue {
                        viewModel.startOrResumePlayback(atOffset: playheadManager.offset, bpm: project.bpm, shouldSeek: shouldSeek)
                        shouldSeek = false
                    } else {
                        viewModel.pausePlayback()
                    }
                }
                .onChange(of: project.nodes.flatMap({ $0.tracks })) { oldValue, newValue in
                    viewModel.registerTracks(newValue)
                }
        }
    }
}
