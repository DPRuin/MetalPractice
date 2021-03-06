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

struct Uniforms {
    float4x4 modelMatrix;
};

// 顶点着色器 负责点的位置
vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]] ) {
    float4x4 matrix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    
    return out;
}

// 片段着色器 负责点的颜色
fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    // 每个顶点自带的实际颜色（通过vertex_buffer传递到GPU）
    return vert.color;
}
