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
    
    let lower_left_corner = float3(-2.0, 1.0, -1.0)
    let horizontal = float3(4.0, 0, 0)
    let vertical = float3(0, -2.0, 0)
    let origin = float3(0, 0, 0)
    
    let world = Hitable_list()
    var object = Sphere(center: float3(0, -100.5, -1), radius: 100)
    world.add(h: object)
    
    object = Sphere(center: float3(0, 0, -1), radius: 0.5)
    world.add(h: object)
    
    for i in 0..<width {
        for j in 0..<height {
            let u = Float(i) / Float(width)
            let v = Float(j) / Float(height)
            let ray = Ray(origin: origin, direction: lower_left_corner + u * horizontal + v * vertical)
            
            let col = color(ray: ray, world: world)
            
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            // pixel = Pixel(red: 0, green: UInt8(Double(i * 255 / width)), blue: UInt8(Double(j * 255 / height)))
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


