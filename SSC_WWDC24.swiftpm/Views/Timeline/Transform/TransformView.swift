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
    
    var isTemplate = false
    
    let rows = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                GeometryReader { geo in
                    HStack(spacing: 5) {
                        Image(systemName: transformModel.type.iconName)
                            .padding(.top, isEnabled ? 0 : 2)
                            .opacity(isEnabled ? 1 : 0.8)
                        
                        Text(transformModel.type.displayName)
                            .opacity(isEnabled ? 1 : 0)
                    }
                    .font(.headline)
                    .padding(.bottom, 5)
                    .offset(x: getHeaderOffset(from: geo))
                }
                
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
        .background(.ultraThinMaterial.opacity(isEnabled ? 1 : 0))
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
    
    func getHeaderOffset(from geo: GeometryProxy) -> Double {
        guard geo.frame(in: .scrollView).minX < 250 && !isTemplate else { return 0 }
        
        let offset = -geo.frame(in: .scrollView).minX + 250
        
        if offset + 12.0 > geo.size.width {
            return geo.size.width - 12.0
        } else {
            return offset
        }
    }
}
