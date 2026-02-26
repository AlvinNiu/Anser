//
//  SimpleItemFactory.swift
//  Anser
//
//  简化方案：彩色球体 + 文字标签
//  最直观可靠的方案，无需外部模型文件
//

import SceneKit

/// 简化物品工厂 - 彩色球体 + 3D文字标签
class SimpleItemFactory {
    
    static func createItem(for type: ItemType) -> SCNNode {
        let node = SCNNode()
        
        // 创建球体主体
        let sphere = SCNSphere(radius: 0.55)
        sphere.segmentCount = 32
        
        // 获取样式
        let (color, name) = getStyle(for: type)
        
        // 设置材质 - 有光泽的塑料质感
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        material.roughness.contents = 0.2
        material.lightingModel = .physicallyBased
        sphere.firstMaterial = material
        
        let sphereNode = SCNNode(geometry: sphere)
        node.addChildNode(sphereNode)
        
        // 添加3D文字标签
        let textNode = createTextNode(text: name, color: .white)
        textNode.position = SCNVector3(0, 0, 0.56) // 放在球体正面
        textNode.scale = SCNVector3(0.15, 0.15, 0.15)
        node.addChildNode(textNode)
        
        // 背面也添加文字（从另一侧可见）
        let textNodeBack = createTextNode(text: name, color: .white)
        textNodeBack.position = SCNVector3(0, 0, -0.56)
        textNodeBack.rotation = SCNVector4(0, 1, 0, Float.pi)
        textNodeBack.scale = SCNVector3(0.15, 0.15, 0.15)
        node.addChildNode(textNodeBack)
        
        // 添加装饰环（让球体更有辨识度）
        let ring = SCNTorus(ringRadius: 0.4, pipeRadius: 0.03)
        ring.firstMaterial = SCNMaterial()
        ring.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        let ringNode = SCNNode(geometry: ring)
        ringNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        node.addChildNode(ringNode)
        
        return node
    }
    
    /// 创建3D文字节点
    private static func createTextNode(text: String, color: UIColor) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.3)
        textGeometry.font = UIFont.boldSystemFont(ofSize: 8)
        textGeometry.firstMaterial = SCNMaterial()
        textGeometry.firstMaterial?.diffuse.contents = color
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        textGeometry.firstMaterial?.shininess = 0.9
        
        let textNode = SCNNode(geometry: textGeometry)
        
        // 计算中心点使文字居中
        let (min, max) = textGeometry.boundingBox
        let textWidth = max.x - min.x
        let textHeight = max.y - min.y
        textNode.position = SCNVector3(x: -textWidth / 2, y: -textHeight / 2, z: 0)
        
        return textNode
    }
    
    /// 获取每种类型的样式
    private static func getStyle(for type: ItemType) -> (UIColor, String) {
        switch type {
        case .apple:
            return (UIColor(red: 0.9, green: 0.15, blue: 0.1, alpha: 1.0), "苹果")
        case .banana:
            return (UIColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1.0), "香蕉")
        case .carrot:
            return (UIColor(red: 0.95, green: 0.45, blue: 0.05, alpha: 1.0), "萝卜")
        case .donut:
            return (UIColor(red: 0.85, green: 0.55, blue: 0.75, alpha: 1.0), "甜圈")
        case .egg:
            return (UIColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1.0), "鸡蛋")
        case .fish:
            return (UIColor(red: 0.4, green: 0.6, blue: 0.85, alpha: 1.0), "鱼")
        case .grape:
            return (UIColor(red: 0.55, green: 0.2, blue: 0.65, alpha: 1.0), "葡萄")
        case .hamburger:
            return (UIColor(red: 0.75, green: 0.5, blue: 0.25, alpha: 1.0), "汉堡")
        case .icecream:
            return (UIColor(red: 0.95, green: 0.85, blue: 0.75, alpha: 1.0), "雪糕")
        case .juice:
            return (UIColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0), "果汁")
        case .kiwi:
            return (UIColor(red: 0.65, green: 0.75, blue: 0.25, alpha: 1.0), "奇异")
        case .lemon:
            return (UIColor(red: 1.0, green: 0.9, blue: 0.1, alpha: 1.0), "柠檬")
        }
    }
}
