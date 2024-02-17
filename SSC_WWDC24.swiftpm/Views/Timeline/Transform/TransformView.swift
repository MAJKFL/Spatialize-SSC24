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
    }
    
    /// Returns views offset withing a scroll view.
    private func getHeaderOffset(from geo: GeometryProxy) -> Double {
        guard geo.frame(in: .scrollView).minX < 250 && !isTemplate else { return 0 }
        
        return -geo.frame(in: .scrollView).minX + 250
    }
}
