//
//  SpeakerNode.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SceneKit
import PHASE

class SpeakerNode: SCNNode {
    /// Speaker node model.
    var nodeModel: Node!
    /// Engine used for playback.
    var phaseEngine: PHASEEngine!
    /// Source of the speaker
    var phaseSource: PHASESource!
    
    /// Creates a new speaker.
    init(nodeModel: Node, phaseEngine: PHASEEngine, phaseSource: PHASESource) {
        super.init()
        self.nodeModel = nodeModel
        self.phaseEngine = phaseEngine
        self.phaseSource = phaseSource
        
        let sphereGeometry = SCNSphere(radius: 3)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = nodeModel.uiColor
        sphereGeometry.materials = [sphereMaterial]
        
        let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysicsBody.isAffectedByGravity = false
        
        self.name = nodeModel.id.uuidString
        self.geometry = sphereGeometry
        self.physicsBody = spherePhysicsBody
        
        let x: Float = cos(.pi * Float(nodeModel.position) / 5)
        let z: Float = sin(.pi * Float(nodeModel.position) / 5)
        
        self.position = SCNVector3(x, 13, z)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates position of the speaker node in the 3D editor and engine.
    func updatePosition(playheadOffset offset: Double, nodePosition: Int) {
        let previousTransform = nodeModel.transforms
            .filter { trans in
                trans.start + trans.length < offset
            }
            .max(by: { $0.start + $0.length < $1.start + $1.length })
        
        if let currentTransform = nodeModel.transforms.first(where: { $0.start <= offset && $0.start + $0.length >= offset }) {
            position = currentTransform.getPositionFor(playheadOffset: offset, currentPosition: position, source: previousTransform?.endPosition ?? SCNVector3(0, 13, 0))
        } else {
            if let previousTransform {
                position = previousTransform.endPosition
            } else {
                let x: Float = cos(.pi * Float(nodePosition) / 5)
                let z: Float = sin(.pi * Float(nodePosition) / 5)
                
                position = SCNVector3(x, 13, z)
            }
        }
        
        phaseSource.transform.columns.3 = simd_make_float4(position.x, position.y, position.z, 1.0)
    }
}
