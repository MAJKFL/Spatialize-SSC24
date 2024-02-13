//
//  TransformTimelineView.swift
//
//
//  Created by Jakub Florek on 28/12/2023.
//

import SwiftUI

/// Universal transform representation.
struct TransformView: View {
    /// Transform represented by this view.
    @Bindable var transformModel: TransformModel
    
    /// Indicates whether the transform is obstructed by a different transform.
    var isObstructed = false
    /// Specifies whether the view should be a template.
    var isTemplate = false
    
    /// Rows used for displaying the transform properties.
    private let rows = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                
                HStack(spacing: 5) {
                    Image(systemName: transformModel.type.iconName)
                    
                    Text(transformModel.type.displayName)
                }
                .font(.title2)
                .bold()
                .offset(x: getHeaderOffset(from: geo))
                
                Spacer()
            }
        }
        .padding(.leading, 10)
        .foregroundStyle(.white)
        .frame(width: transformModel.length)
        .mask {
            Rectangle()
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(isObstructed ? Color.red.opacity(0.7) : Color.gray.opacity(0.7))
                .strokeBorder(Color.gray, lineWidth: 3)
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
        
        return -geo.frame(in: .scrollView).minX + 250
    }
}
