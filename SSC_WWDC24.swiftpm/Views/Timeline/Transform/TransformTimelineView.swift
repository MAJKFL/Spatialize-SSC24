//
//  File.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SwiftUI

/// Transform representation on the timeline.
struct TransformTimelineView: View {
    @Environment(\.isEnabled) var isEnabled
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
    
    var body: some View {
        TransformView(transformModel: transformModel, isObstructed: isObstructed)
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        
                        if isEnabled {
                            Button("Edit") {
                                showPopover.toggle()
                            }
                            .padding(5)
                            .background(Material.thick)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 5,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 9.5
                                )
                            )
                            .popover(isPresented: $showPopover) {
                                TransformEditView(project: project, node: node, transformModel: transformModel)
                                    .frame(width: 600, height: 800)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.clear)
                        .strokeBorder(selectedTransform?.id == transformModel.id && isEnabled ? Color.accentColor : .clear, lineWidth: 3)
                    
                    if selectedTransform?.id == transformModel.id {
                        HStack {
                            Circle()
                                .fill(Color.accentColor)
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
                                .fill(Color.accentColor)
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
}
