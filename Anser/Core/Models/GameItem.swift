//
//  GameItem.swift
//  Anser
//
//  游戏物品模型
//

import Foundation
import SwiftUI

/// 游戏物品类型
enum ItemType: String, Codable, CaseIterable {
    case apple = "apple"
    case banana = "banana"
    case carrot = "carrot"
    case donut = "donut"
    case egg = "egg"
    case fish = "fish"
    case grape = "grape"
    case hamburger = "hamburger"
    case icecream = "icecream"
    case juice = "juice"
    case kiwi = "kiwi"
    case lemon = "lemon"
    
    /// 获取类型的显示名称
    var displayName: String {
        switch self {
        case .apple: return "苹果"
        case .banana: return "香蕉"
        case .carrot: return "胡萝卜"
        case .donut: return "甜甜圈"
        case .egg: return "鸡蛋"
        case .fish: return "鱼"
        case .grape: return "葡萄"
        case .hamburger: return "汉堡"
        case .icecream: return "冰淇淋"
        case .juice: return "果汁"
        case .kiwi: return "猕猴桃"
        case .lemon: return "柠檬"
        }
    }
    
    /// 获取类型的图标/颜色标识
    var color: Color {
        switch self {
        case .apple: return .red
        case .banana: return .yellow
        case .carrot: return .orange
        case .donut: return .pink
        case .egg: return .white
        case .fish: return .blue
        case .grape: return .purple
        case .hamburger: return .brown
        case .icecream: return .cyan
        case .juice: return .green
        case .kiwi: return .green
        case .lemon: return .yellow
        }
    }
}

/// 游戏物品模型
@Observable
class GameItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ItemType
    var position: SIMD3<Float>
    var rotation: SIMD3<Float>
    var isSelected: Bool = false
    var isVisible: Bool = true
    var isEliminated: Bool = false
    var scale: Float = 1.0
    
    /// 唯一标识符（用于SceneKit节点关联）
    var nodeName: String {
        return "item_\(id.uuidString)"
    }
    
    init(id: UUID = UUID(), 
         type: ItemType,
         position: SIMD3<Float> = .zero,
         rotation: SIMD3<Float> = .zero,
         scale: Float = 1.0) {
        self.id = id
        self.type = type
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    static func == (lhs: GameItem, rhs: GameItem) -> Bool {
        lhs.id == rhs.id
    }
    
    /// 计算与另一个物品的相似度（用于消除判断）
    func canMatch(with other: GameItem) -> Bool {
        return type == other.type && !isEliminated && !other.isEliminated
    }
}

/// 槽位状态
enum SlotState {
    case empty
    case occupied(GameItem)
}

/// 待消除栏（3槽位）
@Observable
class EliminationTray {
    private(set) var slots: [GameItem?] = [nil, nil, nil]
    private(set) var items: [GameItem] = []
    
    var isFull: Bool {
        items.count >= 3
    }
    
    var count: Int {
        items.count
    }
    
    /// 添加物品到待消除栏
    /// - Returns: 如果形成三连则返回true
    @discardableResult
    func addItem(_ item: GameItem) -> Bool {
        guard !isFull else { return false }
        
        items.append(item)
        item.isSelected = true
        
        // 检查是否有三个相同类型
        let typeCounts = Dictionary(grouping: items, by: { $0.type })
        if let matchType = typeCounts.first(where: { $0.value.count >= 3 })?.key {
            // 找到三连，消除
            eliminateItems(of: matchType)
            return true
        }
        
        return false
    }
    
    /// 消除指定类型的物品
    private func eliminateItems(of type: ItemType) {
        items.removeAll { $0.type == type }
        // 被消除的物品标记为已消除
        // 注意：实际标记在GameSession中处理
    }
    
    /// 清空待消除栏
    func clear() {
        items.forEach { $0.isSelected = false }
        items.removeAll()
    }
    
    /// 移除指定物品
    func removeItem(_ item: GameItem) {
        items.removeAll { $0.id == item.id }
        item.isSelected = false
    }
}
