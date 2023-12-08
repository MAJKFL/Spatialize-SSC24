//
//  SwiftUIView.swift
//  
//
//  Created by Jakub Florek on 12/11/2023.
//

import SwiftUI

struct EdgeMaterialGradient: ViewModifier {
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    let size: Double
    
    var height: Double {
        startPoint == .bottom || startPoint == .top ? size : .infinity
    }
    
    var width: Double {
        startPoint == .bottom || startPoint == .top ? .infinity : size
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                VStack {
                    Spacer()
                    
                    
                    Rectangle()
                        .fill(Material.ultraThin)
                        .frame(maxWidth: width, maxHeight: height)
                        .mask {
                            LinearGradient(gradient: Gradient(stops: [
                                Gradient.Stop(color: .clear, location: 0),
                                Gradient.Stop(color: .black, location: 0.5)
                            ]), startPoint: startPoint, endPoint: endPoint)
                            .allowsHitTesting(false)
                        }
                }
            }
    }
}

extension View {
    func edgeMaterialGradient(startPoint: UnitPoint, endPoint: UnitPoint, size: Double) -> some View {
        modifier(EdgeMaterialGradient(startPoint: startPoint, endPoint: endPoint, size: size))
    }
}
