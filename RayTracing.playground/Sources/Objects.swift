import Foundation
import simd

// 结构体 表示hit事件
struct Hit_record {
    var t: Float        // ?
    var p: float3       // point
    var normal: float3  // 法线
    
    // 指向material颜色的指针
    var material_pointer: Material
    
    init(t: Float, p: float3, normal: float3, material_pointer: Material) {
        self.t = t
        self.p = p
        self.normal = normal
        self.material_pointer = material_pointer
    }
}

// 协议
protocol Hitable {
    func hit(ray: Ray, tmin: Float, tmax: Float) -> Hit_record?
}

class Sphere: Hitable {
    
    var center: float3 = float3(x: 0, y: 0, z: 0)
    var radius: Float = 0.0
    var material: Material
    
    init(center: float3, radius: Float, material: Material) {
        self.center = center
        self.radius = radius
        self.material = material
    }
    
    // tmin - tmax 之间的撞击  射线是否撞击到球体
    func hit(ray: Ray, tmin: Float, tmax: Float) -> Hit_record? {
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
                let point = ray.point_at_parameter(t: t)
                let normal = (point - center) / float3(radius)
                return Hit_record(t: t, p: point, normal: normal, material_pointer: material)
            }
        }
        return nil
    }
}

// 多个目标，多个球
class Hitable_list: Hitable {
    var list = [Hitable]()
    
    func add(h: Hitable) {
        list.append(h)
    }
    
    func hit(ray: Ray, tmin: Float, tmax: Float) -> Hit_record? {
        var hit_anything: Hit_record?
        for item in list {
            if let ahit = item.hit(ray: ray, tmin: tmin, tmax: tmax) {
                hit_anything = ahit
            }
        }
        return hit_anything
    }
}


