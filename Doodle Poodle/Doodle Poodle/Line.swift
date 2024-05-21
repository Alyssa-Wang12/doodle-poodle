//
//  Line.swift
//  Doodle Poodle
//
//  Created by Wang, Alyssa on 4/29/24.
//

import Foundation
import SwiftUI

struct Line: Identifiable {
    
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat

    let id = UUID()
}
