//
//  Matrix.swift
//  SphereGame
//
//  Created by lisilong on 2018/4/4.
//  Copyright © 2018年 lisilong. All rights reserved.
//

import UIKit

struct Matrix {
    var column: NSInteger
    var row: NSInteger
    var matrix: [[CGFloat]]
    init(_ c: NSInteger,
         _ r: NSInteger,
         _ mat: [[CGFloat]] = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]) {
        column = c
        row = r
        matrix = mat
    }
}

struct MatrixTool {
    
    public static func pointMakeRotation(point: SpherePoint, direction dir: SpherePoint, angle: CGFloat) -> SpherePoint {
        guard angle != 0 else {
            return point
        }
        
        let t: [[CGFloat]] = [[point.x, point.y, point.z, 1]]
        var result: Matrix = Matrix(1, 4, t)
        
        if dir.z * dir.z + dir.y * dir.y != 0 {
            let cos1: CGFloat = dir.z / sqrt(dir.z * dir.z + dir.y * dir.y)
            let sin1: CGFloat = dir.y / sqrt(dir.z * dir.z + dir.y * dir.y)
            let t1 = [[1, 0, 0, 0], [0, cos1, sin1, 0], [0, -sin1, cos1, 0], [0, 0, 0, 1]]
            let m1 = Matrix(4, 4, t1)
            result = matrixMutiply(a: result, b: m1)
        }
        
        if dir.x * dir.x + dir.y * dir.y + dir.z * dir.z != 0 {
            let cos2: CGFloat = sqrt(dir.y * dir.y + dir.z * dir.z) / sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z);
            let sin2: CGFloat = -dir.x / sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z)
            let t2 = [[cos2, 0, -sin2, 0], [0, 1, 0, 0], [sin2, 0, cos2, 0], [0, 0, 0, 1]]
            let m2 = Matrix(4, 4, t2)
            result = matrixMutiply(a: result, b: m2)
        }
        
        let cos3 = cos(angle)
        let sin3 = sin(angle)
        let t3 = [[cos3, sin3, 0, 0], [-sin3, cos3, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
        let m3 = Matrix(4, 4, t3)
        result = matrixMutiply(a: result, b: m3)
        
        if dir.x * dir.x + dir.y * dir.y + dir.z * dir.z != 0 {
            let cos2 = sqrt(dir.y * dir.y + dir.z * dir.z) / sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z)
            let sin2 = -dir.x / sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z)
            let t2   = [[cos2, 0, sin2, 0], [0, 1, 0, 0], [-sin2, 0, cos2, 0], [0, 0, 0, 1]]
            let m2   = Matrix(4, 4, t2)
            result   = matrixMutiply(a: result, b: m2)
        }
        
        if dir.z * dir.z + dir.y * dir.y != 0 {
            let cos1 = dir.z / sqrt(dir.z * dir.z + dir.y * dir.y)
            let sin1 = dir.y / sqrt(dir.z * dir.z + dir.y * dir.y)
            let t1   = [[1, 0, 0, 0], [0, cos1, -sin1, 0], [0, sin1, cos1, 0], [0, 0, 0, 1]]
            let m1   = Matrix(4, 4, t1)
            result   = matrixMutiply(a: result, b: m1)
        }
        
        let resultPoint = SpherePoint(result.matrix[0][0], result.matrix[0][1], result.matrix[0][2])
        return resultPoint
    }
    
    private static func matrixMutiply(a: Matrix, b: Matrix) -> Matrix {
        var matrix: Matrix = Matrix(a.column, b.row)
        for i in 0..<a.column {
            for j in 0..<b.row {
                for k in 0..<a.row {
                    matrix.matrix[i][j] += a.matrix[i][k] * b.matrix[k][j]
                }
            }
        }
        return matrix
    }
}

