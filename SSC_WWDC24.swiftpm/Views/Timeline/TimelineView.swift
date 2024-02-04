//
//  TimelineView.swift
//
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI
import Combine

struct TimelineView: View {
    @Bindable var project: Project
    @State var playheadManager: PlayheadManager
    
    @Binding var selectedTransform: TransformModel?
    let editTransform: Bool
    
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
        ScrollView {
            ZStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack {
                        beatMarkers()
                        
                        tracks()
                        
                        playhead()
                    }
                    .padding(.leading, 10)
                    .padding(.leading, 250)
                }
                
                nodeList()
                    .frame(width: 250)
                    .background(.regularMaterial)
                    .padding(.top, 30)
            }
            .frame(minHeight: 320)
        }
        .ignoresSafeArea()
        .onChange(of: playheadManager.offset) { oldValue, newValue in
            
            if newValue >= Double((numberOfBeats - project.timeSignature.firstDigit - 1)) *
                (Constants.beatSpacingFor(timeSingature: project.timeSignature) +
                Constants.beatMarkerWidthFor(timeSignature: project.timeSignature)) {
                playheadManager.pause()
            }
        }
    }
    
    func nodeList() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(project.nodes.sorted(by: { $0.position < $1.position })) { node in
                NodeListRowView(project: project, node: node)
                
                Divider()
            }
            
            Button {
                addNewNode()
            } label: {
                HStack {
                    Text("Add new node")
                    
                    Spacer()
                    
                    Image(systemName: "plus")
                        .font(.headline)
                }
            }
            .frame(height: Constants.nodeViewHeight)
            .padding(.horizontal)
            
            Spacer()
        }
        .animation(.easeIn(duration: 0.2), value: project.nodes)
    }
    
    func beatMarkers() -> some View {
        HStack(spacing: Constants.beatSpacingFor(timeSingature: project.timeSignature)) {
            ForEach(project.timeSignature.firstDigit..<numberOfBeats, id: \.self) { x in
                VStack(spacing: 10) {
                    Text(getBeatStr(x))
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(x % project.timeSignature.firstDigit == 0 ? 1 : 0.5))
                        .frame(width: 30, height: 20)
                        .onTapGesture {
                            guard !playheadManager.isPlaying else { return }
                            playheadManager.jumpTo(x)
                        }
                    
                    Rectangle()
                        .fill(.gray.opacity(x % project.timeSignature.firstDigit == 0 ? 1 : 0.3))
                        .frame(width: 1)
                }
                .frame(width: Constants.beatMarkerWidthFor(timeSignature: project.timeSignature))
            }
            
            Spacer()
        }
        .padding(.leading, Constants.timelineLeadingPaddingFor(timeSignature: project.timeSignature))
    }
    
    func tracks() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(project.nodes.sorted(by: { $0.position < $1.position })) { node in
                    NodeTimelineView(project: project, node: node, selectedTransform: $selectedTransform, editTransform: editTransform)
                        .frame(height: 80)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(.top, 30)
        .padding(.leading, 4)
    }
    
    func playhead() -> some View {
        HStack {
            VStack(spacing: 0) {
                Image(systemName: "chevron.down")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8.5)
                
                Rectangle()
                    .fill(.primary)
            }
            .frame(width: 2)
            .offset(x: playheadManager.offset)
            
            Spacer()
        }
        .padding(.leading, 4)
    }
    
    func getEndFor(track: Track) -> Double {
        Constants.trackWidth(track, bpm: project.bpm) + track.start
    }
    
    func getBeatStr(_ x: Int) -> String {
        return String(x / project.timeSignature.firstDigit) + "." + String(x % project.timeSignature.firstDigit + 1)
    }
    
    func addNewNode() {
        let number = project.nodes
            .map { $0.name }
            .filter { $0.contains("New Node") }
            .map { Int($0.replacingOccurrences(of: "New Node ", with: "")) ?? 0 }
            .max() ?? 0
        
        let defaultNodeNameCount = project.nodes
            .map { $0.name }
            .filter { $0.contains("New Node") }
            .count
        
        let currentPosition = project.nodes
            .map { $0.position }
            .max() ?? 0
        
        project.nodes.append(Node(position: currentPosition + 1, name: "New Node\(defaultNodeNameCount == 0 ? "" : " \(number + 1)")", color: UIColor(named: "NewNodeColor")!))
        project.nodes.sort(by: { $0.position < $1.position })
    }
}
