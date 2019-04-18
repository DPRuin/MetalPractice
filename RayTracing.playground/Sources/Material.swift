import simd

/*
 用更多不同材料来渲染球体
 产生一个扩散射线并用它的反射系数来计算计算吸收多少减弱多少
 attenuation 衰减
 
 */
protocol Material {
    func scatter(ray_in: Ray, rec: Hit_record, attenuation:inout float3, scattered:inout Ray) -> Bool
}

// Lambertian郎伯特 材质 : 射线随机扩散到其它方向
class Lambertian: Material {
    // 反射系数，衰减因子
    var albedo: float3
    init(albedo: float3) {
        self.albedo = albedo
    }
    func scatter(ray_in: Ray, rec: Hit_record, attenuation: inout float3, scattered: inout Ray) -> Bool {
        let target = rec.p + rec.normal + random_in_unit_sphere()
        scattered = Ray(origin: rec.p, direction: target - rec.p)
        attenuation = albedo
        return true
    }
}

// 金属材质：射线几乎以入射角相同的度数沿法线进行反射
class Metal: Material {
    /// 反射系数，衰减因子
    var albedo: float3
    /// 模糊因子：调节材料表面反射,从高反射率到几乎不反射都可调整
    var fuzz: Float
    init(albedo: float3, fuzz: Float) {
        self.albedo = albedo
        if fuzz < 1.0 {
            self.fuzz = fuzz
        } else {
            self.fuzz = 1.0
        }
    }
    func scatter(ray_in: Ray, rec: Hit_record, attenuation: inout float3, scattered: inout Ray) -> Bool {
        // reflect 返回入射向量和单位法线向量的反射方向
        let reflected = reflect(normalize(ray_in.direction), n: rec.normal)
        scattered = Ray(origin: rec.p, direction: reflected + fuzz * random_in_unit_sphere())
        attenuation = albedo
        return dot(scattered.direction, rec.normal) > 0
    }
}


