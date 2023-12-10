//
//  ProjectView.swift
//  PHASing
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI

struct ProjectView: View {
    @Bindable var project: Project
    
    @State var playheadManager: PlayheadManager
    
    init(project: Project) {
        self.project = project
        self._playheadManager = State(initialValue: PlayheadManager(project: project))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScenePreviewView()
                .toolbarRole(.editor)
                .navigationTitle(project.name)
            
            Spacer()
            
            Divider()
            
            TimelineEditorView(project: project, playheadManager: playheadManager)
                .frame(height: 300)
        }
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    playheadManager.jumpBackward()
                } label: {
                    Label("Backward", systemImage: "backward.fill")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    playheadManager.jumpForward()
                } label: {
                    Label("Forward", systemImage: "forward.fill")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    if playheadManager.isPlaying || playheadManager.offset == 0 {
                        playheadManager.pause()
                    } else {
                        playheadManager.revert()
                    }
                } label: {
                    Label("Stop/Revert", systemImage: playheadManager.isPlaying || playheadManager.offset == 0 ? "stop.fill" : "backward.end.fill")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    playheadManager.toggle()
                } label: {
                    Label("Play/Pause", systemImage: "play.fill")
                }
                .tint(playheadManager.isPlaying ? .green : .accentColor)
            }
            
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
}
