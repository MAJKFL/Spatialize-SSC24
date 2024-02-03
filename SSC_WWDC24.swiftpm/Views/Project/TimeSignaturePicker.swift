//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI

struct TimeSignaturePicker: View {
    @Bindable var project: Project
    
    var body: some View {
        Menu {
            Picker(selection: $project.timeSignature, label: EmptyView()) {
                ForEach(TimeSignature.allCases) { timeSignature in
                    Text(timeSignature.stringRepresentation)
                        .tag(timeSignature)
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text("\(project.timeSignature.firstDigit)")
                    .contentTransition(.numericText())
                
                Text("/")
                
                Text("\(project.timeSignature.secondDigit)")
                    .contentTransition(.numericText())
            }
            .animation(.spring, value: project.timeSignature)
        }
        .tint(.primary)
        .monospaced()
        .frame(height: 33)
        .background {
            Color.blue.opacity(0.1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
