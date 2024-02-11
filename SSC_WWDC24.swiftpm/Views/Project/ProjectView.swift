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
    @State private var isPlayAvailable = true
    @State private var selectedTransform: TransformModel?
    
    @StateObject var viewModel: EditorViewModel
    
    init(project: Project) {
        self.project = project
        let playheadMng = PlayheadManager(project: project)
        self._playheadManager = State(initialValue: playheadMng)
        self._viewModel = StateObject(wrappedValue: EditorViewModel(playheadManager: playheadMng))
    }
    
    var numberOfBeats: Int {
        let lastTrackEnd = project.nodes
            .flatMap { $0.tracks }
            .map { getEndFor(track: $0) }
            .max()
        
        if let lastTrackEnd {
            return Constants.getNumberOfBeatsFor(lastTrackEnd, with: project.timeSignature)
        } else {
            return Int(Constants.fullBeatWidth) / 10 * project.timeSignature.secondDigit
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                EditorView(project: project, playheadManager: playheadManager, viewModel: viewModel, updateSpeaker: updateSpeaker(id:from:))
                
                transformPicker()
            }
            
            TimelineView(project: project, playheadManager: playheadManager, selectedTransform: $selectedTransform, editTransform: editTransform, numberOfBeats: numberOfBeats, updateSpeaker: updateSpeaker(id:from:))
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
            
            updateAllSpeakers()
        }
        .onChange(of: numberOfBeats) { oldValue, newValue in
            guard newValue > oldValue else { return }
            
            updateAllSpeakers()
        }
        .onAppear {
            viewModel.setSpeakerNodes(for: project.nodes)
            viewModel.registerTracks(project.nodes.flatMap({ $0.tracks }))
            viewModel.updateSpeakerNodePosition(playheadOffset: 0)
            
            updateAllSpeakers()
        }
    }
    
    func transformPicker() -> some View {
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
    
    func playheadControls() -> ToolbarItemGroup<some View> {
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
                if isPlayAvailable {
                    Label("Play/Pause", systemImage: "play.fill")
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(playheadManager.isPlaying ? .green : .accentColor)
            .disabled(!isPlayAvailable)
        }
    }
    
    func getEndFor(track: Track) -> Double {
        Constants.trackWidth(track, bpm: project.bpm) + track.start
    }
    
    func updateSpeaker(id: ObjectIdentifier, from: Double) {
        isPlayAvailable = false
        
        Task {
            await viewModel.updateSpeaker(id: id, from: from, to: Double(numberOfBeats + 10) * Constants.fullBeatWidth)
            viewModel.updateSpeakerPosition(id: id, atOffset: playheadManager.offset)
            
            DispatchQueue.main.async {
                isPlayAvailable = true
            }
        }
    }
    
    func updateAllSpeakers() {
        isPlayAvailable = false
        
        Task {
            await viewModel.updateAllSpeakers(maxPlayheadOffset: Double(numberOfBeats + 10) * Constants.fullBeatWidth)
            viewModel.updateSpeakerNodePosition(playheadOffset: playheadManager.offset)
            
            DispatchQueue.main.async {
                isPlayAvailable = true
            }
        }
    }
}
