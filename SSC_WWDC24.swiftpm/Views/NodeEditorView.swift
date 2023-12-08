//
//  NodeEditorView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI

struct NodeEditorView: View {
    @Bindable var node: Node
    
    var transformCount: Int {
        node.transforms.count
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                LazyHStack(spacing: 89.1) {
                    ForEach(0..<10000) { x in
                        VStack {
                            Text(getBeatStr(x))
                                .font(.caption)
                                .foregroundStyle(.secondary.opacity(x % 4 == 0 ? 1 : 0.5))
                                .frame(width: 24)
                            
                            Rectangle()
                                .fill(.gray.opacity(x % 4 == 0 ? 1 : 0.3))
                                .frame(width: 1)
                        }
                        .padding(.leading, -12)
                    }
                    
                    Spacer()
                }
                .ignoresSafeArea(.container)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 0) {
                        ForEach(0..<node.transforms.count, id: \.self) { index in
                            if index != 0 && node.transforms[index].start - node.transforms[index - 1].finish != 0 {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: Double(node.transforms[index].start - node.transforms[index - 1].finish) * 101 + 0.25)
                            }
                            
                            TransformView(transform: node.transforms[index])
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.green.opacity(0.3))
                        .frame(height: 40)
                }
                .padding(.top, 21)
            }
            .padding(.leading)
        }
    }
    
    func getBeatStr(_ x: Int) -> String {
        return String(x / 4) + "." + String(x % 4)
    }
}

struct TransformView: View {
    @Bindable var transform: Transform
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.gray.opacity(0.3))
            .frame(width: Double(transform.length * 101) + 0.25)
    }
}
