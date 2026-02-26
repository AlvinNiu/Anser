//
//  EmojiItemFactory.swift
//  Anser
//
//  Emoji贴图方案 - 使用Emoji作为3D物品的视觉标识
//  这是一个临时方案，直到获得真实的3D模型
//

import SceneKit

/// Emoji物品工厂 - 用彩色球体+Emoji贴图代替复杂3D模型
class EmojiItemFactory {
    
    /// 创建带有Emoji贴图的物品
    static func createEmojiItem(for type: ItemType) -> SCNNode {
        let node = SCNNode()
        
        // 创建基础球体
        let sphere = SCNSphere(radius: 0.5)
        sphere.segmentCount = 32
        
        // 根据类型设置颜色和Emoji
        let (color, emoji, emojiSize) = getStyle(for: type)
        
        // 设置材质
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white
        material.shininess = 0.6
        material.roughness.contents = 0.3
        material.lightingModel = .physicallyBased
        sphere.firstMaterial = material
        
        let sphereNode = SCNNode(geometry: sphere)
        node.addChildNode(sphereNode)
        
        // 添加Emoji贴图
        if let emojiImage = createEmojiImage(emoji: emoji, size: emojiSize) {
            let emojiPlane = SCNPlane(width: 0.8, height: 0.8)
            let emojiMaterial = SCNMaterial()
            emojiMaterial.diffuse.contents = emojiImage
            emojiMaterial.isDoubleSided = true
            emojiMaterial.transparency = 1.0
            emojiPlane.firstMaterial = emojiMaterial
            
            // 创建始终面向相机的Billboard节点
            let emojiNode = SCNNode(geometry: emojiPlane)
            emojiNode.position = SCNVector3(0, 0, 0.51)
            emojiNode.constraints = [SCNBillboardConstraint()]
            node.addChildNode(emojiNode)
            
            // 背面也添加Emoji
            let emojiNodeBack = SCNNode(geometry: emojiPlane)
            emojiNodeBack.position = SCNVector3(0, 0, -0.51)
            emojiNodeBack.rotation = SCNVector4(0, 1, 0, Float.pi)
            emojiNodeBack.constraints = [SCNBillboardConstraint()]
            node.addChildNode(emojiNodeBack)
        }
        
        return node
    }
    
    /// 获取每种类型的样式
    private static func getStyle(for type: ItemType) -> (UIColor, String, CGFloat) {
        switch type {
        case .apple:
            return (UIColor(red: 0.9, green: 0.15, blue: 0.1, alpha: 1.0), "🍎", 120)
        case .banana:
            return (UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0), "🍌", 120)
        case .carrot:
            return (UIColor(red: 0.95, green: 0.5, blue: 0.1, alpha: 1.0), "🥕", 120)
        case .donut:
            return (UIColor(red: 0.85, green: 0.6, blue: 0.4, alpha: 1.0), "🍩", 100)
        case .egg:
            return (UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0), "🥚", 120)
        case .fish:
            return (UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 1.0), "🐟", 120)
        case .grape:
            return (UIColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0), "🍇", 120)
        case .hamburger:
            return (UIColor(red: 0.85, green: 0.65, blue: 0.35, alpha: 1.0), "🍔", 120)
        case .icecream:
            return (UIColor(red: 0.95, green: 0.8, blue: 0.7, alpha: 1.0), "🍦", 120)
        case .juice:
            return (UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0), "🧃", 120)
        case .kiwi:
            return (UIColor(red: 0.6, green: 0.7, blue: 0.3, alpha: 1.0), "🥝", 120)
        case .lemon:
            return (UIColor(red: 1.0, green: 0.9, blue: 0.15, alpha: 1.0), "🍋", 120)
        }
    }
    
    /// 创建Emoji图片
    private static func createEmojiImage(emoji: String, size: CGFloat) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: size)
        label.textAlignment = .center
        label.backgroundColor = .clear
        
        // 计算大小
        let tempSize = emoji.boundingRect(
            with: CGSize(width: 200, height: 200),
            options: .usesLineFragmentOrigin,
            attributes: [.font: label.font!],
            context: nil
        ).size
        
        let renderSize = CGSize(width: ceil(tempSize.width), height: ceil(tempSize.height))
        label.frame = CGRect(origin: .zero, size: renderSize)
        
        UIGraphicsBeginImageContextWithOptions(renderSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        label.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
