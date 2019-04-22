#include <metal_stdlib>

using namespace metal;
/*
 kernel function内核函数或compute shader计算着色器.
 你将经常听到它们两个的混合词变形词.内核是用于计算任务,
 也就是在GPU上进行大规模并行计算.例如:图像处理,科学模拟,等等.
 
 关于内核有一些重要特点:没有渲染管线,函数总是返回void,
 并且名字总是以kernel关键字开头,就像我们以前用过的前面带有vertex和vertex关键字的函数一样.
 */

// 内核函数或计算着色器
kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    texture2d<float, access::read> input [[texture(1)]],
                    constant float &timer [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]])
{
    int width = input.get_width();
    int height = input.get_height();
    float2 uv = float2(gid) / float2(width, height);
    uv = uv * 2.0 - 1.0;
    float radius = 0.5;
    float distance = length(uv) - radius;
    
    float4 color = input.read(gid);
    
    output.write(distance < 0 ? color : float4(0), gid);
    
}


