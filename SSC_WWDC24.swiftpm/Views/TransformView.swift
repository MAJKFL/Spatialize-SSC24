//
//  TransformTimelineView.swift
//
//
//  Created by Jakub Florek on 28/12/2023.
//

import SwiftUI

struct TransformView: View {
    @Environment(\.isEnabled) var isEnabled
    @Bindable var transformModel: TransformModel
    
    var isObstructed = false
    
    let rows = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: transformModel.type.iconName)
                        .padding(.top, isEnabled ? 0 : 2)
                        .opacity(isEnabled ? 1 : 0.8)
                    
                    Text(transformModel.type.displayName)
                        .opacity(isEnabled ? 1 : 0)
                }
                .font(.headline)
                .padding(.bottom, 5)
                
                LazyHGrid(rows: rows) {
                    ForEach(transformModel.doubleFields.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text("\(key):")
                            
                            Text(String(format: "%g", value))
                            
                            Spacer()
                        }
                    }
                    .monospaced()
                    .font(.subheadline)
                    
                    ForEach(transformModel.booleanFields.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text("\(key):")
                            
                            Text(value ? "Yes" : "No")
                            
                            Spacer()
                        }
                    }
                    .monospaced()
                    .font(.subheadline)
                }
                .opacity(isEnabled ? 1 : 0)
                
                Spacer()
            }
            .padding(isEnabled ? 5 : 0)
            
            Spacer()
        }
        .foregroundStyle(.white)
        .frame(width: transformModel.length, height: Constants.nodeViewHeight)
        .background(isObstructed ? Color.red.opacity(isEnabled ? 0.7 : 0) : Color.secondary.opacity(isEnabled ? 0.7 : 0))
        .clipShape(RoundedRectangle(cornerRadius: isEnabled ? 10 : 0))
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
    }
}

struct TransformNodeView: View {
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
