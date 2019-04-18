import Cocoa

let width = 400
let height = 200

let t0 = CFAbsoluteTimeGetCurrent()

let image = imageFromPixels(width: width, height: height)

let t1 = CFAbsoluteTimeGetCurrent()

// 计算代码运行时间
t1 - t0

image
