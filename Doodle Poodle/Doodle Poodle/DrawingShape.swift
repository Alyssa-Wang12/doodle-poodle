//
//  DrawingShape.swift
//  Doodle Poodle
//
//  Created by Wang, Alyssa on 4/29/24.
//

import SwiftUI

struct DrawingShape: Shape {
    let points: [CGPoint]
    let engine = DrawingEngine()
    func path(in rect: CGRect) -> Path {
        engine.createPath(for: points)
    }
}

