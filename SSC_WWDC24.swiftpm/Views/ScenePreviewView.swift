//
//  ScenePreviewView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI
import SceneKit

struct ScenePreviewView: View {
    var body: some View {
        SceneKitView()
    }
}

struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let view = EditorSceneView()
        view.setup()
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}

class EditorSceneView: SCNView {
    func setup() {
        let scene = EditorScene()
        self.scene = scene
        scene.create()
        self.allowsCameraControl = true
        self.defaultCameraController.maximumVerticalAngle = 90
        self.defaultCameraController.minimumVerticalAngle = -15
        
        var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func pinchGesture(_ sender: UIPinchGestureRecognizer) {}
}

class EditorScene: SCNScene {
    func create() {
        background.contents = UIColor.black
        
        createListenerRepresentation()
        createPlane()
        createCamera()
    }
    
    private func createCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3(x: 60, y: 50, z: 120)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(cameraNode)
    }
    
    private func createPlane() {
        let boxGeometry = SCNBox(width: 120, height: 0.5 , length: 120, chamferRadius: 0)
        
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIImage(named: "PlaneTexture")
        boxGeometry.materials = [boxMaterial]
        
        let boxPhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: boxGeometry))
        
        
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(0, 0, 0)
        boxNode.physicsBody = boxPhysicsBody
        
        rootNode.addChildNode(boxNode)
    }
    
    private func createListenerRepresentation() {
        let sphereGeometry = SCNSphere(radius: 4)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.green
        sphereGeometry.materials = [sphereMaterial]
        
        let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysicsBody.isAffectedByGravity = false
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = SCNVector3(0, 4.5, 0)
        sphereNode.physicsBody = spherePhysicsBody
        
        rootNode.addChildNode(sphereNode)
    }
}
