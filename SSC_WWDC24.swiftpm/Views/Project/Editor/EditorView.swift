//
//  EditorView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI
import SceneKit
import Combine

/// SwiftUI view of the 3D editor.
struct EditorView: View {
    /// Current project.
    @Bindable var project: Project
    /// Used for adjusting playhead and managing playback.
    @State var playheadManager: PlayheadManager
    
    /// View model of the 3D editor.
    @ObservedObject var viewModel: EditorViewModel
    
    /// Specifies whether playhead was moved outside of playback and the files have to be seeked accordingly.
    @State private var shouldSeek = true
    
    var body: some View {
        ZStack {
            ForEach(project.nodes) { node in
                Text(node.name)
                    .foregroundStyle(.black)
                    .onChange(of: node.color) { oldValue, newValue in
                        viewModel.onNodeColorChange(node)
                    }
                    .onChange(of: node.isSolo) { oldValue, newValue in
                        viewModel.soloMode = project.nodes.contains(where: { $0.isSolo })
                    }
            }
            
            EditorViewRepresentable(viewModel: viewModel)
                .onAppear {
                    viewModel.setSpeakerNodes(for: project.nodes)
                    viewModel.registerTracks(project.nodes.flatMap({ $0.tracks }))
                    viewModel.updateSpeakerNodePosition(playheadOffset: 0)
                }
                .onChange(of: project.nodes) { oldValue, newValue in
                    viewModel.setSpeakerNodes(for: newValue)
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
