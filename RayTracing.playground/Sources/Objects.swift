import Foundation
import simd

// 结构体 表示hit事件
struct Hit_record {
    var t: Float // ?
    var p: float3 // ?
    var normal: float3 // ?
    
    init() {
        t = 0
        p = float3(0, 0, 0)
        normal = float3(0, 0, 0)
    }
}

// 协议
protocol Hitable {
    func hit(ray: Ray, tmin: Float, tmax: Float, rec: inout Hit_record) -> Bool
}

class Sphere: Hitable {
    
    var center: float3 = float3(x: 0, y: 0, z: 0)
    var radius: Float = 0.0
    
    init(center: float3, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    // tmin - tmax 之间的撞击  射线是否撞击到球体
    func hit(ray: Ray, tmin: Float, tmax: Float, rec: inout Hit_record) -> Bool {
        // ？？？
        let oc = ray.origin - center
        let a = dot(ray.direction, ray.direction) // 点积
        let b = dot(oc, ray.direction)
        let c = dot(oc, oc) - radius * radius
        let discriminant = b * b - a * c
        if discriminant > 0 {
            
            var t = (-b - Float(sqrt(Double(discriminant)))) / a
            if t < tmin {
                t = (-b + Float(sqrt(Double(discriminant)))) / a
            }
            
            if tmin < t && t < tmax {
                rec.t = t
                rec.p = ray.point_at_parameter(t: rec.t)
                rec.normal = (rec.p - center) / float3(radius)
                return true
            }
        }
        return false
    }
}

// 多个目标，多个球
class Hitable_list: Hitable {
    var list = [Hitable]()
    
    func add(h: Hitable) {
        list.append(h)
    }
    
    func hit(ray: Ray, tmin: Float, tmax: Float, rec: inout Hit_record) -> Bool {
        var hit_anything = false
        for item in list {
            if item.hit(ray: ray, tmin: tmin, tmax: tmax, rec: &rec) {
                hit_anything = true
            }
        }
        return hit_anything
    }
}


