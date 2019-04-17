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
        let target = rec.p + rec.normal + random_in_unit_sphere()
        return 0.5 * color(ray: Ray(origin: rec.p, direction: target - rec.p), world: world)
    } else {
        let unit_direction = normalize(ray.direction)
        let t = 0.5 * (unit_direction.y + 1.0)
        return (1.0 - t) * float3(x: 1.0, y: 1.0, z: 1.0) + t * float3(x: 0.5, y: 0.7, z: 1.0)
    }
}

struct camera {
    
    let lower_left_corner: float3
    let horizontal: float3
    let vertical: float3
    let origin: float3
    
    init() {
        lower_left_corner = float3(-2.0, 1.0, -1.0)
        horizontal = float3(4.0, 0, 0)
        vertical = float3(0, -2.0, 0)
        origin = float3(0, 0, 0)
    }
    
    // 获取射线
    func get_ray(u: Float, v: Float) -> Ray {
        return Ray(origin: origin, direction: lower_left_corner + u * horizontal + v * vertical)
    }
    
}

/*
 漫反射材料反射出的光线方向是随机的
 返回随机的方向
 */
func random_in_unit_sphere() -> float3 {
    var p = float3()
    repeat {
        p = 2.0 * float3(Float(drand48()), Float(drand48()), Float(drand48()))
    } while dot(p, p) >= 1.0
    return p
}
