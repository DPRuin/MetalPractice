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
                    uint2 gid [[thread_position_in_grid]])
{
    // 只简单地给纹理中的每个像素/位置设置了相同的颜色
    // output.write(float4(0, 0.5, 0.5, 1), gid);

    /* 拿到纹理的width和height,
    然后根据像素在纹理中的位置来计算red和green的值,然后将新颜色写入回纹理中
     */
    int width = output.get_width();
    int height = output.get_height();
    float red = float(gid.x) / float(width);
    float green = float(gid.y) / float(height);
    // output.write(float4(red, green, 0, 1), gid);

    /*
     这是在着色中很常用的技术,叫做distance function.
     我们使用length函数来确定像素是否在屏幕中心也就是我们圆的中心的0.5倍之内.
     注意,我们归一化了uv向量来匹配窗口坐标范围 [-1,1].
     最后,我们判断像素如果在内部就是黑色,否则就像原来一样,给它一个渐变色.
     */
    float2 uv = float2(gid) / float2(width, height);
    // uv = uv * 2.0 - 1.0;
    /*
     如何根据到圆的距离改变背景颜色,而不是仅根据像素的绝对位置.
     我们通过计算像素到圆的距离来改变透明通道的值
     */
    float distance = dist(uv, float2(0), 0.5);

    float xMax = width / height;
    float4 sun = float4(1, 0.7, 0, 1) * (1 - distance);
    float4 planet = float4(0);
    float radius = 0.5;
    float m = smootherstep(radius - 0.005, radius + 0.005, length(uv - float2(xMax-1, 0)));
    /*
     mix() 函数在x和y之间执行线性插补,并用a来调节权重.返回值用x * (1 - w) + y * w计算.
     在本例中,planet颜色和sun颜色用smootherstep作为权重值来插补
     */
    float4 pixel = mix(planet, sun, m);
    // output.write(pixel, gid);
    
    // ----类似蓝色风格线
//    float3 color = float3(0.7);
//    // fmod 计算x的对y取模后的余数
//    if (fmod(uv.x, 0.1) < 0.005 || fmod(uv.y, 0.1) < 0.005) color = float3(0, 0, 1);
//
//    float2 uv_ext = uv * 2.0 - 1.0;
//    // abs 取绝对值
//    if (abs(uv_ext.x) < 0.02 || abs(uv_ext.y) < 0.02) color = float3(1, 0, 0);
//    if (abs(uv_ext.x - uv_ext.y) < 0.02 || abs(uv_ext.x + uv_ext.y) < 0.02) color = float3(0, 1, 0);
//    output.write(float4(color, 1), gid);
    
    // ----Inigo Quilez艺术图像 ？？
    float2 cc = 1.1 * float2(0.5 * cos(0.1) - 0.25 * cos(0.2), 0.5 * sin(0.1) - 0.25 * sin(0.2) );
    float4 dmin = float4(1000.0);
    float2 z = (-1.0 + 2.0*uv) * float2(1.7, 1.0);
    for(int i=0; i<64; i++) {
        z = cc + float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
        dmin=min(dmin, float4(abs(0.0 + z.y + 0.5 * sin(z.x)), abs(1.0 + z.x + 0.5 * sin(z.y)), dot(z, z), length(fract(z) - 0.5)));
    }
    float3 color = float3(dmin.w);
    color = mix(color, float3(1.00, 0.80, 0.60), min(1.0, pow(dmin.x * 0.25, 0.20)));
    color = mix(color, float3(0.72, 0.70, 0.60), min(1.0, pow(dmin.y * 0.50, 0.50)));
    color = mix(color, float3(1.00, 1.00, 1.00), 1.0 - min(1.0, pow(dmin.z * 1.00, 0.15)));
    color = 1.25 * color * color;
    color *= 0.5 + 0.5 * pow(16.0 * uv.x * (1.0 - uv.x) * uv.y * (1.0 - uv.y), 0.15);
    output.write(float4(color, 1), gid);
}


