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
    
    var body: some View {
        ZStack {
            ForEach(project.nodes) { node in
                Text(node.name)
                    .foregroundStyle(.background)
                    .onChange(of: node.color) { oldValue, newValue in
                        viewModel.onNodeColorChange(node)
                    }
            }
            
            EditorViewRepresentable(viewModel: viewModel)
                .onAppear {
                    viewModel.setSpeakerNodes(for: project.nodes)
                    viewModel.updateSpeakerNodePosition(playheadOffset: 0)
                }
                .onChange(of: project.nodes) { oldValue, newValue in
                    viewModel.setSpeakerNodes(for: newValue)
                }
                .onChange(of: playheadManager.offset) { oldValue, newValue in
                    viewModel.updateSpeakerNodePosition(playheadOffset: newValue)
                }
                .onChange(of: playheadManager.isPlaying) { oldValue, newValue in
                    if newValue {
                        viewModel.startEngine(atOffset: playheadManager.offset, bpm: project.bpm)
                    } else {
                        viewModel.stopEngine()
                    }
                }
        }
    }
}
