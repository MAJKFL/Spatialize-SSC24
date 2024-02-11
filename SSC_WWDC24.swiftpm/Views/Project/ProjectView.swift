//
//  ProjectView.swift
//  PHASing
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI

/// Current selected project view.
struct ProjectView: View {
    /// Current project.
    @Bindable var project: Project
    
    /// Used for adjusting playhead and managing playback.
    @State private var playheadManager: PlayheadManager
    /// Specifies whether user is editing transforms or audio files.
    @State private var editTransform = false
    /// Transform the user is currently editing size.
    @State private var selectedTransform: TransformModel?
    
    /// View model of the 3D editor.
    @StateObject var viewModel: EditorViewModel
    
    /// Creates new project view.
    init(project: Project) {
        self.project = project
        let playheadMng = PlayheadManager(project: project)
        self._playheadManager = State(initialValue: playheadMng)
        self._viewModel = StateObject(wrappedValue: EditorViewModel(playheadManager: playheadMng))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                EditorView(project: project, playheadManager: playheadManager, viewModel: viewModel)
                
                transformPicker()
            }
            
            TimelineView(project: project, playheadManager: playheadManager, selectedTransform: $selectedTransform, editTransform: editTransform)
                .frame(height: 350)
        }
        .toolbarRole(.editor)
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.spring(duration: 0.15)) {
                        editTransform.toggle()
                        
                        if !editTransform {
                            selectedTransform = nil
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: editTransform ? "waveform" : "arrow.triangle.swap")
                        
                        Text(editTransform ? "Audio" : "Transform")
                    }
                }
            }
            
            playheadControls()
            
            ToolbarItem(placement: .topBarTrailing) {
                TimeSignaturePicker(project: project)
                    .disabled(playheadManager.isPlaying)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                BPMStepper(project: project)
                    .disabled(playheadManager.isPlaying)
            }
        }
        .toolbarRole(.editor)
        .ignoresSafeArea(.keyboard)
        .onChange(of: project) { oldValue, newValue in
            playheadManager.pause()
            playheadManager.revert()
            viewModel.pausePlayback()
            playheadManager.project = newValue
            viewModel.updateSpeakerNodePosition(playheadOffset: 0)
        }
    }
    
    /// Shows available transforms.
    private func transformPicker() -> some View {
        VStack {
            Spacer()
            
            if editTransform {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(TransformType.allCases, id: \.self) { type in
                            TransformView(transformModel: TransformModel.defaultModel(for: type), isTemplate: true)
                                .shadow(radius: 7)
                                .padding()
                        }
                    }
                }
                .background(.thinMaterial)
            }
        }
    }
    
    /// Buttons responsible for managing the playhead.
    private func playheadControls() -> ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .secondaryAction) {
            Button {
                playheadManager.jumpBackward()
            } label: {
                Label("Backward", systemImage: "backward.fill")
            }
            .disabled(playheadManager.isPlaying)
            
            Button {
                playheadManager.jumpForward()
            } label: {
                Label("Forward", systemImage: "forward.fill")
            }
            .disabled(playheadManager.isPlaying)
            
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
            .buttonStyle(.plain)
            .foregroundStyle(playheadManager.isPlaying ? .green : .accentColor)
        }
    }
}
