//
//  ItemModelFactory.swift
//  Anser
//
//  3D食物模型工厂 - 程序化生成各种食物模型（改进版）
//

import SceneKit

/// 3D食物模型工厂
class ItemModelFactory {
    
    /// 创建指定类型的食物模型
    static func createModel(for type: ItemType) -> SCNNode {
        let node = SCNNode()
        
        switch type {
        case .apple:
            node.addChildNode(createApple())
        case .banana:
            node.addChildNode(createBanana())
        case .carrot:
            node.addChildNode(createCarrot())
        case .donut:
            node.addChildNode(createDonut())
        case .egg:
            node.addChildNode(createEgg())
        case .fish:
            node.addChildNode(createFish())
        case .grape:
            node.addChildNode(createGrape())
        case .hamburger:
            node.addChildNode(createHamburger())
        case .icecream:
            node.addChildNode(createIceCream())
        case .juice:
            node.addChildNode(createJuice())
        case .kiwi:
            node.addChildNode(createKiwi())
        case .lemon:
            node.addChildNode(createLemon())
        }
        
        return node
    }
    
    // MARK: - 材质辅助方法
    
    /// 创建光滑材质
    private static func createSmoothMaterial(color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        material.roughness.contents = 0.2
        material.metalness.contents = 0.0
        material.lightingModel = .physicallyBased
        return material
    }
    
    /// 创建粗糙材质
    private static func createRoughMaterial(color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.darkGray
        material.shininess = 0.1
        material.roughness.contents = 0.8
        material.metalness.contents = 0.0
        material.lightingModel = .physicallyBased
        return material
    }
    
    /// 创建金属材质
    private static func createMetallicMaterial(color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white
        material.shininess = 0.9
        material.roughness.contents = 0.3
        material.metalness.contents = 0.5
        material.lightingModel = .physicallyBased
        return material
    }
    
    /// 创建半透明材质
    private static func createTranslucentMaterial(color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color.withAlphaComponent(0.7)
        material.specular.contents = UIColor.white
        material.shininess = 0.6
        material.roughness.contents = 0.1
        material.metalness.contents = 0.0
        material.transparency = 0.7
        material.lightingModel = .physicallyBased
        return material
    }
    
