//
//  EditorViewRepresentable.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SwiftUI
import SceneKit

struct EditorViewRepresentable: UIViewRepresentable {
    let viewModel: EditorViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let view = EditorSceneView()
        view.setup(viewModel: viewModel)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
