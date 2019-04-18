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
// depth深度因子,这样当射线接触到物体时我们就能够通过递归调用这个函数来更精确地计算颜色
func color(ray: Ray, world: Hitable, depth: Int) -> float3 {
    // Float.infinity 无穷
    // tmin 由 0.0 改为 0.01 可以有效去除图片中的小的波纹
    if let rec = world.hit(ray: ray, tmin: 0.01, tmax: Float.infinity) {// 撞到
        var scattered = ray
        var attenuation = float3()
        if (depth < 50) && rec.material_pointer.scatter(ray_in: ray, rec: rec, attenuation: &attenuation, scattered: &scattered) {// depth 50
            return attenuation * color(ray: scattered, world: world, depth: depth + 1)
        } else {
            return float3(x: 0, y: 0, z: 0)
        }
    } else {
        let unit_direction = normalize(ray.direction)
        let t = 0.5 * (unit_direction.y + 1.0)
        return (1.0 - t) * float3(x: 1.0, y: 1.0, z: 1.0) + t * float3(x: 0.5, y: 0.7, z: 1.0)
    }
}

struct Camera {
    // 修复摄像机,这样我们从不同角度和距离来观察物体
    let lower_left_corner, horizontal, vertical, origin, u, v, w: float3
    var lens_radius: Float = 0.0
    
    init(lookFrom: float3, lookAt: float3, vup: float3, vfov: Float, aspect: Float) {
        
        let theta = vfov * Float(Double.pi) / 180
        let half_height = tan(theta / 2)
        let half_width = aspect * half_height
        origin = lookFrom
        w = normalize(lookFrom - lookAt)
        u = normalize(cross(vup, w))
        v = cross(w, u)
        lower_left_corner = origin - half_width * u - half_height * v - w
        horizontal = 2 * half_width * u
        vertical = 2 * half_height * v
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
