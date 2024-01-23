//
//  EditorViewModel.swift
//  
//
//  Created by Jakub Florek on 23/01/2024.
//

import Foundation
import Combine

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
