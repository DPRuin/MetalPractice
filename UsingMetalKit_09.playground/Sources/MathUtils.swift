import simd
/*
 vector_float4
 通过类似数组下标来访问向量的成员分量,具体作法是用 . 操作符和组件名称访问(x,y,z,w,或它们的组合).除了 .xyzw组件名外,
 下面的子向量也能通过:.lo / .hi(向量的前半部分和后半部分)来轻松访问,还有奇偶位的 .even / .odd子向量
 */
// 结构体 vertex data
struct Vertex {
    var position: vector_float4
    var color: vector_float4
    init(position: vector_float4, color: vector_float4) {
        self.position = position
        self.color = color
    }
}

// 储存变换矩阵
struct Uniforms {
    var modelViewProjectionMatrix: matrix_float4x4
    init(modelViewProjectionMatrix: matrix_float4x4) {
        self.modelViewProjectionMatrix = modelViewProjectionMatrix
    }
}

// 平移
func translationMatrix(position: float3) -> matrix_float4x4 {
    let X = simd_float4(1, 0, 0, 0)
    let Y = simd_float4(0, 1, 0, 0)
    let Z = simd_float4(0, 0, 1, 0)
    let W = simd_float4(position.x, position.y, position.z, 1)
    return matrix_float4x4(columns: (X, Y, Z , W))
}

// 缩放
func scalingMatrix(scale: Float) -> matrix_float4x4 {
    let X = simd_float4(scale, 0, 0, 0)
    let Y = simd_float4(0, scale, 0, 0)
    let Z = simd_float4(0, 0, scale, 0)
    let W = simd_float4(0, 0, 0, 1)
    return matrix_float4x4(columns: (X, Y, Z, W))
}

// 绕x，y，z轴旋转 下面不懂？？？？？？？
func rotationMatrix(angle: Float, axis: simd_float3) -> matrix_float4x4 {
    var X = simd_float4(0, 0, 0, 0)
    X.x = axis.x * axis.x + (1 - axis.x * axis.x) * cos(angle)
    X.y = axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle)
    X.z = axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle)
    X.w = 0.0
    var Y = simd_float4(0, 0, 0, 0)
    Y.x = axis.x * axis.y * (1 - cos(angle)) + axis.z * sin(angle)
    Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * cos(angle)
    Y.z = axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle)
    Y.w = 0.0
    var Z = simd_float4(0, 0, 0, 0)
    Z.x = axis.x * axis.z * (1 - cos(angle)) - axis.y * sin(angle)
    Z.y = axis.y * axis.z * (1 - cos(angle)) + axis.x * sin(angle)
    Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * cos(angle)
    Z.w = 0.0
    let W = simd_float4(0, 0, 0, 1)
    return matrix_float4x4(columns:(X, Y, Z, W))
}

func modelMatrix() -> matrix_float4x4 {
    
    let scaled = scalingMatrix(scale: 0.5)
    let rotatedY = rotationMatrix(angle: .pi / 4, axis: float3(0, 1, 0))
    let rotatedX = rotationMatrix(angle: .pi / 4, axis: float3(1, 0, 0))
    
    return matrix_multiply(matrix_multiply(rotatedY, rotatedX), scaled)
}

// 视图矩阵
func viewMatrix() -> matrix_float4x4 {
    let cameraPosition = float3(0, 0, -3)
    return translationMatrix(position: cameraPosition)
}

// 投影矩阵 aspect? fovy?
func projectionMatrix(near: Float, far: Float, aspect: Float, fovy: Float ) -> matrix_float4x4 {
    let scaleY = 1 / tan(fovy * 0.5)
    let scaleX = scaleY / aspect
    let scaleZ = -(far + near) / (far - near)
    let scaleW = -2 * far * near / (far - near)
    
    let X = simd_float4(scaleX, 0, 0, 0)
    let Y = simd_float4(0, scaleY, 0, 0)
    let Z = simd_float4(0, 0, scaleZ, -1)
    let W = simd_float4(0, 0, scaleW, 0)
    
    return matrix_float4x4(columns:(X, Y, Z, W))
}

