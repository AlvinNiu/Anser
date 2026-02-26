//
//  USDZModelLoader.swift
//  Anser
//
//  USDZ模型加载器 - 加载真实的3D模型文件
//

import SceneKit
import Foundation

/// USDZ模型加载器
class USDZModelLoader {
    
    /// 模型文件缓存
    private static var modelCache: [ItemType: SCNNode] = [:]
    
    /// 获取指定类型的模型
    /// - 优先加载USDZ文件，如果没有则返回程序化模型
    static func loadModel(for type: ItemType) -> SCNNode {
        // 检查缓存
        if let cached = modelCache[type] {
            return cached.copy() as! SCNNode
        }
        
        // 尝试加载USDZ文件
        if let usdzNode = loadUSDZFile(named: type.usdzFileName) {
            // 归一化大小
            normalizeModelSize(usdzNode)
            
            // 缓存并返回复制
            modelCache[type] = usdzNode
            return usdzNode.copy() as! SCNNode
        }
        
        // 如果没有USDZ文件，使用简化方案（彩色球体+文字）
        print("[USDZModelLoader] USDZ not found for \(type), using simple model")
        return SimpleItemFactory.createItem(for: type)
    }
    
    /// 加载USDZ文件
    private static func loadUSDZFile(named filename: String) -> SCNNode? {
        // 尝试从Bundle加载
        guard let url = Bundle.main.url(forResource: filename, withExtension: "usdz") else {
            return nil
        }
        
        do {
            let scene = try SCNScene(url: url, options: [.checkConsistency: true])
            
            // 创建包装节点（不能直接使用 scene.rootNode）
            let wrapperNode = SCNNode()
            wrapperNode.name = "usdz_\(filename)"
            
            // 复制 rootNode 的所有子节点到包装节点
            for childNode in scene.rootNode.childNodes {
                wrapperNode.addChildNode(childNode.copy() as! SCNNode)
            }
            
            return wrapperNode
        } catch {
            print("[USDZModelLoader] Failed to load \(filename).usdz: \(error)")
            return nil
        }
    }
    
    /// 归一化模型大小
    private static func normalizeModelSize(_ node: SCNNode) {
        // 计算包围盒
        let (minBox, maxBox) = node.boundingBox
        let width = maxBox.x - minBox.x
        let height = maxBox.y - minBox.y
        let depth = maxBox.z - minBox.z
        let maxDimension = max(width, max(height, depth))
        
        // 缩放到合适大小（目标大小约1.0单位）
        let targetSize: Float = 1.0
        let scale = targetSize / maxDimension
        node.scale = SCNVector3(scale, scale, scale)
        
        // 居中
        let centerX = (minBox.x + maxBox.x) / 2
        let centerY = (minBox.y + maxBox.y) / 2
        let centerZ = (minBox.z + maxBox.z) / 2
        node.position = SCNVector3(x: -centerX * scale, y: -centerY * scale, z: -centerZ * scale)
    }
    
    /// 预加载所有模型
    static func preloadModels() {
        for type in ItemType.allCases {
            _ = loadModel(for: type)
        }
    }
    
    /// 清除缓存
    static func clearCache() {
        modelCache.removeAll()
    }
}

// MARK: - ItemType USDZ文件名扩展
extension ItemType {
    var usdzFileName: String {
        switch self {
        case .apple: return "apple"
        case .banana: return "banana"
        case .carrot: return "carrot"
        case .donut: return "donut"
        case .egg: return "egg"
        case .fish: return "fish"
        case .grape: return "grape"
        case .hamburger: return "hamburger"
        case .icecream: return "icecream"
        case .juice: return "juice"
        case .kiwi: return "kiwi"
        case .lemon: return "lemon"
        }
    }
}


