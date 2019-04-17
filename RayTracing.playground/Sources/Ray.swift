import Foundation
import simd

// 射线 结构体
struct Ray {
    var origin: float3 // 原点
    var direction: float3 // 方向
    init(origin:float3, direction: float3) {
        self.origin = origin
        self.direction = direction
    }
    
    func point_at_parameter(t: Float) -> float3 {
        return origin + t * direction
    }
}

// 获取颜色
func color(ray: Ray, world: Hitable) -> float3 {
    var rec = Hit_record()
    // Float.infinity 无穷
    if world.hit(ray: ray, tmin: 0, tmax: Float.infinity, rec: &rec) { // 撞到
        return 0.5 * float3(rec.normal.x + 1.0 , rec.normal.y + 1.0, rec.normal.z + 1.0)
    } else {
        let unit_direction = normalize(ray.direction)
        let t = 0.5 * (unit_direction.y + 1.0)
        return (1.0 - t) * float3(x: 1.0, y: 1.0, z: 1.0) + t * float3(x: 0.5, y: 0.7, z: 1.0)
    }
}