    // MARK: - 苹果
    private static func createApple() -> SCNNode {
        let node = SCNNode()
        
        // 苹果主体 - 使用光滑材质
        let body = SCNSphere(radius: 0.5)
        body.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.85, green: 0.15, blue: 0.1, alpha: 1.0))
        let bodyNode = SCNNode(geometry: body)
        bodyNode.scale = SCNVector3(1, 0.9, 1)
        node.addChildNode(bodyNode)
        
        // 苹果梗 - 粗糙材质
        let stem = SCNCylinder(radius: 0.04, height: 0.25)
        stem.firstMaterial = createRoughMaterial(color: UIColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0))
        let stemNode = SCNNode(geometry: stem)
        stemNode.position = SCNVector3(0, 0.5, 0)
        node.addChildNode(stemNode)
        
        // 叶子 - 粗糙材质
        let leaf = SCNCone(topRadius: 0.0, bottomRadius: 0.12, height: 0.25)
        leaf.firstMaterial = createRoughMaterial(color: UIColor(red: 0.2, green: 0.6, blue: 0.15, alpha: 1.0))
        let leafNode = SCNNode(geometry: leaf)
        leafNode.position = SCNVector3(0.1, 0.55, 0)
        leafNode.rotation = SCNVector4(0, 0, 1, Float.pi / 3)
        node.addChildNode(leafNode)
        
        return node
    }
    
    // MARK: - 香蕉
    private static func createBanana() -> SCNNode {
        let node = SCNNode()
        
        // 香蕉主体 - 弯曲的形状
        let body = SCNCapsule(capRadius: 0.22, height: 1.0)
        body.firstMaterial = createSmoothMaterial(color: UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))
        let bodyNode = SCNNode(geometry: body)
        bodyNode.eulerAngles = SCNVector3(0, 0, Float.pi / 5)
        node.addChildNode(bodyNode)
        
        // 香蕉顶部深色
        let tip = SCNSphere(radius: 0.06)
        tip.firstMaterial = createRoughMaterial(color: UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0))
        let tipNode = SCNNode(geometry: tip)
        tipNode.position = SCNVector3(-0.55, 0.3, 0)
        node.addChildNode(tipNode)
        
        return node
    }
    
    // MARK: - 胡萝卜
    private static func createCarrot() -> SCNNode {
        let node = SCNNode()
        
        // 胡萝卜主体 - 粗糙材质
        let body = SCNCone(topRadius: 0.04, bottomRadius: 0.3, height: 0.9)
        body.firstMaterial = createRoughMaterial(color: UIColor(red: 1.0, green: 0.45, blue: 0.05, alpha: 1.0))
        let bodyNode = SCNNode(geometry: body)
        node.addChildNode(bodyNode)
        
        // 胡萝卜叶子 - 多片
        for i in 0..<4 {
            let leaf = SCNCylinder(radius: 0.025, height: 0.35)
            leaf.firstMaterial = createRoughMaterial(color: UIColor(red: 0.15, green: 0.55, blue: 0.15, alpha: 1.0))
            let leafNode = SCNNode(geometry: leaf)
            let angle = Float(i) * (Float.pi / 2)
            leafNode.position = SCNVector3(cos(angle) * 0.08, 0.55, sin(angle) * 0.08)
            leafNode.rotation = SCNVector4(cos(angle), 0, sin(angle), Float.pi / 4)
            node.addChildNode(leafNode)
        }
        
        return node
    }
    
    // MARK: - 甜甜圈
    private static func createDonut() -> SCNNode {
        let node = SCNNode()
        
        // 甜甜圈主体 - 蛋糕质地
        let body = SCNTorus(ringRadius: 0.4, pipeRadius: 0.18)
        body.firstMaterial = createRoughMaterial(color: UIColor(red: 0.75, green: 0.55, blue: 0.35, alpha: 1.0))
        let bodyNode = SCNNode(geometry: body)
        node.addChildNode(bodyNode)
        
        // 糖霜 - 光滑材质
        let frosting = SCNTorus(ringRadius: 0.4, pipeRadius: 0.19)
        frosting.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.95, green: 0.5, blue: 0.75, alpha: 1.0))
        let frostingNode = SCNNode(geometry: frosting)
        frostingNode.position = SCNVector3(0, 0.04, 0)
        frostingNode.scale = SCNVector3(0.92, 0.92, 0.92)
        node.addChildNode(frostingNode)
        
        // 糖珠 - 多种颜色
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0),
            UIColor(red: 1.0, green: 0.9, blue: 0.1, alpha: 1.0)
        ]
        
        for i in 0..<8 {
            let sprinkle = SCNSphere(radius: 0.035)
            sprinkle.firstMaterial = createSmoothMaterial(color: colors[i % colors.count])
            let sprinkleNode = SCNNode(geometry: sprinkle)
            let angle = Float(i) * (Float.pi / 4)
            sprinkleNode.position = SCNVector3(cos(angle) * 0.4, 0.18, sin(angle) * 0.4)
            node.addChildNode(sprinkleNode)
        }
        
        return node
    }
    
    // MARK: - 鸡蛋
    private static func createEgg() -> SCNNode {
        let node = SCNNode()
        
        // 鸡蛋主体 - 光滑的椭球
        let body = SCNSphere(radius: 0.38)
        body.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.98, green: 0.94, blue: 0.88, alpha: 1.0))
        let bodyNode = SCNNode(geometry: body)
        bodyNode.scale = SCNVector3(0.8, 1.15, 0.8)
        node.addChildNode(bodyNode)
        
        return node
    }
    
    // MARK: - 鱼
    private static func createFish() -> SCNNode {
        let node = SCNNode()
        
        // 鱼身 - 光滑的鱼鳞质感
        let body = SCNCapsule(capRadius: 0.22, height: 0.85)
        body.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.35, green: 0.55, blue: 0.75, alpha: 1.0))
        let bodyNode = SCNNode(geometry: body)
        bodyNode.eulerAngles = SCNVector3(0, Float.pi / 2, 0)
        node.addChildNode(bodyNode)
        
        // 鱼尾 - 薄扇形
        let tail = SCNCone(topRadius: 0.0, bottomRadius: 0.28, height: 0.35)
        tail.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.35, green: 0.55, blue: 0.75, alpha: 1.0))
        let tailNode = SCNNode(geometry: tail)
        tailNode.position = SCNVector3(-0.55, 0, 0)
        tailNode.rotation = SCNVector4(0, 0, 1, Float.pi / 2)
        node.addChildNode(tailNode)
        
        // 鱼眼 - 黑色亮点
        let eye = SCNSphere(radius: 0.05)
        eye.firstMaterial = createSmoothMaterial(color: UIColor.black)
        let eyeNode = SCNNode(geometry: eye)
        eyeNode.position = SCNVector3(0.35, 0.08, 0.15)
        node.addChildNode(eyeNode)
        
        return node
    }
    
    // MARK: - 葡萄
    private static func createGrape() -> SCNNode {
        let node = SCNNode()
        
        // 葡萄材质 - 半透明光滑
        let grapeMaterial = createSmoothMaterial(color: UIColor(red: 0.45, green: 0.15, blue: 0.55, alpha: 1.0))
        grapeMaterial.roughness.contents = 0.15
        grapeMaterial.shininess = 0.9
        
        // 一串葡萄
        let positions: [(Float, Float, Float)] = [
            (0, 0, 0),
            (0.13, 0.05, 0), (-0.13, 0.05, 0), (0, 0.05, 0.13), (0, 0.05, -0.13),
            (0.1, -0.1, 0.1), (-0.1, -0.1, 0.1), (0.1, -0.1, -0.1), (-0.1, -0.1, -0.1),
            (0, -0.2, 0), (0.08, -0.15, 0), (-0.08, -0.15, 0)
        ]
        
        for pos in positions {
            let grape = SCNSphere(radius: 0.1)
            grape.firstMaterial = grapeMaterial
            let grapeNode = SCNNode(geometry: grape)
            grapeNode.position = SCNVector3(pos.0, pos.1, pos.2)
            node.addChildNode(grapeNode)
        }
        
        return node
    }
    
    // MARK: - 汉堡
    private static func createHamburger() -> SCNNode {
        let node = SCNNode()
        
        // 下层面包 - 柔软质地
        let bottomBun = SCNCylinder(radius: 0.45, height: 0.18)
        bottomBun.firstMaterial = createRoughMaterial(color: UIColor(red: 0.85, green: 0.65, blue: 0.35, alpha: 1.0))
        let bottomBunNode = SCNNode(geometry: bottomBun)
        bottomBunNode.position = SCNVector3(0, -0.25, 0)
        node.addChildNode(bottomBunNode)
        
        // 肉饼 - 粗糙质地
        let patty = SCNCylinder(radius: 0.44, height: 0.12)
        patty.firstMaterial = createRoughMaterial(color: UIColor(red: 0.35, green: 0.2, blue: 0.12, alpha: 1.0))
        let pattyNode = SCNNode(geometry: patty)
        pattyNode.position = SCNVector3(0, -0.12, 0)
        node.addChildNode(pattyNode)
        
        // 芝士 - 光滑奶酪
        let cheese = SCNBox(width: 0.85, height: 0.04, length: 0.85, chamferRadius: 0.02)
        cheese.firstMaterial = createSmoothMaterial(color: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0))
        let cheeseNode = SCNNode(geometry: cheese)
        cheeseNode.position = SCNVector3(0, -0.02, 0)
        node.addChildNode(cheeseNode)
        
        // 生菜 - 粗糙绿色
        let lettuce = SCNCylinder(radius: 0.48, height: 0.04)
        lettuce.firstMaterial = createRoughMaterial(color: UIColor(red: 0.25, green: 0.75, blue: 0.25, alpha: 1.0))
        let lettuceNode = SCNNode(geometry: lettuce)
        lettuceNode.position = SCNVector3(0, 0.06, 0)
        node.addChildNode(lettuceNode)
        
        // 上层面包 - 柔软质地
        let topBun = SCNSphere(radius: 0.45)
        topBun.firstMaterial = createRoughMaterial(color: UIColor(red: 0.85, green: 0.65, blue: 0.35, alpha: 1.0))
        let topBunNode = SCNNode(geometry: topBun)
        topBunNode.position = SCNVector3(0, 0.3, 0)
        topBunNode.scale = SCNVector3(1, 0.55, 1)
        node.addChildNode(topBunNode)
        
        // 芝麻
        for i in 0..<6 {
            let seed = SCNSphere(radius: 0.025)
            seed.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.95, green: 0.9, blue: 0.8, alpha: 1.0))
            let seedNode = SCNNode(geometry: seed)
            let angle = Float(i) * (Float.pi / 3)
            seedNode.position = SCNVector3(cos(angle) * 0.2, 0.52, sin(angle) * 0.2)
            node.addChildNode(seedNode)
        }
        
        return node
    }
    
    // MARK: - 冰淇淋
    private static func createIceCream() -> SCNNode {
        let node = SCNNode()
        
        // 蛋筒 - 锥形格子纹理（用圆锥模拟）
        let cone = SCNCone(topRadius: 0.35, bottomRadius: 0.08, height: 0.7)
        cone.firstMaterial = createRoughMaterial(color: UIColor(red: 0.9, green: 0.75, blue: 0.5, alpha: 1.0))
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, -0.35, 0)
        node.addChildNode(coneNode)
        
        // 冰淇淋球1 - 香草
        let scoop1 = SCNSphere(radius: 0.32)
        scoop1.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.95, green: 0.9, blue: 0.8, alpha: 1.0))
        let scoop1Node = SCNNode(geometry: scoop1)
        scoop1Node.position = SCNVector3(0, 0.15, 0)
        node.addChildNode(scoop1Node)
        
        // 冰淇淋球2 - 草莓
        let scoop2 = SCNSphere(radius: 0.28)
        scoop2.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.95, green: 0.7, blue: 0.75, alpha: 1.0))
        let scoop2Node = SCNNode(geometry: scoop2)
        scoop2Node.position = SCNVector3(0.12, 0.38, 0)
        node.addChildNode(scoop2Node)
        
        return node
    }
    
    // MARK: - 果汁
    private static func createJuice() -> SCNNode {
        let node = SCNNode()
        
        // 杯子 - 透明材质
        let cup = SCNCylinder(radius: 0.28, height: 0.7)
        cup.firstMaterial = createTranslucentMaterial(color: UIColor.white)
        let cupNode = SCNNode(geometry: cup)
        node.addChildNode(cupNode)
        
        // 果汁液体 - 橙色光滑
        let liquid = SCNCylinder(radius: 0.26, height: 0.6)
        liquid.firstMaterial = createSmoothMaterial(color: UIColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1.0))
        liquid.firstMaterial?.transparency = 0.9
        let liquidNode = SCNNode(geometry: liquid)
        liquidNode.position = SCNVector3(0, -0.05, 0)
        node.addChildNode(liquidNode)
        
        // 吸管 - 红色光滑
        let straw = SCNCylinder(radius: 0.035, height: 0.5)
        straw.firstMaterial = createSmoothMaterial(color: UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0))
        let strawNode = SCNNode(geometry: straw)
        strawNode.position = SCNVector3(0.08, 0.15, 0)
        strawNode.rotation = SCNVector4(0, 0, 1, Float.pi / 10)
        node.addChildNode(strawNode)
        
        return node
    }
    
    // MARK: - 猕猴桃
    private static func createKiwi() -> SCNNode {
        let node = SCNNode()
        
        // 猕猴桃主体 - 毛茸茸的棕色外皮
        let body = SCNSphere(radius: 0.42)
        let skinMaterial = createRoughMaterial(color: UIColor(red: 0.55, green: 0.45, blue: 0.25, alpha: 1.0))
        skinMaterial.roughness.contents = 0.9 // 非常粗糙
        body.firstMaterial = skinMaterial
        let bodyNode = SCNNode(geometry: body)
        node.addChildNode(bodyNode)
        
        // 切面 - 绿色果肉
        let inner = SCNCylinder(radius: 0.35, height: 0.08)
        inner.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.7, green: 0.85, blue: 0.25, alpha: 1.0))
        let innerNode = SCNNode(geometry: inner)
        innerNode.position = SCNVector3(0, 0.3, 0)
        innerNode.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
        node.addChildNode(innerNode)
        
        // 白色核心
        let core = SCNCylinder(radius: 0.08, height: 0.1)
        core.firstMaterial = createSmoothMaterial(color: UIColor(red: 0.95, green: 0.95, blue: 0.85, alpha: 1.0))
        let coreNode = SCNNode(geometry: core)
        coreNode.position = SCNVector3(0, 0.32, 0)
        coreNode.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
        node.addChildNode(coreNode)
        
        // 黑色籽 - 辐射状排列
        for i in 0..<12 {
            let seed = SCNSphere(radius: 0.018)
            seed.firstMaterial = createSmoothMaterial(color: UIColor.black)
            let seedNode = SCNNode(geometry: seed)
            let angle = Float(i) * (Float.pi / 6)
            let radius: Float = 0.18
            seedNode.position = SCNVector3(cos(angle) * radius, 0.34, sin(angle) * radius)
            node.addChildNode(seedNode)
        }
        
        return node
    }
    
    // MARK: - 柠檬
    private static func createLemon() -> SCNNode {
        let node = SCNNode()
        
        // 柠檬主体 - 光滑黄色
        let body = SCNSphere(radius: 0.42)
        body.firstMaterial = createSmoothMaterial(color: UIColor(red: 1.0, green: 0.9, blue: 0.15, alpha: 1.0))
        body.firstMaterial?.roughness.contents = 0.25
        let bodyNode = SCNNode(geometry: body)
        bodyNode.scale = SCNVector3(0.85, 1.12, 0.85)
        node.addChildNode(bodyNode)
        
        // 两端凸起 - 粗糙质地
        let tip1 = SCNSphere(radius: 0.06)
        tip1.firstMaterial = createRoughMaterial(color: UIColor(red: 0.75, green: 0.65, blue: 0.1, alpha: 1.0))
        let tip1Node = SCNNode(geometry: tip1)
        tip1Node.position = SCNVector3(0, 0.48, 0)
        node.addChildNode(tip1Node)
        
        let tip2 = SCNSphere(radius: 0.05)
        tip2.firstMaterial = createRoughMaterial(color: UIColor(red: 0.75, green: 0.65, blue: 0.1, alpha: 1.0))
        let tip2Node = SCNNode(geometry: tip2)
        tip2Node.position = SCNVector3(0, -0.48, 0)
        node.addChildNode(tip2Node)
        
        return node
    }
}
