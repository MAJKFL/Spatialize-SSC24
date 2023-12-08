//
//  Node.swift
//
//
//  Created by Jakub Florek on 11/11/2023.
//

import Foundation
import SwiftData

@Model
class Transform {
    var id = UUID()
    var start: Int
    var finish: Int
    
    init(start: Int, finish: Int) {
        self.start = start
        self.finish = finish
    }
    
    var length: Int {
        finish - start
    }
}
