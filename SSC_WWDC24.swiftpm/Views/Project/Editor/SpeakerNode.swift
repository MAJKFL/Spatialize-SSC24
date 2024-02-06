//
//  SpeakerNode.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import SceneKit
import PHASE

class SpeakerNode: SCNNode {
    var nodeModel: Node!
    var phaseEngine: PHASEEngine!
    var phaseSource: PHASESource!
    
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
            position = currentTransform.getPositionFor(playheadOffset: offset, currentPosition: position, source: previousTransform?.endPosition ?? SCNVector3(0, 13, 0))
        } else {
            if let previousTransform {
                position = previousTransform.endPosition
            } else {
                position = SCNVector3(0, 13, 0)
            }
        }
        
        phaseSource.transform.columns.3 = simd_make_float4(position.x, position.y, position.z, 1.0)
    }
    
    deinit {
        phaseEngine.rootObject.removeChild(phaseSource)
    }
}
