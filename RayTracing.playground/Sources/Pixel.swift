import Foundation
import CoreImage
import simd


// 像素
public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        r = red
        g = green
        b = blue
        a = 255
    }
}

// 像素渲染图片
public func imageFromPixels(width: Int, height: Int) -> CIImage {
    
    // 屏幕的所有像素，每个像素加入集合前，给每个像素创建一个ray射线并计算color颜色
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width * height)
    
    // 添加两个球
    let world = Hitable_list()
    var object = Sphere(center: float3(0, -100.5, -1), radius: 100,material: Lambertian(albedo: float3(x: 0.3, y: 0, z: 0)))
    world.add(h: object)
    
    object = Sphere(center: float3(x: 1, y: 0, z: -1), radius: 0.5, material: Metal(albedo: float3(x: 0.8, y: 0.6, z: 0.2), fuzz: 0.7))
    world.add(h: object)
    
    object = Sphere(center: float3(-1, 0, -1), radius: 0.5, material: Dielectric())
    world.add(h: object)
    
    object = Sphere(center: float3(0, 0, -1), radius: 0.5, material: Lambertian(albedo: float3(x: 0, y: 0.7, z: 0.3)))
    world.add(h: object)
    
    let cam = camera()
    for i in 0..<width {
        for j in 0..<height {
            /*
             解决球体边缘有锯齿问题
             注意到边缘的锯齿效应,这是因为我们没有对边缘像素使用任何颜色混合.
             要修复它,我们需要用随机生成值在一定范围内进行多次颜色采样,这样我们能把多个颜色混合在一起达到反锯齿效应的作用
             
             用随机生成值进行多次颜色采样
             
             每个像素有多个射线，这样就可以模拟漫反射
             */
            // 100 渲染时间在18秒，改为10 时间为1.8秒
            let ns = 10
            var col = float3()
            for _ in 0..<ns {
                // drand48 产生[0, 1]之间均匀分布的随机数
                let u = (Float(i) + Float(drand48())) / Float(width)
                let v = (Float(j) + Float(drand48())) / Float(height)
                let ray = cam.get_ray(u: u, v: v)
                col = col + color(ray: ray, world: world, depth: 0)
            }
            col = col / float3(Float(ns))
            
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            pixels[i + j * width] = pixel
        }
    }
    
    // 像素渲染图片
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let providerRef = CGDataProvider(data: NSData(bytes: pixels, length: pixels.count * MemoryLayout<Pixel>.size))
    
    let image = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: width * MemoryLayout<Pixel>.size, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
    
    return CIImage(cgImage: image!)
}


