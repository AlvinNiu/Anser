//
//  ItemModelFactory.swift
//  Anser
//
//  3D食物模型工厂 - 程序化生成各种食物模型
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
    
    // MARK: - 苹果
    private static func createApple() -> SCNNode {
        let node = SCNNode()
        
        // 苹果主体 - 球体稍微压扁
        let body = SCNSphere(radius: 0.5)
        body.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1.0)
        body.firstMaterial?.specular.contents = UIColor.white
        body.firstMaterial?.shininess = 0.3
        let bodyNode = SCNNode(geometry: body)
        bodyNode.scale = SCNVector3(1, 0.95, 1)
        node.addChildNode(bodyNode)
        
        // 苹果梗
        let stem = SCNCylinder(radius: 0.04, height: 0.3)
        stem.firstMaterial?.diffuse.contents = UIColor.brown
        let stemNode = SCNNode(geometry: stem)
        stemNode.position = SCNVector3(0, 0.55, 0)
        node.addChildNode(stemNode)
        
        // 叶子
        let leaf = SCNCone(topRadius: 0.0, bottomRadius: 0.15, height: 0.3)
        leaf.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 1.0)
        let leafNode = SCNNode(geometry: leaf)
        leafNode.position = SCNVector3(0.1, 0.6, 0)
        leafNode.rotation = SCNVector4(0, 0, 1, Float.pi / 4)
        node.addChildNode(leafNode)
        
        return node
    }
    
    // MARK: - 香蕉
    private static func createBanana() -> SCNNode {
        let node = SCNNode()
        
        // 香蕉主体 - 弯曲的形状用多个圆柱体模拟
        let body = SCNCapsule(capRadius: 0.25, height: 1.2)
        body.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        body.firstMaterial?.specular.contents = UIColor.white
        let bodyNode = SCNNode(geometry: body)
        bodyNode.eulerAngles = SCNVector3(0, 0, Float.pi / 6)
        node.addChildNode(bodyNode)
        
        // 香蕉两端深色
        let tip1 = SCNSphere(radius: 0.08)
        tip1.firstMaterial?.diffuse.contents = UIColor.brown
        let tip1Node = SCNNode(geometry: tip1)
        tip1Node.position = SCNVector3(-0.6, 0.35, 0)
        node.addChildNode(tip1Node)
        
        return node
    }
    
    // MARK: - 胡萝卜
    private static func createCarrot() -> SCNNode {
        let node = SCNNode()
        
        // 胡萝卜主体
        let body = SCNCone(topRadius: 0.05, bottomRadius: 0.35, height: 1.0)
        body.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1.0)
        body.firstMaterial?.specular.contents = UIColor.white
        let bodyNode = SCNNode(geometry: body)
        node.addChildNode(bodyNode)
        
        // 胡萝卜叶子
        for i in 0..<3 {
            let leaf = SCNCylinder(radius: 0.03, height: 0.4)
            leaf.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            let leafNode = SCNNode(geometry: leaf)
            let angle = Float(i) * (2 * Float.pi / 3)
            leafNode.position = SCNVector3(cos(angle) * 0.1, 0.6, sin(angle) * 0.1)
            leafNode.rotation = SCNVector4(cos(angle), 0, sin(angle), Float.pi / 6)
            node.addChildNode(leafNode)
        }
        
        return node
    }
    
    // MARK: - 甜甜圈
    private static func createDonut() -> SCNNode {
        let node = SCNNode()
        
        // 甜甜圈主体
        let body = SCNTorus(ringRadius: 0.45, pipeRadius: 0.2)
        body.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        let bodyNode = SCNNode(geometry: body)
        node.addChildNode(bodyNode)
        
        // 糖霜
        let frosting = SCNTorus(ringRadius: 0.45, pipeRadius: 0.22)
        frosting.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.5, blue: 0.7, alpha: 1.0)
        frosting.firstMaterial?.shininess = 0.5
        let frostingNode = SCNNode(geometry: frosting)
        frostingNode.position = SCNVector3(0, 0.05, 0)
        frostingNode.scale = SCNVector3(0.9, 0.9, 0.9)
        node.addChildNode(frostingNode)
        
        // 糖珠
        for i in 0..<6 {
            let sprinkle = SCNSphere(radius: 0.04)
            let colors: [UIColor] = [.red, .blue, .green, .yellow, .cyan, .orange]
            sprinkle.firstMaterial?.diffuse.contents = colors[i % colors.count]
            let sprinkleNode = SCNNode(geometry: sprinkle)
            let angle = Float(i) * (Float.pi / 3)
            sprinkleNode.position = SCNVector3(cos(angle) * 0.45, 0.15, sin(angle) * 0.45)
            node.addChildNode(sprinkleNode)
        }
        
        return node
    }
    
    // MARK: - 鸡蛋
    private static func createEgg() -> SCNNode {
        let node = SCNNode()
        
        // 鸡蛋主体 - 略微拉长的球体
        let body = SCNSphere(radius: 0.4)
        body.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
        body.firstMaterial?.specular.contents = UIColor.white
        body.firstMaterial?.shininess = 0.4
        let bodyNode = SCNNode(geometry: body)
        bodyNode.scale = SCNVector3(0.85, 1.1, 0.85)
        node.addChildNode(bodyNode)
        
        return node
    }
    
    // MARK: - 鱼
    private static func createFish() -> SCNNode {
        let node = SCNNode()
        
        // 鱼身
        let body = SCNCapsule(capRadius: 0.25, height: 1.0)
        body.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0)
        body.firstMaterial?.specular.contents = UIColor.white
        let bodyNode = SCNNode(geometry: body)
        bodyNode.eulerAngles = SCNVector3(0, Float.pi / 2, 0)
        node.addChildNode(bodyNode)
        
        // 鱼尾
        let tail = SCNCone(topRadius: 0.0, bottomRadius: 0.3, height: 0.4)
        tail.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0)
        let tailNode = SCNNode(geometry: tail)
        tailNode.position = SCNVector3(-0.6, 0, 0)
        tailNode.rotation = SCNVector4(0, 0, 1, Float.pi / 2)
        node.addChildNode(tailNode)
        
        // 鱼眼
        let eye = SCNSphere(radius: 0.06)
        eye.firstMaterial?.diffuse.contents = UIColor.black
        let eyeNode = SCNNode(geometry: eye)
        eyeNode.position = SCNVector3(0.4, 0.1, 0.15)
        node.addChildNode(eyeNode)
        
        return node
    }
    
    // MARK: - 葡萄
    private static func createGrape() -> SCNNode {
        let node = SCNNode()
        
        // 一串葡萄由多个小球组成
        let positions: [(Float, Float, Float)] = [
            (0, 0, 0), (0.15, 0, 0), (-0.15, 0, 0), (0, 0.15, 0), (0, -0.15, 0),
            (0.1, 0.1, 0.1), (-0.1, 0.1, 0.1), (0.1, -0.1, 0.1), (-0.1, -0.1, 0.1),
            (0, 0.2, 0), (0, -0.2, 0), (0.2, 0, 0), (-0.2, 0, 0)
        ]
        
        for pos in positions {
            let grape = SCNSphere(radius: 0.12)
            grape.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0)
            grape.firstMaterial?.specular.contents = UIColor.white
            grape.firstMaterial?.shininess = 0.4
            let grapeNode = SCNNode(geometry: grape)
            grapeNode.position = SCNVector3(pos.0, pos.1, pos.2)
            node.addChildNode(grapeNode)
        }
        
        return node
    }
    
    // MARK: - 汉堡
    private static func createHamburger() -> SCNNode {
        let node = SCNNode()
        
        // 下层面包
        let bottomBun = SCNCylinder(radius: 0.5, height: 0.2)
        bottomBun.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0)
        let bottomBunNode = SCNNode(geometry: bottomBun)
        bottomBunNode.position = SCNVector3(0, -0.2, 0)
        node.addChildNode(bottomBunNode)
        
        // 肉饼
        let patty = SCNCylinder(radius: 0.48, height: 0.15)
        patty.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1.0)
        let pattyNode = SCNNode(geometry: patty)
        pattyNode.position = SCNVector3(0, -0.05, 0)
        node.addChildNode(pattyNode)
        
        // 芝士
        let cheese = SCNBox(width: 0.9, height: 0.05, length: 0.9, chamferRadius: 0.02)
        cheese.firstMaterial?.diffuse.contents = UIColor.yellow
        let cheeseNode = SCNNode(geometry: cheese)
        cheeseNode.position = SCNVector3(0, 0.05, 0)
        node.addChildNode(cheeseNode)
        
        // 生菜
        let lettuce = SCNCylinder(radius: 0.52, height: 0.05)
        lettuce.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1.0)
        let lettuceNode = SCNNode(geometry: lettuce)
        lettuceNode.position = SCNVector3(0, 0.12, 0)
        node.addChildNode(lettuceNode)
        
        // 上层面包
        let topBun = SCNSphere(radius: 0.5)
        topBun.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0)
        let topBunNode = SCNNode(geometry: topBun)
        topBunNode.position = SCNVector3(0, 0.35, 0)
        topBunNode.scale = SCNVector3(1, 0.6, 1)
        node.addChildNode(topBunNode)
        
        // 芝麻
        for i in 0..<5 {
            let seed = SCNSphere(radius: 0.03)
            seed.firstMaterial?.diffuse.contents = UIColor.white
            let seedNode = SCNNode(geometry: seed)
            let angle = Float(i) * (2 * Float.pi / 5)
            seedNode.position = SCNVector3(cos(angle) * 0.2, 0.6, sin(angle) * 0.2)
            node.addChildNode(seedNode)
        }
        
        return node
    }
    
    // MARK: - 冰淇淋
    private static func createIceCream() -> SCNNode {
        let node = SCNNode()
        
        // 蛋筒
        let cone = SCNCone(topRadius: 0.4, bottomRadius: 0.1, height: 0.8)
        cone.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0)
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, -0.4, 0)
        node.addChildNode(coneNode)
        
        // 冰淇淋球1
        let scoop1 = SCNSphere(radius: 0.35)
        scoop1.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.7, blue: 0.5, alpha: 1.0)
        let scoop1Node = SCNNode(geometry: scoop1)
        scoop1Node.position = SCNVector3(0, 0.2, 0)
        node.addChildNode(scoop1Node)
        
        // 冰淇淋球2
        let scoop2 = SCNSphere(radius: 0.3)
        scoop2.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.5, blue: 0.4, alpha: 1.0)
        let scoop2Node = SCNNode(geometry: scoop2)
        scoop2Node.position = SCNVector3(0.15, 0.45, 0)
        node.addChildNode(scoop2Node)
        
        return node
    }
    
    // MARK: - 果汁
    private static func createJuice() -> SCNNode {
        let node = SCNNode()
        
        // 杯子
        let cup = SCNCylinder(radius: 0.3, height: 0.8)
        cup.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6)
        cup.firstMaterial?.transparency = 0.3
        let cupNode = SCNNode(geometry: cup)
        node.addChildNode(cupNode)
        
        // 果汁液体
        let liquid = SCNCylinder(radius: 0.28, height: 0.7)
        liquid.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        let liquidNode = SCNNode(geometry: liquid)
        liquidNode.position = SCNVector3(0, -0.05, 0)
        node.addChildNode(liquidNode)
        
        // 吸管
        let straw = SCNCylinder(radius: 0.04, height: 0.6)
        straw.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        let strawNode = SCNNode(geometry: straw)
        strawNode.position = SCNVector3(0.1, 0.2, 0)
        strawNode.rotation = SCNVector4(0, 0, 1, Float.pi / 8)
        node.addChildNode(strawNode)
        
        return node
    }
    
    // MARK: - 猕猴桃
    private static func createKiwi() -> SCNNode {
        let node = SCNNode()
        
        // 猕猴桃主体
        let body = SCNSphere(radius: 0.45)
        body.firstMaterial?.diffuse.contents = UIColor(red: 0.6, green: 0.7, blue: 0.3, alpha: 1.0)
        body.firstMaterial?.roughness.contents = 0.8
        let bodyNode = SCNNode(geometry: body)
        node.addChildNode(bodyNode)
        
        // 切面（显示内部）
        let inner = SCNCylinder(radius: 0.35, height: 0.1)
        inner.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.9, blue: 0.7, alpha: 1.0)
        let innerNode = SCNNode(geometry: inner)
        innerNode.position = SCNVector3(0, 0.3, 0)
        innerNode.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
        node.addChildNode(innerNode)
        
        // 黑色籽
        for i in 0..<8 {
            let seed = SCNSphere(radius: 0.02)
            seed.firstMaterial?.diffuse.contents = UIColor.black
            let seedNode = SCNNode(geometry: seed)
            let angle = Float(i) * (Float.pi / 4)
            seedNode.position = SCNVector3(cos(angle) * 0.15, 0.35, sin(angle) * 0.15)
            node.addChildNode(seedNode)
        }
        
        return node
    }
    
    // MARK: - 柠檬
    private static func createLemon() -> SCNNode {
        let node = SCNNode()
        
        // 柠檬主体 - 椭球体
        let body = SCNSphere(radius: 0.45)
        body.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        body.firstMaterial?.specular.contents = UIColor.white
        body.firstMaterial?.shininess = 0.4
        let bodyNode = SCNNode(geometry: body)
        bodyNode.scale = SCNVector3(0.9, 1.1, 0.9)
        node.addChildNode(bodyNode)
        
        // 两端凸起
        let tip1 = SCNSphere(radius: 0.08)
        tip1.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.7, blue: 0.1, alpha: 1.0)
        let tip1Node = SCNNode(geometry: tip1)
        tip1Node.position = SCNVector3(0, 0.5, 0)
        node.addChildNode(tip1Node)
        
        let tip2 = SCNSphere(radius: 0.06)
        tip2.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0.7, blue: 0.1, alpha: 1.0)
        let tip2Node = SCNNode(geometry: tip2)
        tip2Node.position = SCNVector3(0, -0.5, 0)
        node.addChildNode(tip2Node)
        
        return node
    }
}
