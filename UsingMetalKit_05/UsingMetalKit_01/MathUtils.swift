//
//  MathUtils.swift
//  UsingMetalKit_01
//
//  Created by mac126 on 2019/4/16.
//  Copyright © 2019 mac126. All rights reserved.
//

import simd
/*
 vector_float4
 通过类似数组下标来访问向量的成员分量,具体作法是用 . 操作符和组件名称访问(x,y,z,w,或它们的组合).除了 .xyzw组件名外,
 下面的子向量也能通过:.lo / .hi(向量的前半部分和后半部分)来轻松访问,还有奇偶位的 .even / .odd子向量
 */
// 结构体 vertex data
struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

// 矩阵
struct Matrix {
    var m: [Float]
    
    init() {
        m = [1,0,0,0,
             0,1,0,0,
             0,0,1,0,
             0,0,0,1
        ]
    }
    
    // 平移
    func translationMatrix(_ matrix: Matrix, _ position: float3) -> Matrix {
        var matrix = matrix
        matrix.m[12] = position.x
        matrix.m[13] = position.y
        matrix.m[14] = position.z
        return matrix
    }
    
    // 缩放
    func scalingMatrix(_ matrix: Matrix, _ scale: Float) -> Matrix {
        var matrix = matrix
        matrix.m[0] = scale
        matrix.m[5] = scale
        matrix.m[10] = scale
        matrix.m[15] = 1.0
        return matrix
    }
    
    // 绕x，y，z轴旋转 下面不懂？？？？？？？
    func rotationMatrix(_ matrix: Matrix, _ rot: float3) -> Matrix {
        var matrix = matrix
        matrix.m[0] = cos(rot.y) * cos(rot.z)
        matrix.m[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z)
        matrix.m[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z)
        matrix.m[1] = cos(rot.y) * sin(rot.z)
        matrix.m[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z)
        matrix.m[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z)
        matrix.m[2] = -sin(rot.y)
        matrix.m[6] = cos(rot.y) * sin(rot.x)
        matrix.m[10] = cos(rot.x) * cos(rot.y)
        matrix.m[15] = 1.0
        
        return matrix
    }
    
    func modelMatrix(_ matrix: Matrix) -> Matrix {
        var matrix = matrix
        
        // 绕z轴旋转
        matrix = rotationMatrix(matrix, float3(0, 0, 0.1))
        
        // 向上移动半个屏幕的高度
        matrix = translationMatrix(matrix, float3(0, 0.5, 0))
        
        // 缩小原来的四分之一
        matrix = scalingMatrix(matrix, 0.25)
        
        return matrix
    }
}
