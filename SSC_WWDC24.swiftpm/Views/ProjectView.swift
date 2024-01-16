//
//  ProjectView.swift
//  PHASing
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI

struct ProjectView: View {
    @Bindable var project: Project
    
    @State private var playheadManager: PlayheadManager
    @State private var editTransform = false
    
    init(project: Project) {
        self.project = project
        self._playheadManager = State(initialValue: PlayheadManager(project: project))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScenePreviewView()
                
                transformPicker()
            }
            
            TimelineEditorView(project: project, playheadManager: playheadManager, editTransform: editTransform)
                .frame(height: 280)
                .zIndex(5)
        }
        .toolbarRole(.editor)
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.spring(duration: 0.15)) {
                        editTransform.toggle()
                    }
                } label: {
                    Image(systemName: editTransform ? "arrow.triangle.swap" : "waveform") // TODO: Custom 3d arrow symbol
                }
            }
            
            playheadControls()
            
            ToolbarItem(placement: .topBarTrailing) {
                TimeSignaturePicker(project: project)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                BPMStepper(project: project)
            }
        }
        .toolbarRole(.editor)
        .ignoresSafeArea(.keyboard)
    }
    
    func transformPicker() -> some View {
        VStack {
            Spacer()
            
            if editTransform {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(TransformType.allCases, id: \.self) { type in
                            TransformView(transformModel: TransformModel.defaultModel(for: type))
                                .padding()
                        }
                    }
                }
                .background(.thinMaterial)
            }
        }
    }
    
    func playheadControls() -> ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .secondaryAction) {
            Button {
                playheadManager.jumpBackward()
            } label: {
                Label("Backward", systemImage: "backward.fill")
            }
            
            Button {
                playheadManager.jumpForward()
            } label: {
                Label("Forward", systemImage: "forward.fill")
            }
            
            Button {
                if playheadManager.isPlaying || playheadManager.offset == 0 {
                    playheadManager.pause()
                } else {
                    playheadManager.revert()
                }
            } label: {
                Label("Stop/Revert", systemImage: playheadManager.isPlaying || playheadManager.offset == 0 ? "stop.fill" : "backward.end.fill")
            }
            
            Button {
                playheadManager.toggle()
            } label: {
                Label("Play/Pause", systemImage: "play.fill")
            }
            .tint(playheadManager.isPlaying ? .green : .accentColor)
        }
    }
}
