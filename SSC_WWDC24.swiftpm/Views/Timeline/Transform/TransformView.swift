//
//  TransformTimelineView.swift
//
//
//  Created by Jakub Florek on 28/12/2023.
//

import SwiftUI

/// Universal transform representation.
struct TransformView: View {
    /// Specifies whether the view should be enabled.
    @Environment(\.isEnabled) var isEnabled
    /// Transform represented by this view.
    @Bindable var transformModel: TransformModel
    
    /// Indicates whether the transform is obstructed by a different transform.
    var isObstructed = false
    /// Specifies whether the view should be a template.
    var isTemplate = false
    
    /// Rows used for displaying the transform properties.
    private let rows = [GridItem(.flexible()), GridItem(.flexible())]
    
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
                            
                            Text(String(format: "%.0f", value))
                            
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
        .background {
            RoundedRectangle(cornerRadius: isEnabled ? 10 : 0)
                .fill(isObstructed ? Color.red.opacity(isEnabled ? 0.7 : 0) : Color.gray.opacity(isEnabled ? 0.7 : 0))
                .strokeBorder(Color.gray.opacity(isEnabled ? 1 : 0), lineWidth: 3)
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
    }
    
    /// Returns views offset withing a scroll view.
    private func getHeaderOffset(from geo: GeometryProxy) -> Double {
        guard geo.frame(in: .scrollView).minX < 250 && !isTemplate else { return 0 }
        
        let offset = -geo.frame(in: .scrollView).minX + 250
        
        if offset + 12.0 > geo.size.width {
            return geo.size.width - 12.0
        } else {
            return offset
        }
    }
}
