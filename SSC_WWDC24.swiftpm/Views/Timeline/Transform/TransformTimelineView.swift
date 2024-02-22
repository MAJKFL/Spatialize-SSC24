//
//  File.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SwiftUI

/// Transform representation on the timeline.
struct TransformTimelineView: View {
    @Environment(\.self) var environment
    /// Swift Data context.
    @Environment(\.modelContext) var context
    /// Current project.
    @Bindable var project: Project
    /// Node associated with this transform.
    @Bindable var node: Node
    /// Transform represented by this view.
    @Bindable var transformModel: TransformModel
    /// Transform the user is currently editing size.
    @Binding var selectedTransform: TransformModel?
    /// Specifies whether to show the transform edit popover.
    @State private var showPopover = false
    
    /// Difference used for adjusting left border of the transform.
    @State private var startPointChange: Double = 0
    /// Difference used for adjusting right border of the transform.
    @State private var endPointChange: Double = 0
    
    /// Specifies whether the transform is obstructed by a different transform.
    var isObstructed: Bool {
        node.transforms
            .contains(where: {
                $0.start < transformModel.start &&
                $0.length + $0.start > transformModel.start
            })
    }
    
    var selectionBorderColor: Color {
        let components = node.color.resolve(in: environment)
        
        return Color(red: 1 - Double(components.red), green: 1 - Double(components.green), blue: 1 - Double(components.blue))
    }
    
    var body: some View {
        TransformView(transformModel: transformModel)
            .overlay {
                ZStack {
                    HStack {
                        Spacer()
                        
                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                
                                Button("Edit") {
                                    showPopover.toggle()
                                }
                                .padding(5)
                                .background(Material.thick)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .popover(isPresented: $showPopover) {
                                    TransformPreviewView(project: project, node: node, transformModel: transformModel)
                                        .frame(width: 500, height: 700)
                                }
                                .offset(x: getEditOffsetX(from: geo) + 0.1)
                                
                                Spacer()
                            }
                        }
                        .frame(maxWidth: 40)
                        .padding(.trailing, 10)
                    }
                    
                    getRect()
                        .fill(.clear)
                        .strokeBorder(selectedTransform?.id == transformModel.id ? selectionBorderColor : .clear, lineWidth: 3)
                    
                    if selectedTransform?.id == transformModel.id {
                        HStack {
                            Circle()
                                .fill(selectionBorderColor)
                                .frame(width: 12, height: 12)
                                .offset(x: -4.5)
                                .gesture(
                                    DragGesture(minimumDistance: 1, coordinateSpace: .global)
                                        .onChanged { gesture in
                                            startPointChange = Double(Int(gesture.translation.width / Constants.fullBeatWidth * 2)) * Constants.fullBeatWidth / 2
                                        }
                                )
                            
                            Spacer()
                            
                            Circle()
                                .fill(selectionBorderColor)
                                .frame(width: 12, height: 12)
                                .offset(x: 4.5)
                                .gesture(
                                    DragGesture(minimumDistance: 1, coordinateSpace: .global)
                                        .onChanged { gesture in
                                            endPointChange = Double(Int(gesture.translation.width / Constants.fullBeatWidth * 2)) * Constants.fullBeatWidth / 2
                                        }
                                )
                        }
                    }
                }
            }
            .background {
                getRect()
                    .fill(isObstructed ? Color.red.opacity(0.5) : node.color.opacity(0.5))
                    .strokeBorder(node.color, lineWidth: 3)
            }
            .draggable(TransformTransfer(model: transformModel)) {
                Image(systemName: transformModel.type.iconName)
                    .foregroundStyle(Color.white)
                    .font(.largeTitle)
                    .padding()
                    .background {
                        Color.gray.opacity(0.8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .onChange(of: startPointChange) { oldValue, newValue in
                let change = newValue - oldValue;
                
                guard abs(change) == Constants.fullBeatWidth / 2 &&
                        (transformModel.start > 0 || change > 0) &&
                        (transformModel.length > Constants.fullBeatWidth * 4 || change < 0) else { return }
                
                transformModel.start += change;
                transformModel.length -= change;
            }
            .onChange(of: endPointChange) { oldValue, newValue in
                let change = newValue - oldValue;
                
                guard abs(change) == Constants.fullBeatWidth / 2 &&
                        (transformModel.length > Constants.fullBeatWidth * 4 || change > 0) else { return }
                
                transformModel.length += change;
            }
            .onTapGesture {
                if selectedTransform?.id == transformModel.id {
                    selectedTransform = nil
                } else {
                    selectedTransform = transformModel
                }
            }
            .contextMenu {
                Button("Delete", role: .destructive) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        context.delete(transformModel)
                        node.transforms.removeAll(where: { $0.id == transformModel.id })
                    }
                }
            }
    }
    
    private func getEditOffsetX(from geo: GeometryProxy) -> Double {
        let offset =  UIScreen.main.bounds.size.width - geo.frame(in: .global).maxX - 10
        
        guard offset < 0 else { return 0 }
        
        if offset > -transformModel.length + 175 {
            return offset
        } else {
            return -transformModel.length + 175
        }
    }
    
    private func getRect() -> UnevenRoundedRectangle {
        let shouldLeftBeRounded = !node.tracks.contains(where: {
            $0.start <= transformModel.start && 
            $0.start + Constants.trackWidth($0, bpm: project.bpm) > transformModel.start
        })
        
        let shouldRightBeRounded = !node.tracks.contains(where: {
            $0.start < transformModel.start + transformModel.length &&
            ($0.start + Constants.trackWidth($0, bpm: project.bpm) > transformModel.start + transformModel.length || ($0.start + Constants.trackWidth($0, bpm: project.bpm)).isEqualTo(to: transformModel.start + transformModel.length, withPrecision: 0.1))
        })
        
        return .rect(
            topLeadingRadius: 10,
            bottomLeadingRadius: shouldLeftBeRounded ? 10 : 0,
            bottomTrailingRadius: shouldRightBeRounded ? 10 : 0,
            topTrailingRadius: 10
        )
    }
}
