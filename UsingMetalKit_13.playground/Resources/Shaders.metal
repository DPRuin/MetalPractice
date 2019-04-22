#include <metal_stdlib>

using namespace metal;
/*
 kernel function内核函数或compute shader计算着色器.
 你将经常听到它们两个的混合词变形词.内核是用于计算任务,
 也就是在GPU上进行大规模并行计算.例如:图像处理,科学模拟,等等.
 
 关于内核有一些重要特点:没有渲染管线,函数总是返回void,
 并且名字总是以kernel关键字开头,就像我们以前用过的前面带有vertex和vertex关键字的函数一样.
 */

float dist(float2 point, float2 center, float radius)
{
    return length(point - center) - radius;
}

// 自定义smootherstep
float smootherstep(float e1, float e2, float x)
{
    /*
     给定clamp() 函数一个min值和max值,它会将点移到最接近的可用值.
     输入如果小了则采用min值,如果大了则采用max值,如果在中间则保留原值
     */
    x = clamp((x - e1) / (e2 - e1), 0.0, 1.0);
    return x * x * x * (x * (x * 6 - 15) + 10);
}

// 内核函数或计算着色器
kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    constant float &timer [[buffer(1)]],
                    constant float2 &mouse [[buffer(2)]],
                    uint2 gid [[thread_position_in_grid]])
{
    /* 拿到纹理的width和height,
    然后根据像素在纹理中的位置来计算red和green的值,然后将新颜色写入回纹理中
     */
    int width = output.get_width();
    int height = output.get_height();
    /*
     这是在着色中很常用的技术,叫做distance function.
     我们使用length函数来确定像素是否在屏幕中心也就是我们圆的中心的0.5倍之内.
     注意,我们归一化了uv向量来匹配窗口坐标范围 [-1,1].
     最后,我们判断像素如果在内部就是黑色,否则就像原来一样,给它一个渐变色.
     */
    float2 uv = float2(gid) / float2(width, height);
    uv = uv * 2.0 - 1.0;
    float radius = 0.5;
    float distance = length(uv) - radius;
    
    // z值，就可以获取球体的颜色
    float planet = sqrt(radius * radius - uv.x * uv.x - uv.y * uv.y);
    // z 值规范化为[0 1]
    planet = planet / radius;
    // 每个像素坐标的normal法
    float3 normal = normalize(float3(uv.x, uv.y, planet));
    
    // 给光源一个圆周运动，x和y都是按圆的参数方程从-1到1
    float3 source = normalize(float3(cos(timer), sin(timer), 1));
    // 法线乘以规格化光源，光照模型
    float light = dot(normal, source);
    
    output.write(distance < 0 ?  float4(float3(light), 1.0) : float4(0), gid);
    
}


