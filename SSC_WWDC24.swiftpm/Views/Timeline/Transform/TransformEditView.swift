//
//  TransformEditView.swift
//
//
//  Created by Jakub Florek on 03/02/2024.
//

import SwiftUI
import SceneKit

struct TransformEditView: View {
    let node: Node
    @Bindable var transformModel: TransformModel
    
    let transformPreviewNode: SCNNode = {
        let node = SCNNode()
        
        let sphereGeometry = SCNSphere(radius: 3)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.blue
        sphereGeometry.materials = [sphereMaterial]
        
        let spherePhysicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysicsBody.isAffectedByGravity = false
        
        node.position = SCNVector3(0, 10, 0)
        node.geometry = sphereGeometry
        node.physicsBody = spherePhysicsBody
        
        return node
    }()
    
    let transformPathPreviewNodes: [SCNNode] = {
        var nodes = [SCNNode]()
        
        for i in 0..<100 {
            let node = SCNNode()
            
            nodes.append(node)
        }
        
        return nodes
    }()
    
    @State private var mockPlayheadOffset: Double = 0
    
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let xBinding = Binding {
            transformModel.doubleFields["x"] ?? 0
        } set: { value in
            transformModel.doubleFields["x"] = value
        }
        
        let yBinding = Binding {
            transformModel.doubleFields["y"] ?? 0
        } set: { value in
            transformModel.doubleFields["y"] = value
        }
        
        let zBinding = Binding {
            transformModel.doubleFields["z"] ?? 0
        } set: { value in
            transformModel.doubleFields["z"] = value
        }
        
        let interpBinding = Binding {
            transformModel.booleanFields["interp"] ?? true
        } set: { value in
            transformModel.booleanFields["interp"] = value
        }

        NavigationView {
            Form {
                Section {
                    TransformPreviewViewRepresentable(previewNode: transformPreviewNode, pathPreviewNodes: transformPathPreviewNodes)
                        .frame(height: 300)
                        .listRowInsets(EdgeInsets())
                    
                    GeometryReader { geo in
                        ZStack {
                            Rectangle()
                                .fill(.primary)
                                .frame(width: 2)
                                .offset(x: mockPlayheadOffset - geo.size.width / 2)
                            
                            Rectangle()
                                .fill(.secondary)
                                .frame(height: 3)
                        }
                        .onReceive(timer) { publisher in
                            mockPlayheadOffset = (mockPlayheadOffset + 3).truncatingRemainder(dividingBy: geo.size.width)
                            
                            transformPreviewNode.position = transformModel.getPositionFor(playheadOffset: mockPlayheadOffset, source: SCNVector3(0, 13, 0), mockT: Float(mockPlayheadOffset / geo.size.width))
                        }
                    }
                    
                    Text("This transform moves the node to the specified coordinates. Possibly, linearly interpolates between the source and the destination.")
                }
                
                Section("parameters") {
                    HStack {
                        Text("x: \(String(format: "%.1f", transformModel.doubleFields["x"] ?? 0))")
                        
                        Spacer()
                        
                        Text("-50")
                            .frame(width: 30)
                        
                        Slider(value: xBinding, in: -50...50)
                            .frame(width: 380)
                        
                        Text("50")
                            .frame(width: 30)
                    }
                    
                    HStack {
                        Text("y: \(String(format: "%.1f", transformModel.doubleFields["y"] ?? 0))")
                        
                        Spacer()
                        
                        Text("0")
                            .frame(width: 30)
                        
                        Slider(value: yBinding, in: 0...50)
                            .frame(width: 380)
                        
                        Text("50")
                            .frame(width: 30)
                    }
                    
                    HStack {
                        Text("z: \(String(format: "%.1f", transformModel.doubleFields["z"] ?? 0))")
                        
                        Spacer()
                    
                        Text("-50")
                            .frame(width: 30)
                        
                        Slider(value: zBinding, in: -50...50)
                            .frame(width: 380)
                        
                        Text("50")
                            .frame(width: 30)
                    }
                    
                    Toggle("Interpolate", isOn: interpBinding)
                }
            }
            .navigationTitle("Move")
        }
        .onChange(of: transformModel.doubleFields) { oldValue, newValue in
            updatePathPreview()
        }
        .onChange(of: transformModel.booleanFields) { oldValue, newValue in
            updatePathPreview()
        }
        .onAppear {
            let material = SCNMaterial()
            material.diffuse.contents = node.uiColor
            
            transformPreviewNode.geometry?.materials = [material]
            updatePathPreview()
        }
        .tint(node.color)
    }
    
    func updatePathPreview() {
        for i in 0..<100 {
            let node = transformPathPreviewNodes[i]
            
            let geometry = lineBetween(vector: transformModel.getPositionFor(playheadOffset: 0, source: SCNVector3(0, 13, 0), mockT: Float(i) / 100), toVector: transformModel.getPositionFor(playheadOffset: 0, source: SCNVector3(0, 13, 0), mockT: Float(i + 1) / 100))
            
            let material = SCNMaterial()
            material.diffuse.contents = self.node.uiColor
            geometry.materials = [material]
            
            node.geometry = geometry
        }
    }
    
    func lineBetween(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
