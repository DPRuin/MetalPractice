import MetalKit
import PlaygroundSupport

let device = MTLCreateSystemDefaultDevice()
let frame = NSRect(x: 0, y: 0, width: 300, height: 300)

let delegate = MetalView()

let view = MTKView(frame: frame, device: device)
view.delegate = delegate
PlaygroundPage.current.liveView = view
