//
//  ScenePreviewView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI
import SceneKit
import Combine

class EditorViewModel: ObservableObject {
    @Published var speakerNodes = [SCNNode]()
    
    private var cancellables = Set<AnyCancellable>()
    
    func setSpeakerNodes(for nodes: [Node]) {
        speakerNodes.removeAll(where: { speakerNode in
            !nodes.contains(where: { node in
                node.id.uuidString == speakerNode.name
            })
        })
        
        for node in nodes {
            guard !speakerNodes.contains(where: { $0.name == node.id.uuidString }) else { continue }
            
            let sphereGeometry = SCNSphere(radius: 3)
            
            let sphereMaterial = SCNMaterial()
            sphereMaterial.diffuse.contents = node.uiColor
            sphereGeometry.materials = [sphereMaterial]
            
            let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
            spherePhysicsBody.isAffectedByGravity = false
            
            let sphereNode = SCNNode(geometry: sphereGeometry)
            sphereNode.name = node.id.uuidString
            sphereNode.position = node.initLocation
            sphereNode.physicsBody = spherePhysicsBody
            
            speakerNodes.append(sphereNode)
        }
    }
    
    func onNodeColorChange(_ node: Node) {
        speakerNodes.first(where: { $0.name == node.id.uuidString })?.geometry?.firstMaterial?.diffuse.contents = node.uiColor
    }
    
    func onNodeInitLocationChange(_ node: Node) {
        speakerNodes.first(where: { $0.name == node.id.uuidString })?.position = node.initLocation
    }
}

struct ScenePreviewView: View {
    @Bindable var project: Project
    @State var playheadManager: PlayheadManager
    
    @StateObject var viewModel = EditorViewModel()
    
    var body: some View {
        ZStack {
            ForEach(project.nodes) { node in
                Text(node.name)
                    .onChange(of: node.color) { oldValue, newValue in
                        viewModel.onNodeColorChange(node)
                    }
                    .onChange(of: node.initLocation) { oldValue, newValue in
                        if playheadManager.isAtZero {
                            viewModel.onNodeInitLocationChange(node)
                        }
                    }
            }
            
            EditorView(viewModel: viewModel)
                .onAppear {
                    viewModel.setSpeakerNodes(for: project.nodes)
                }
                .onChange(of: project.nodes) { oldValue, newValue in
                    viewModel.setSpeakerNodes(for: newValue)
                }
        }
    }
}

struct EditorView: UIViewRepresentable {
    let viewModel: EditorViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let view = EditorSceneView()
        view.setup(viewModel: viewModel)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}

class EditorSceneView: SCNView {
    func setup(viewModel: EditorViewModel) {
        let scene = EditorScene()
        self.scene = scene
        scene.create(viewModel: viewModel)
        self.allowsCameraControl = true
        self.defaultCameraController.maximumVerticalAngle = 90
        self.defaultCameraController.minimumVerticalAngle = -15
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture))
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func pinchGesture(_ sender: UIPinchGestureRecognizer) {}
}

class EditorScene: SCNScene {
    var viewModel: EditorViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    func create(viewModel: EditorViewModel) {
        self.viewModel = viewModel
        
        background.contents = UIColor.black
        
        createListenerRepresentation()
        createPlane()
        createCamera()
        
        viewModel.$speakerNodes
            .sink { nodes in
                self.updateNodes(nodes)
            }
            .store(in: &cancellables)
    }
    
    private func updateNodes(_ nodes: [SCNNode]) {
        for node in rootNode.childNodes {
            if node.name == "ground" || node.name == "listener" || node.name == "camera" { continue }
            
            if !nodes.contains(where: { $0.name == node.name }) {
                node.removeFromParentNode()
            }
        }
        
        for node in nodes {
            if !rootNode.childNodes.contains(where: { $0.name == node.name }) {
                rootNode.addChildNode(node)
            }
        }
    }
    
    private func createCamera() {
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
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
        boxNode.name = "ground"
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
        sphereNode.name = "listener"
        sphereNode.position = SCNVector3(0, 4.5, 0)
        sphereNode.physicsBody = spherePhysicsBody
        
        rootNode.addChildNode(sphereNode)
    }
}
