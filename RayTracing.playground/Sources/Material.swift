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
struct Lambertian: Material {
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
struct Metal: Material {
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

/* 介电质,水或者某个玻璃物体
 当dielectric被射线撞击时,射线会分成两部分:一个反射(反弹)射线和一个折射(新增)射线
 注意attenuation衰减总是 1 ,因为dielectrics不吸收入射射线
 */
struct Dielectric: Material {
    var ref_index: Float = 1
    
    func scatter(ray_in: Ray, rec: Hit_record, attenuation: inout float3, scattered: inout Ray) -> Bool {
        // ??
        var reflect_prob: Float = 1
        var cosine: Float = 1
        
        // 先计算向外的法线,可以用射线和碰撞点的点积正负来判断
        var ni_over_nt: Float = 1
        var outward_normal: float3 = float3()
        let reflected = reflect(ray_in.direction, n: rec.normal) // 反射射线
        attenuation = float3(1.0, 1.0, 1.0)
        if dot(ray_in.direction, rec.normal) > 0 {
            outward_normal = -rec.normal
            ni_over_nt = ref_index
            cosine = ref_index * dot(ray_in.direction, rec.normal) / length(ray_in.direction)
        } else {
            outward_normal = rec.normal
            ni_over_nt = 1 / ref_index
            cosine = -dot(ray_in.direction, rec.normal) / length(ray_in.direction)
        }
        
        // 然后用它来计算折射射线.当它是nil时,我们反射射线,否则我们折射射线
        let refracted = refract(v: ray_in.direction, n: outward_normal, ni_over_nt: ni_over_nt)
        if refracted != nil { // 折射
            reflect_prob = schlick(cosine: cosine, ref_index)
            scattered = Ray(origin: rec.p, direction: refracted!)
        } else { // 反射
            scattered = Ray(origin: rec.p, direction: reflected)
            reflect_prob = 1.0
        }
        
        if Float(drand48()) < reflect_prob {
            scattered = Ray(origin: rec.p, direction: reflected)
        } else {
            scattered = Ray(origin: rec.p, direction: refracted!)
        }
        
        return true
    }
}


/// 折射,用斯涅尔定律 Snell’s law来描述 ,代码实现
///
/// - Parameters:
///   - v: 射入 射线
///   - n: 法线
///   - ni_over_nt: ？
/// - Returns: 折射射线
func refract(v: float3, n: float3, ni_over_nt: Float ) -> float3? {
    let uv = normalize(v)
    let dt = dot(uv, n)
    // ???不懂
    let discriminant = 1.0 - ni_over_nt * ni_over_nt * (1.0 - dt * dt)
    if discriminant > 0 {
        return ni_over_nt * (uv - n * dt) - n * sqrt(discriminant)
    }
    return nil
}

/*
 玻璃表面的反射率随角度变化而不同.
 当你垂直观察它时,反射率几乎没有.随着观察点角度变小,反射率升高,并且外界其它物体在玻璃表面的镜面反射越来越清楚.
 这个效应可以用Schlick 多项式近似来计算
 ?????
 */
func schlick(cosine: Float, _ index: Float) -> Float {
    var r0 = (1 - index) / (1 + index)
    r0 = r0 * r0
    return r0 + (1 - r0) * powf(1 - cosine, 5)
}


