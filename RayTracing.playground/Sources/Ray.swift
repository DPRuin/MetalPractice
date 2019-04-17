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

// 射线是否撞到球体  ?????
func hit_sphere(center: float3, radius: Float, ray: Ray ) -> Float {
    let oc = ray.origin - center
    let a = dot(ray.direction, ray.direction) // 点积
    let b = 2.0 * dot(oc, ray.direction)
    let c = dot(oc, oc) - radius * radius
    let discriminant = b * b - 4 * a * c
    if discriminant < 0 {
        return -1.0
    } else {
        return (-b - Float(sqrt(Double(discriminant)))) / 2.0 * a
    }
    
}
