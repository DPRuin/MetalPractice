
import Cocoa
import MetalKit

// 类public 需要在Sources外调用
public class MetalView: NSObject, MTKViewDelegate {
    
    /*
     MetalKit为原Metal框架带来大量改进和新特性
     MTKView 继承NSView/UIView，内置MetalLayer层，同时管理着帧缓冲器framebuffer
     以及渲染目标附件 render target attachments 还管理着绘制循环 draw loop
     
     有两种方法让我们的类支持绘制：
     1. 遵守MTKViewDelegate协议，并实现它的drawInView(:) 方法
     2. 继承MTKView ，并重写它的drawRect(:) 方法
     这里我们选择后者
     
     */
    
    public var device: MTLDevice?
    var cps: MTLComputePipelineState?
    var commandQueue: MTLCommandQueue?
    
    public override init() {
        super.init()
        registerShaders()
    }
    
    public func draw(in view: MTKView) {
        render(in: view)
    }
    
    private func registerShaders() {
        device = MTLCreateSystemDefaultDevice()
        guard let device = self.device else {
            return
        }
        commandQueue = device.makeCommandQueue()
        
        // 第二步 shader着色器
        // 绘制到屏幕的整个处理过程 pipeline管线
        
        // 函数（Shader）组成的库
        let path = Bundle.main.path(forResource: "Shaders", ofType: "metal")
        do {
            let input = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let library = try device.makeLibrary(source: input, options: nil)
            let kernel = library.makeFunction(name: "compute")
            // 创建计算管线状态
            cps = try device.makeComputePipelineState(function: kernel!)
        } catch let error {
            print("\(error)")
        }
    }
    
    private func render(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let commandQueue = self.commandQueue,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let command_encoder = commandBuffer.makeComputeCommandEncoder(),
            let cps = self.cps else {
            return
        }

        // 储存从命令编码器编译出的指令，当能执行完所有命令后Metal会通知应用程序
        
        /*
         命令编码器 将API命令编译成GPU硬件命令，共有三种编码器render(供图形渲染),compute(供数据并行处理)及blit(供资源复制操作).
         使用用一个设置了纹理的内核函数,创建线程组并指派它们干活.我们用MTLSize来设置线程组的维数,及每次计算调用中要执行的线程组的数量
         */
        
        command_encoder.setComputePipelineState(cps)
        command_encoder.setTexture(drawable.texture, index: 0)

        // 每个线程组中线程数量
        let threads = MTLSizeMake(8, 8, 1)
        // 每个格子中线程组数量
        let threadgroups = MTLSizeMake(drawable.texture.width / threads.width, drawable.texture.height / threads.height, 1)
        command_encoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threads)
        
        command_encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}

