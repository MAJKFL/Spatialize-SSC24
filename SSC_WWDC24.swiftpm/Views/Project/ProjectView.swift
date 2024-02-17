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
                Color.black
                
                HStack(spacing: 0) {
                    transformPicker()
                    
                    Color.secondary
                        .opacity(0.7)
                        .frame(width: 2)
                    
                    EditorView(project: project, playheadManager: playheadManager, viewModel: viewModel)
                }
            }
            
            TimelineView(project: project, playheadManager: playheadManager, selectedTransform: $selectedTransform)
                .frame(height: 400)
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Transforms")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .padding([.leading, .vertical])
                
                ForEach(TransformType.allCases, id: \.self) { type in
                    TransformView(transformModel: TransformModel.defaultModel(for: type), isTemplate: true)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.5))
                                .strokeBorder(Color.gray, lineWidth: 3)
                        }
                        .draggable(TransformTransfer(model: TransformModel.defaultModel(for: type))) {
                            Image(systemName: TransformModel.defaultModel(for: type).type.iconName)
                                .foregroundStyle(Color.white)
                                .font(.largeTitle)
                                .padding()
                                .background {
                                    Color.gray.opacity(0.8)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .frame(height: Constants.nodeViewHeight / 2)
                        .padding([.horizontal, .bottom])
                }
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
