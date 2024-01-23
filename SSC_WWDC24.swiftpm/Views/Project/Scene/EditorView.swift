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
    
    @StateObject var viewModel = EditorViewModel()
    
    var body: some View {
        ZStack {
            ForEach(project.nodes) { node in
                Text(node.name)
                    .onChange(of: node.color) { oldValue, newValue in
                        viewModel.onNodeColorChange(node)
                    }
            }
            
            EditorViewRepresentable(viewModel: viewModel)
                .onAppear {
                    viewModel.setSpeakerNodes(for: project.nodes)
                }
                .onChange(of: project.nodes) { oldValue, newValue in
                    viewModel.setSpeakerNodes(for: newValue)
                }
                .onChange(of: playheadManager.offset) { oldValue, newValue in
                    viewModel.updateSpeakerNodePosition(playheadOffset: newValue)
                }
        }
    }
}
