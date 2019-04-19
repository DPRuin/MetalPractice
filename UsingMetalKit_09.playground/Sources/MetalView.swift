
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
    
    var vertexData: [Float]?
    var vertexBuffer: MTLBuffer?
    var rps: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    var uniform_buffer: MTLBuffer?
    var index_buffer: MTLBuffer!
    
    public var device: MTLDevice?
    
    public override init() {
        super.init()
        createBuffer()
        registerShaders()
    }
    
    public func draw(in view: MTKView) {
        render(in: view)
    }
    
    private func createBuffer() {
        
        // Device 对GPU的抽象，处理命令队列中渲染和计算命令
        device = MTLCreateSystemDefaultDevice()!
        
        guard let device = self.device else {
            return
        }
        
        // 命令队列：一个命令缓冲器的串行队列，确保储存的命令按顺序执行
        commandQueue = device.makeCommandQueue()!
        
        /*
         在屏幕上绘制几何体.所有的图形学教程比如和OpenGL相关的都会以Hello,Triangle类型程序开始,
         因为三角形是能绘制在屏幕上几何体中最简单的一个.
         它是2D图形学基本元素,图形学中其他所有对象都是三角形组成的,所以它是个很好的入门切入点.
         想象屏幕坐标系统拥有自己的贯穿屏幕中心的坐标轴,中心点坐标为 (0,0).相应的屏幕边缘应该为 -1 和 1 .
         让我们创建一组浮点数和一个缓冲器来保存三角形的顶点.
         
         第一步 储存顶点
         */
        let vertex_data: [Vertex] = [
            Vertex(position: [-1.0, -1.0, 1.0, 1.0], color: [1,0,0,1]),
            Vertex(position: [1.0, -1.0, 1.0, 1.0], color: [0,1,0,1]),
            Vertex(position: [1.0, 1.0, 1.0, 1], color: [0,0,1,1]),
            Vertex(position: [-1.0, 1.0, 1.0, 1], color: [1,1,1,1]),
            Vertex(position: [-1.0, -1.0, -1.0, 1.0], color: [1,0,0,1]),
            Vertex(position: [1.0, -1.0, -1.0, 1.0], color: [0,1,0,1]),
            Vertex(position: [1.0, 1.0, -1.0, 1], color: [0,0,1,1]),
            Vertex(position: [-1.0, 1.0, -1.0, 1], color: [1,1,1,1]),
        ]
        
        let index_data: [UInt16] = [
            0, 1, 2, 2, 3, 0,   // front
            
            1, 5, 6, 6, 2, 1,   // right
            
            3, 2, 6, 6, 7, 3,   // top
            
            4, 5, 1, 1, 0, 4,   // bottom
            
            4, 0, 3, 3, 7, 4,   // left
            
            7, 6, 5, 5, 4, 7,   // back
        ]
        
        // 计算数组大小
        let data_size = vertex_data.count * MemoryLayout<Vertex>.size
        vertexBuffer = device.makeBuffer(bytes: vertex_data, length: data_size, options: [])
        index_buffer = device.makeBuffer(bytes: index_data, length: index_data.count * MemoryLayout<UInt16>.size, options: [])
        
        uniform_buffer = device.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
        
        // 给缓冲器分配内存
        let bufferPointer = uniform_buffer?.contents()
        let projMatrix = projectionMatrix(near: 1, far: 100, aspect: 1, fovy: 1.1)
        // 视图矩阵 投影矩阵
        let modelViewProjectionMatrix =  matrix_multiply(projMatrix, matrix_multiply(viewMatrix(), modelMatrix()))
        
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        // memcpy c语言,缓冲器指针来传递全局变量
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
    }
    
    private func registerShaders() {
        
        guard let device = self.device else {
            return
        }
        // 第二步 shader着色器
        // 绘制到屏幕的整个处理过程 pipeline管线
        
        // 函数（Shader）组成的库
        let path = Bundle.main.path(forResource: "Shaders", ofType: "metal")
        

        let input: String?
        let library: MTLLibrary
        let vertex_func: MTLFunction
        let frag_func: MTLFunction
        do {
            input = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            library = try device.makeLibrary(source: input!, options: nil)
            vertex_func = library.makeFunction(name: "vertex_func")!
            frag_func = library.makeFunction(name: "fragment_func")!
            
            // 创建渲染管线描述符，来使用着色器
            let rpld = MTLRenderPipelineDescriptor()
            rpld.vertexFunction = vertex_func
            rpld.fragmentFunction = frag_func
            /*
             bgra8Unorm设置了像素格式,所以渲染管线中出来的所有东西的颜色组件都会是同一顺序(本例中按Blue,Green,Red,Alpha顺序),
             同时大小也会一致(本例中是8-bit的颜色值,范围从0到255)
             */
            rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
            // 利用上面的描述符，创建渲染管线状态
            rps = try device.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            print("\(error)")
        }
    }
    
    private func render(in view: MTKView) {
        
        guard let drawable = view.currentDrawable, let rpd = view.currentRenderPassDescriptor else {
            return
        }
        
        // 渲染目标描述，包含一组附件渲染目标
        // let rpd = MTLRenderPassDescriptor()
        let bleen = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1.0)
        
        /*
         colorAttachments[0] 是什么.为了设置rendering pipeline state渲染管线状态,Metal框架提供了3种类型的附件,来让我们写入:
         colorAttachments颜色附件
         depthAttachmentPixelFormat像素格式的深度附件
         stencilAttachmentPixelFormat像素格式的模板附件
         我们目前只关心如何储存颜色数据,colorAttachments是一个纹理数组,里面包含了绘制结果并将他们展示到屏幕上.
         我们目前只有一个这样的纹理-数组中的第一个元素(数组下标为0)
         */
        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
        rpd.colorAttachments[0].loadAction = .clear
        
        guard let commandQueue = self.commandQueue  else {
            return
        }
        // 储存从命令编码器编译出的指令，当能执行完所有命令后Metal会通知应用程序
        let commandBuffer = commandQueue.makeCommandBuffer()!
        /*
         命令编码器 将API命令编译成GPU硬件命令，共有三种编码器render(供图形渲染),compute(供数据并行处理)及blit(供资源复制操作).
         目前我们只需关注render command encoder渲染命令编码器
         
         Metal框架包含若干对象：
         states状态-例如混合和深度
         shaders着色器-源码
         resources资源-纹理和数据缓冲器
         
         Render Command Encoder (RCE)渲染命令编码器为每一个单独的渲染通道提供硬件命令,
         这意味着所有的渲染都被送入一个单一的framebuffer帧缓冲器对象中(目标集合中).
         如果另一个帧缓冲器需要被渲染,会创建一个新的RCE.RCE会为从graphics popeline图形管线中给出的vertex顶点和fragment片段确定状态,
         并且插入resources,state changes和draw calls.利用RCE的一个优点是无需绘制时编译;
         应用可以决定编译和状态检查何时发生,这样为程序员提供了很大的性能优势.
         */
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)!
        // 命令编码器获取三角形
        guard let rps = self.rps else {
            return
        }
        encoder.setRenderPipelineState(rps)
        // 设置正面模式
        encoder.setFrontFacing(.counterClockwise)
        // 设置裁剪模式
        encoder.setCullMode(.back)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // setVertexBuffer 在drawPrimitives 之前，不然会报错
        encoder.setVertexBuffer(uniform_buffer, offset: 0, index: 1)
        // encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        encoder.drawIndexedPrimitives(type: .triangle, indexCount: index_buffer.length / MemoryLayout<UInt16>.size, indexType: MTLIndexType.uint16, indexBuffer: index_buffer, indexBufferOffset: 0)
        
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}

