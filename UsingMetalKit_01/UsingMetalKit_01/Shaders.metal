//
//  File.metal
//  UsingMetalKit_01
//
//  Created by mac126 on 2019/4/15.
//  Copyright © 2019 mac126. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/*
 shader着色器
 一个shader就是程序员能够用自定义函数来干预图形管线的地方.
 Metal提供了几种类型的着色器,但今天我们只看其中两种:
 vertex shader顶点着色器负责点的位置,fragment shader片段着色器负责点的颜色.
 
 Metal shading language着色语言 其实是C++
 
 */

// 结构体 CPU 和 GPU 来回传递数据
struct Vertex {
    float4 position [[position]];
    float4 color;
};

// 顶点着色器 负责点的位置
vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]] ) {
    return vertices[vid];
}

// 片段着色器 负责点的颜色
fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    // 每个顶点自带的实际颜色（通过vertex_buffer传递到GPU）
    return vert.color;
}
