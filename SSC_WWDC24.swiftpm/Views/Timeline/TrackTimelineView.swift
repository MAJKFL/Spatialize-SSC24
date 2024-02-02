//
//  TrackTimelineView.swift
//
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI

struct TrackTimelineView: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.modelContext) var context
    @Bindable var project: Project
    @Bindable var node: Node
    @Bindable var track: Track
    
    @State private var showPopover = false
    @State private var waveformImage: Image?
    
    var isObstructed: Bool {
        node.tracks
            .contains(where: {
                $0.start < track.start &&
                Constants.trackWidth($0, bpm: project.bpm) + $0.start > track.start
            })
    }
    
    var body: some View {
        ZStack {
            if let waveformImage {
                waveformImage
                    .resizable()
                    .frame(width: Constants.trackWidth(track, bpm: project.bpm), height: Constants.nodeViewHeight)
                    .opacity(0.8)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isObstructed ? .secondary.opacity(0.3) : node.color.opacity(0.7))
                                .strokeBorder(isObstructed ? .secondary.opacity(0.7) : node.color.opacity(0.9), lineWidth: 3)
                                .opacity(isEnabled ? 1 : 0.3)
                            
                            if isObstructed {
                                GeometryReader { geo in
                                    HStack {
                                        ForEach(0..<Int(geo.size.width) / 50, id: \.self) { i in
                                            Spacer()
                                            
                                            Rectangle()
                                                .fill(.red.opacity(0.7))
                                                .frame(width: 10, height: geo.size.height * 1.5)
                                                .rotationEffect(.radians(.pi / 4))
                                                .offset(x: -20, y: -geo.size.height / 4)
                                        }
                                    }
                                }
                                .opacity(isEnabled ? 1 : 0.3)
                            }
                        }
                    }
                    .mask {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.black)
                    }
            } else {
                Rectangle()
                    .fill(.clear)
                    .frame(height: Constants.nodeViewHeight)
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
                withAnimation(.easeIn(duration: 0.1)) {
                    node.tracks.removeAll(where: { $0.id == track.id })
                    context.delete(track)
                    do {
                        try FileManager.default.removeItem(at: track.fileURL)
                    } catch {
                        print(error)
                    }
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
            let image = Image(uiImage: uiImage)
            self.waveformImage = image
        }
    }
}