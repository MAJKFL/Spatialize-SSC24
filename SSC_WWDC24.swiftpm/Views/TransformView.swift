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
        .background(Color.secondary.opacity(isEnabled ? 0.7 : 0))
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
    @Environment(\.modelContext) var context
    @Bindable var project: Project
    @Bindable var node: Node
    @Bindable var transformModel: TransformModel
    @Binding var selectedTransform: TransformModel?
    
    var body: some View {
        TransformView(transformModel: transformModel)
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
                        node.transforms.removeAll(where: { $0.id == transformModel.id })
                        context.delete(transformModel)
                    }
                }
            }
    }
}
