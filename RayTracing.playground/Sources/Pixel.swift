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

// 屏幕的所有像素
public func makePixelSet(width: Int, height: Int) -> ([Pixel], Int, Int) {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    var pixels = [Pixel](repeating: pixel, count: width * height)
    for i in 0..<width {
        for j in 0..<height {
            pixel = Pixel(red: 0, green: UInt8(Double(i * 255 / width)), blue: UInt8(Double(j * 255 / height)))
            pixels[i + j * width] = pixel
        }
    }
    
    return (pixels, width, height)
}

// 像素渲染图片
public func imageFromPixels(_ pixels: ([Pixel], width: Int, height: Int)) -> CIImage {
    
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let providerRef = CGDataProvider(data: NSData(bytes: pixels.0, length: pixels.0.count * MemoryLayout<Pixel>.size))
    
    let image = CGImage(width: pixels.1, height: pixels.2, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: pixels.1 * MemoryLayout<Pixel>.size, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
    
    return CIImage(cgImage: image!)
}

//struct Ray {
//    var origin: float3
//    var
//}
