//
//  BubbleModifier.swift
//  Amigos Chat Package
//
//  Created by Jarret on 29/10/2025.
//

import SwiftUI

public struct BubbleShape: Shape {

    public var topLeft: CGFloat
    public var topRight: CGFloat
    public var bottomLeft: CGFloat
    public var bottomRight: CGFloat

    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = max(0, topLeft)
        self.topRight = max(0, topRight)
        self.bottomLeft = max(0, bottomLeft)
        self.bottomRight = max(0, bottomRight)
    }

    public init(top: CGFloat, bottom: CGFloat) {
        self.init(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom)
    }

    public init(topLeading: CGFloat, topTrailing: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat) {
        self.init(topLeft: topLeading, topRight: topTrailing, bottomLeft: bottomLeading, bottomRight: bottomTrailing)
    }

    public init(cornerRadius: CGFloat) {
        self.init(topLeading: cornerRadius, topTrailing: cornerRadius, bottomLeading: cornerRadius, bottomTrailing: cornerRadius)
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        let topLeft = min(min(topLeft, height / 2), width / 2)
        let topRight = min(min(topRight, height / 2), width / 2)
        let bottomLeft = min(min(bottomLeft, height / 2), width / 2)
        let bottomRight = min(min(bottomRight, height / 2), width / 2)

        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY

        path.move(to: CGPoint(x: minX + topLeft, y: minY))

        path.addLine(to: CGPoint(x: maxX - topRight, y: minY))

        if topRight > 0 {
            path.addArc(
                center: CGPoint(x: maxX - topRight, y: minY + topRight),
                radius: topRight,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: maxX, y: minY))
        }

        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))

        if bottomRight > 0 {
            path.addArc(
                center: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight),
                radius: bottomRight,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: maxX, y: maxY))
        }

        path.addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))

        if bottomLeft > 0 {
            path.addArc(
                center: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft),
                radius: bottomLeft,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: minX, y: maxY))
        }

        path.addLine(to: CGPoint(x: minX, y: minY + topLeft))

        if topLeft > 0 {
            path.addArc(
                center: CGPoint(x: minX + topLeft, y: minY + topLeft),
                radius: topLeft,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        } else {
            path.addLine(to: CGPoint(x: minX, y: minY))
        }

        path.closeSubpath()
        return path
    }
}
