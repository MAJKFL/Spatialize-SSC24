//
//  TransformEditView.swift
//
//
//  Created by Jakub Florek on 03/02/2024.
//

import SwiftUI
import SceneKit

struct TransformEditView: View {
    let project: Project
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
    
    var startPosition: SCNVector3 {
        let previousTransform = node.transforms
            .filter { trans in
                trans.start + trans.length < transformModel.start
            }
            .max(by: { $0.start + $0.length < $1.start + $1.length })
        
        if let previousTransform {
            return previousTransform.endPosition
        } else {
            return SCNVector3(x: 0, y: 13, z: 0)
        }
    }
    
    var body: some View {
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
                                .offset(x: (mockPlayheadOffset / transformModel.length) * geo.size.width - geo.size.width / 2)
                            
                            Rectangle()
                                .fill(.secondary)
                                .frame(height: 3)
                        }
                        .onReceive(timer) { publisher in
                            mockPlayheadOffset = (mockPlayheadOffset + (Double(project.bpm) / 60)).truncatingRemainder(dividingBy: transformModel.length)
                            
                            transformPreviewNode.position = transformModel.getPositionFor(playheadOffset: mockPlayheadOffset, source: startPosition, mockT: Float(mockPlayheadOffset / transformModel.length))
                        }
                    }
                    
                    Text(transformModel.type.displayDescription)
                }
                
                switch transformModel.type {
                case .move:
                    MoveTransformParameterEditView(transformModel: transformModel)
                case .orbit:
                    OrbitTransformParameterEditView(transformModel: transformModel)
                case .spiral:
                    SpiralTransformParameterEditView(transformModel: transformModel)
                }
            }
            .navigationTitle(transformModel.type.displayName)
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
            
            let geometry = lineBetween(vector: transformModel.getPositionFor(playheadOffset: 0, source: startPosition, mockT: Float(i) / 100), toVector: transformModel.getPositionFor(playheadOffset: 0, source: startPosition, mockT: Float(i + 1) / 100))
            
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

struct SpiralTransformParameterEditView: View {
    @Bindable var transformModel: TransformModel
    
    var body: some View {
        let startHeightBinding = Binding {
            transformModel.doubleFields["hStart"] ?? 0
        } set: { value in
            transformModel.doubleFields["hStart"] = value
        }
        
        let endHeightBinding = Binding {
            transformModel.doubleFields["hEnd"] ?? 0
        } set: { value in
            transformModel.doubleFields["hEnd"] = value
        }
        
        let revBinding = Binding {
            transformModel.doubleFields["rev"] ?? 0
        } set: { value in
            transformModel.doubleFields["rev"] = value
        }
        
        let baseRadiusBinding = Binding {
            transformModel.doubleFields["rBase"] ?? 0
        } set: { value in
            transformModel.doubleFields["rBase"] = value
        }
        
        Section("parameters") {
            HStack {
                Text("hStart: \(String(format: "%.1f", transformModel.doubleFields["hStart"] ?? 0))")
                
                Spacer()
                
                Text("0")
                
                Slider(value: startHeightBinding, in: 0...50)
                    .frame(width: 380)
                
                Text("50")
                    .frame(width: 30)
            }
            
            HStack {
                Text("hEnd: \(String(format: "%.1f", transformModel.doubleFields["hEnd"] ?? 0))")
                
                Spacer()
                
                Text("0")
                
                Slider(value: endHeightBinding, in: 0...50)
                    .frame(width: 380)
                
                Text("50")
                    .frame(width: 30)
            }
            
            HStack {
                Text("rev: \(String(format: "%.1f", transformModel.doubleFields["rev"] ?? 0))")
                
                Spacer()
            
                Text("1")
                
                Slider(value: revBinding, in: 1...10, step: 1)
                    .frame(width: 380)
                
                Text("10")
                    .frame(width: 30)
            }
            
            HStack {
                Text("rBase: \(String(format: "%.1f", transformModel.doubleFields["rBase"] ?? 0))")
                
                Spacer()
            
                Text("0")
                
                Slider(value: baseRadiusBinding, in: 0...50)
                    .frame(width: 380)
                
                Text("50")
                    .frame(width: 30)
            }
        }
    }
}

struct OrbitTransformParameterEditView: View {
    @Bindable var transformModel: TransformModel
    
    var body: some View {
        let heightBinding = Binding {
            transformModel.doubleFields["height"] ?? 0
        } set: { value in
            transformModel.doubleFields["height"] = value
        }
        
        let radiusBinding = Binding {
            transformModel.doubleFields["radius"] ?? 0
        } set: { value in
            transformModel.doubleFields["radius"] = value
        }
        
        let revBinding = Binding {
            transformModel.doubleFields["rev"] ?? 0
        } set: { value in
            transformModel.doubleFields["rev"] = value
        }
        
        let heightModBinding = Binding {
            transformModel.doubleFields["hMod"] ?? 0
        } set: { value in
            transformModel.doubleFields["hMod"] = value
        }
        
        Section("parameters") {
            HStack {
                Text("h: \(String(format: "%.1f", transformModel.doubleFields["height"] ?? 0))")
                
                Spacer()
                
                Text("0")
                
                Slider(value: heightBinding, in: 0...50)
                    .frame(width: 380)
                
                Text("50")
                    .frame(width: 30)
            }
            
            HStack {
                Text("r: \(String(format: "%.1f", transformModel.doubleFields["radius"] ?? 0))")
                
                Spacer()
                
                Text("0")
                
                Slider(value: radiusBinding, in: 0...50)
                    .frame(width: 380)
                
                Text("50")
                    .frame(width: 30)
            }
            
            HStack {
                Text("rev: \(String(format: "%.1f", transformModel.doubleFields["rev"] ?? 0))")
                
                Spacer()
            
                Text("1")
                
                Slider(value: revBinding, in: 1...10, step: 1)
                    .frame(width: 380)
                
                Text("10")
                    .frame(width: 30)
            }
            
            HStack {
                Text("hMod: \(String(format: "%.1f", transformModel.doubleFields["hMod"] ?? 0))")
                
                Spacer()
            
                Text("0")
                
                Slider(value: heightModBinding, in: 0...20)
                    .frame(width: 380)
                
                Text("20")
                    .frame(width: 30)
            }
        }
    }
}

struct MoveTransformParameterEditView: View {
    @Bindable var transformModel: TransformModel
    
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
}
