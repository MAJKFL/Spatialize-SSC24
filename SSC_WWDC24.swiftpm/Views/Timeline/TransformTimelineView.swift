//
//  File.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SwiftUI

struct TransformTimelineView: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.modelContext) var context
    @Bindable var project: Project
    @Bindable var node: Node
    @Bindable var transformModel: TransformModel
    @Binding var selectedTransform: TransformModel?
    @State private var showPopover = false
    
    @State private var startPointChange: Double = 0
    @State private var endPointChange: Double = 0
    
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
                                    topTrailingRadius: 10
                                )
                            )
                            .popover(isPresented: $showPopover) {
                                editPopover()
                                    .frame(width: 300, height: 300)
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
    
    func editPopover() -> some View {
        NavigationView {
            Form {
                ForEach(Array(transformModel.doubleFields.keys).sorted(), id: \.self) { key in
                    doubleEditRowFor(key: key)
                }
                
                ForEach(Array(transformModel.booleanFields.keys).sorted(), id: \.self) { key in
                    booleanEditRowFor(key: key)
                }
            }
            .navigationTitle(transformModel.type.displayName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    func doubleEditRowFor(key: String) -> some View {
        let binding = Binding<Double> {
            transformModel.doubleFields[key] ?? 0
        } set: { value in
            transformModel.doubleFields[key] = value
        }
        
        HStack {
            Text(key)
            
            Spacer()
            
            TextField(key, value: binding, format: .number)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
        }
    }
    
    @ViewBuilder
    func booleanEditRowFor(key: String) -> some View {
        let binding = Binding<Bool> {
            transformModel.booleanFields[key] ?? false
        } set: { value in
            transformModel.booleanFields[key] = value
        }
        
        Toggle(key, isOn: binding)
    }
}