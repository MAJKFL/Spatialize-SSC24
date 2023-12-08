//
//  ProjectView.swift
//  PHASing
//
//  Created by Jakub Florek on 11/11/2023.
//

import SwiftUI

struct ProjectView: View {
    @Bindable var project: Project
    
    var body: some View {
        VStack(spacing: 0) {
            ScenePreviewView()
                .toolbarRole(.editor)
                .navigationTitle(project.name)
            
            Spacer()
            
            Divider()
            
            TimelineEditorView(project: project)
                .frame(height: 300)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TimeSignaturePicker(project: project)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                BPMStepper(project: project)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}
