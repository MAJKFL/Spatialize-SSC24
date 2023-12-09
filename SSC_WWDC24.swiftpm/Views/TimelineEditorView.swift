//
//  TimelineEditorView.swift
//
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI

struct TimelineEditorView: View {
    @Bindable var project: Project
    
    var numberOfBeats: Int {
        let result = project.nodes
            .flatMap { $0.tracks }
            .map { getNumberOfBeatsFor(track: $0) }
            .max() ?? 20
        
        return result * 2 / Int(distanceMultiplier(project.timeSignature.secondDigit))
    }
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    
                    ForEach(project.nodes.sorted(by: { $0.position < $1.position })) { node in
                        NodeListRowView(project: project, node: node)
                        
                        Divider()
                    }
                    
                    HStack {
                        Text("New Node")
                        
                        Spacer()
                        
                        Button {
                            addNewNode()
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                        }
                    }
                    .frame(height: 60)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .animation(.easeIn(duration: 0.2), value: project.nodes)
                .frame(width: 300)
                .padding(.top, 30)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack {
                        HStack(spacing: 45 * distanceMultiplier(project.timeSignature.secondDigit)) {
                            ForEach(project.timeSignature.firstDigit..<numberOfBeats, id: \.self) { x in
                                VStack(spacing: 10) {
                                    Text(getBeatStr(x))
                                        .font(.caption)
                                        .foregroundStyle(.secondary.opacity(x % project.timeSignature.firstDigit == 0 ? 1 : 0.5))
                                        .frame(width: 30, height: 20)
                                    
                                    Rectangle()
                                        .fill(.gray.opacity(x % project.timeSignature.firstDigit == 0 ? 1 : 0.3))
                                        .frame(width: 1)
                                }
                                .frame(width: 5 * distanceMultiplier(project.timeSignature.secondDigit))
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 2 * distanceMultiplier(project.timeSignature.secondDigit).truncatingRemainder(dividingBy: 2))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(project.nodes.sorted(by: { $0.position < $1.position })) { node in
                                    NodeTimelineView(project: project, node: node)
                                        .frame(height: 60)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 30)
                        .padding(.leading, 4)
                    }
                    .padding(.leading, 10)
                }
            }
            .frame(minHeight: 320)
        }
        .edgeMaterialGradient(startPoint: .top, endPoint: .bottom, size: 20)
        .ignoresSafeArea()
    }
    
    func getNumberOfBeatsFor(track: Track) -> Int {
        var result = Int(Double(project.bpm) * track.trackLength / 60) + Int(track.start) / 100 + 10 + project.timeSignature.firstDigit
        result -= result % project.timeSignature.firstDigit
        return result
    }
    
    func getBeatStr(_ x: Int) -> String {
        return String(x / project.timeSignature.firstDigit) + "." + String(x % project.timeSignature.firstDigit + 1)
    }
    
    func distanceMultiplier(_ x: Int) -> Double {
        if (x == 8) {
            return 1;
        } else {
            return 2;
        }
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
    }
}
