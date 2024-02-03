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
    
    @State private var dragOffset = 0
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Stepper(value: $project.bpm.animation(), in: 5...200) {
            HStack(spacing: 0) {
                Text("BPM: \(project.bpm)")
                    .foregroundStyle(.primary.opacity(isEnabled ? 1 : 0.3))
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote)
                    .foregroundStyle(.secondary.opacity(isEnabled ? 1 : 0.3))
            }
                .monospaced()
                .frame(height: 33)
                .padding(.horizontal, 6)
                .background {
                    Color.blue.opacity(0.1)
                }
                .contentTransition(.numericText())
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.height < -30 {
                                dragOffset = -3
                            } else if gesture.translation.height > 30 {
                                dragOffset = 3
                            } else {
                                dragOffset = Int(gesture.translation.height / 10)
                            }
                        }
                        .onEnded { _ in
                            dragOffset = 0
                        }
                )
        }
        .onReceive(timer) { _ in
            guard dragOffset != 0 else { return }
            
            withAnimation {
                project.bpm += dragOffset
            }
            
            if (project.bpm < 5) {
                project.bpm = 5
            }
            
            if (project.bpm > 200) {
                project.bpm = 200
            }
        }
    }
}
