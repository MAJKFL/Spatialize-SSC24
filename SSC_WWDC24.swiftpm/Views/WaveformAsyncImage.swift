//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI

struct WaveformAsyncImage: View {
    @Environment(\.modelContext) var context
    @Bindable var project: Project
    @Bindable var node: Node
    @Bindable var track: Track
    
    @State private var showPopover = false
    @State private var waveformImage: Image?
    
    var width: Double {
        Double(project.bpm) * (track.trackLength / 60) * 100
    }
    
    var body: some View {
        ZStack {
            if let waveformImage {
                waveformImage
                    .resizable()
                    .frame(width: width, height: 60)
                    .opacity(0.8)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(node.color.opacity(0.8))
                            .strokeBorder(node.color.opacity(0.9), lineWidth: 3)
                    }
            } else {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 60)
            }
        }
        .onAppear {
            Task {
                await loadImage()
            }
        }
        .onTapGesture {
            showPopover = true
        }
        .popover(isPresented: $showPopover, arrowEdge: .top) {
            Button {
                node.tracks.removeAll(where: { $0.id == track.id })
                context.delete(track)
                do {
                    try FileManager.default.removeItem(at: track.fileURL)
                } catch {
                    print(error)
                }
            } label: {
                Text("Delete")
            }
            .tint(.red)
        }
    }
    
    func loadImage() async {
        if track.imageData == nil {
            let newImage = await WaveGenerator.generateWaveImage(from: track.fileURL)
            
            track.imageData = newImage?.heicData()
        }
        
        guard let imageData = track.imageData, let uiImage = UIImage(data: imageData) else { return }

        DispatchQueue.main.async {
            self.waveformImage = Image(uiImage: uiImage)
        }
    }
}
