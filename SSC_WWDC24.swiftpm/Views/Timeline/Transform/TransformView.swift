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
    
    @State private var showPreview = false
    
    /// Indicates whether the transform is obstructed by a different transform.
    var isObstructed = false
    /// Specifies whether the view should be a template.
    var isTemplate = false
    
    var backgroundColor = Color.gray
    
    /// Rows used for displaying the transform properties.
    private let rows = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                
                HStack(spacing: 5) {
                    Image(systemName: transformModel.type.iconName)
                        .foregroundStyle(.white)
                        .bold()
                    
                    Text(transformModel.type.displayName)
                        .foregroundStyle(.white)
                        .bold()
                    
                    if isTemplate {
                        Spacer()
                        
                        Button {
                            showPreview.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .popover(isPresented: $showPreview) {
                            TransformPreviewView(project: nil, node: nil, transformModel: transformModel, isEditable: false)
                                .frame(width: 600, height: 550)
                        }
                    }
                }
                .font(.title2)
                .offset(x: getHeaderOffset(from: geo))
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .frame(width: transformModel.length)
        .mask {
            Rectangle()
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(isObstructed ? Color.red.opacity(0.5) : backgroundColor.opacity(0.5))
                .strokeBorder(backgroundColor, lineWidth: 3)
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
