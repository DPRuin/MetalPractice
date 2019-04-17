import Cocoa

let width = 800
let height = 400

let t0 = CFAbsoluteTimeGetCurrent()

let image = imageFromPixels(width: width, height: height)

let t1 = CFAbsoluteTimeGetCurrent()

// 计算代码运行时间
t1 - t0

image
