//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI

struct BPMStepper: View {
    @Environment(\.isEnabled) var isEnabled
    
    @Bindable var project: Project
    
    var body: some View {
        Stepper(value: $project.bpm.animation(), in: 5...200) {
            Text("BPM: \(project.bpm)")
                .foregroundStyle(.primary.opacity(isEnabled ? 1 : 0.3))
                .monospaced()
                .frame(height: 33)
                .padding(.horizontal, 6)
                .background {
                    Color.blue.opacity(0.1)
                }
                .contentTransition(.numericText())
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
