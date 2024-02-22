//
//  EditorViewRepresentable.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SwiftUI
import SceneKit

/// SwiftUI 3D editor view representable.
struct EditorViewRepresentable: UIViewRepresentable {
    /// View model of the 3D editor.
    let viewModel: EditorViewModel
    
    /// Creates the SceneKit view.
    func makeUIView(context: Context) -> SCNView {
        let view = EditorSceneView()
        view.setup(viewModel: viewModel)
        return view
    }

    /// Updates the view.
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
