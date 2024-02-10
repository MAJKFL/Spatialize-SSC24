//
//  NodeListRowView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI

struct NodeListRowView: View {
    @Environment(\.modelContext) var context
    @Bindable var project: Project
    @Bindable var node: Node
    
    @State private var showDetailPopover = false
    
    var areOtherSolo: Bool {
        project.nodes.contains(where: { $0.isSolo }) && !node.isSolo
    }
    
    var body: some View {
        HStack(spacing: 15) {
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
                    .frame(width: 18)
            }
            .tint(node.isSolo ? .orange : node.color.opacity(areOtherSolo ? 0.3 : 1))
            
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
    
    func detailsPopover() -> some View {
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
