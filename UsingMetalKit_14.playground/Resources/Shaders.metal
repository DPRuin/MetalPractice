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

float random(float2 p)
{
    return fract(sin(dot(p, float2(15.79, 81.93)) * 45678.9123));
}

float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float bottom = mix(random(i + float2(0)), random(i + float2(1.0, 0.0)), f.x);
    float top = mix(random(i + float2(0.0, 1.0)), random(i + float2(1)), f.x);
    float t = mix(bottom, top, f.y);
    return t;
}

float fbm(float2 uv)
{
    float sum = 0;
    float amp = 0.7;
    for(int i = 0; i < 4; ++i)
    {
        sum += noise(uv) * amp;
        uv += uv * 1.2;
        amp *= 0.4;
    }
    return sum;
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
    
    uv = fmod(uv + float2(timer * 0.2, 0), float2(width, height));
    float t = fbm( uv * 3 );
    output.write(distance < 0 ? float4(float3(t), 1) : float4(0), gid);
    
}


