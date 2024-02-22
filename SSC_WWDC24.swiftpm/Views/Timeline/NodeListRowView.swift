//
//  NodeListRowView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI

/// Speaker node representation in the list on the timeline left side.
struct NodeListRowView: View {
    /// Swift Data context.
    @Environment(\.modelContext) var context
    /// Current project.
    @Bindable var project: Project
    /// Node represented by this row.
    @Bindable var node: Node
    
    /// Specifies whether to show the detail popover.
    @State private var showDetailPopover = false
    
    /// Specifies whether other speaker nodes are solo and this one isn't.
    private var areOtherSolo: Bool {
        project.nodes.contains(where: { $0.isSolo }) && !node.isSolo
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                node.isPlaying.toggle()
            } label: {
                Image(systemName: node.isPlaying ? "speaker.wave.3" : "speaker.slash", variableValue: node.volume)
                    .font(.headline)
                    .frame(width: 18)
            }
            
            Button {
                node.isSolo.toggle()
            } label: {
                Image(systemName: "headphones")
                    .font(.headline)
                    .frame(width: 18, height: 18)
            }
            .tint(node.isSolo ? .white : node.color.opacity(areOtherSolo ? 0.3 : 1))
            .padding(5)
            .background(node.isSolo ? .orange : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Text(node.name)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                showDetailPopover = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.headline)
            }
            .popover(isPresented: $showDetailPopover) {
                detailsPopover()
            }
        }
        .tint(node.color.opacity(areOtherSolo ? 0.3 : 1))
        .frame(height: Constants.nodeViewHeight)
        .padding(.horizontal)
    }
    
    /// Speaker node popover with details.
    private func detailsPopover() -> some View {
        Form {
            Section {
                TextField("Name", text: $node.name)
                
                ColorPicker("Color", selection: $node.color.animation(), supportsOpacity: false)
            }
            
            Section {
                Slider(value: $node.volume, in: 0...1)
                
                Toggle("Is playing", isOn: $node.isPlaying)
            } header: {
                Text("Volume")
            }
             
            Section {
                Button {
                    context.delete(node)
                    do {
                        let manager = FileManager.default
                        for track in node.tracks {
                            try manager.removeItem(at: track.fileURL)
                        }
                        
                        project.nodes.removeAll(where: { $0.id == node.id })
                    } catch {
                        print(error)
                    }
                } label: {
                    Text("Delete")
                }
                .tint(.red)
            }
        }
        .frame(width: 300, height: 300)
    }
}
