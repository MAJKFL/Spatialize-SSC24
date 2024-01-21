//
//  ScenePreviewView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI
import SceneKit
import Combine

class SpeakerNode: SCNNode {
    var nodeModel: Node!
    
    init(nodeModel: Node) {
        super.init()
        self.nodeModel = nodeModel
        
        let sphereGeometry = SCNSphere(radius: 3)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = nodeModel.uiColor
        sphereGeometry.materials = [sphereMaterial]
        
        let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysicsBody.isAffectedByGravity = false
        
        self.name = nodeModel.id.uuidString
        self.position = SCNVector3(0, 4.5, 0)
        self.geometry = sphereGeometry
        self.physicsBody = spherePhysicsBody
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePosition(playheadOffset offset: Double) {
        let previousTransform = nodeModel.transforms
            .filter { trans in
                trans.start + trans.length < offset
            }
            .max(by: { $0.start + $0.length < $1.start + $1.length })
        
        if let currentTransform = nodeModel.transforms.first(where: { $0.start <= offset && $0.start + $0.length >= offset }) {
            position = currentTransform.getPositionFor(playheadOffset: offset, source: previousTransform?.endPosition ?? SCNVector3(0, 4.5, 0))
        } else {
            if let previousTransform {
                position = previousTransform.endPosition
            } else {
                position = SCNVector3(0, 4.5, 0)
            }
        }
    }
}

class EditorViewModel: ObservableObject {
    @Published var speakerNodes = [SpeakerNode]()
    
    private var cancellables = Set<AnyCancellable>()
    
    func setSpeakerNodes(for nodes: [Node]) {
        speakerNodes.removeAll(where: { speakerNode in
            !nodes.contains(where: { node in
                node.id.uuidString == speakerNode.name
            })
        })
        
        for node in nodes {
            guard !speakerNodes.contains(where: { $0.name == node.id.uuidString }) else { continue }
            
            let sphereNode = SpeakerNode(nodeModel: node)
            
            speakerNodes.append(sphereNode)
        }
    }
    
    func onNodeColorChange(_ node: Node) {
        speakerNodes.first(where: { $0.name == node.id.uuidString })?.geometry?.firstMaterial?.diffuse.contents = node.uiColor
    }
    
    func updateSpeakerNodePosition(playheadOffset offset: Double) {
        for speakerNode in speakerNodes {
            speakerNode.updatePosition(playheadOffset: offset)
        }
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
            }
            
            EditorView(viewModel: viewModel)
                .onAppear {
                    viewModel.setSpeakerNodes(for: project.nodes)
                }
                .onChange(of: project.nodes) { oldValue, newValue in
                    viewModel.setSpeakerNodes(for: newValue)
                }
                .onChange(of: playheadManager.offset) { oldValue, newValue in
                    viewModel.updateSpeakerNodePosition(playheadOffset: newValue)
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
            guard let node = node as? SpeakerNode else { continue }
            
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
        sphereMaterial.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
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
