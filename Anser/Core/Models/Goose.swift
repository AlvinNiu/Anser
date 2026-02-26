//
//  Goose.swift
//  Anser
//
//  大鹅收藏模型
//

import Foundation
import SwiftUI

/// 大鹅稀有度等级
enum GooseRarity: String, Codable, CaseIterable, Comparable {
    case common = "common"       // 普通
    case rare = "rare"           // 稀有
    case epic = "epic"           // 史诗
    case legendary = "legendary" // 传说
    
    var displayName: String {
        switch self {
        case .common: return "普通"
        case .rare: return "稀有"
        case .epic: return "史诗"
        case .legendary: return "传说"
        }
    }
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .common:
            return [.gray.opacity(0.6), .gray]
        case .rare:
            return [.blue.opacity(0.6), .cyan]
        case .epic:
            return [.purple.opacity(0.6), .pink]
        case .legendary:
            return [.orange.opacity(0.6), .yellow, .orange]
        }
    }
    
    static func < (lhs: GooseRarity, rhs: GooseRarity) -> Bool {
        let order: [GooseRarity] = [.common, .rare, .epic, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// 大鹅模板（定义大鹅的基本信息）
struct GooseTemplate: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let rarity: GooseRarity
    let unlockCondition: String
    let emoji: String  // 使用emoji作为简单表示
    
    /// 背景故事
    var backstory: String {
        return "这是一只\(rarity.displayName)等级的\(name)，\(description)"
    }
}

/// 已解锁的大鹅（包含解锁信息）
struct UnlockedGoose: Identifiable, Codable {
    let id: UUID
    let templateID: String
    let unlockDate: Date
    let unlockThemeID: Int
    let score: Int
    
    var template: GooseTemplate? {
        GooseLibrary.getGoose(byID: templateID)
    }
}

/// 大鹅库
struct GooseLibrary {
    /// 所有大鹅模板
    static let allGeese: [GooseTemplate] = [
        // 普通大鹅
        GooseTemplate(
            id: "goose_fresh",
            name: "清新鹅",
            description: "喜欢吃水果蔬菜的健康大鹅",
            rarity: .common,
            unlockCondition: "通关「清新果蔬」主题",
            emoji: "🦢"
        ),
        GooseTemplate(
            id: "goose_sweet",
            name: "甜蜜鹅",
            description: "对甜点没有抵抗力的大鹅",
            rarity: .common,
            unlockCondition: "通关「甜蜜点心」主题",
            emoji: "🍬"
        ),
        GooseTemplate(
            id: "goose_breakfast",
            name: "早餐鹅",
            description: "早起享用美味早餐的大鹅",
            rarity: .common,
            unlockCondition: "通关「早餐时光」主题",
            emoji: "🍳"
        ),
        GooseTemplate(
            id: "goose_healthy",
            name: "健身鹅",
            description: "坚持健康饮食的自律大鹅",
            rarity: .common,
            unlockCondition: "通关「健康轻食」主题",
            emoji: "💪"
        ),
        
        // 稀有大鹅
        GooseTemplate(
            id: "goose_ocean",
            name: "海洋鹅",
            description: "来自深海的大鹅，身上有淡淡的咸味",
            rarity: .rare,
            unlockCondition: "通关「海洋盛宴」主题",
            emoji: "🌊"
        ),
        GooseTemplate(
            id: "goose_juice",
            name: "果汁鹅",
            description: "浑身散发着水果香气的大鹅",
            rarity: .rare,
            unlockCondition: "通关「果汁吧」主题",
            emoji: "🧃"
        ),
        GooseTemplate(
            id: "goose_weekend",
            name: "派对鹅",
            description: "喜欢在周末举办派对的大鹅",
            rarity: .rare,
            unlockCondition: "通关「周末聚餐」主题",
            emoji: "🎉"
        ),
        
        // 史诗大鹅
        GooseTemplate(
            id: "goose_tropical",
            name: "热带鹅",
            description: "从热带岛屿远道而来的大鹅",
            rarity: .epic,
            unlockCondition: "在「热带风情」主题获得3000分以上",
            emoji: "🌴"
        ),
        GooseTemplate(
            id: "goose_golden",
            name: "黄金鹅",
            description: "传说中的黄金大鹅，极其罕见",
            rarity: .epic,
            unlockCondition: "单日累计获得10000分",
            emoji: "✨"
        ),
        
        // 传说大鹅
        GooseTemplate(
            id: "goose_master",
            name: "大鹅大师",
            description: "登峰造极的传说大鹅，只有最强玩家才能捕获",
            rarity: .legendary,
            unlockCondition: "在不使用道具的情况下完美通关任意主题",
            emoji: "👑"
        ),
        GooseTemplate(
            id: "goose_rainbow",
            name: "彩虹鹅",
            description: "散发着七彩光芒的神秘大鹅",
            rarity: .legendary,
            unlockCondition: "收集所有其他大鹅后解锁",
            emoji: "🌈"
        ),
    ]
    
    /// 默认大鹅
    static let defaultGoose = allGeese[0]
    
    /// 根据ID获取大鹅
    static func getGoose(byID id: String) -> GooseTemplate? {
        return allGeese.first { $0.id == id }
    }
    
    /// 根据稀有度获取大鹅列表
    static func getGeese(byRarity rarity: GooseRarity) -> [GooseTemplate] {
        return allGeese.filter { $0.rarity == rarity }
    }
    
    /// 获取所有可解锁的大鹅数量
    static var totalCount: Int {
        allGeese.count
    }
}

/// 收藏册管理
@Observable
class CollectionManager: Codable {
    private(set) var unlockedGeese: [UnlockedGoose] = []
    
    /// 检查是否已解锁某只大鹅
    func isUnlocked(_ gooseID: String) -> Bool {
        return unlockedGeese.contains { $0.templateID == gooseID }
    }
    
    /// 解锁大鹅
    func unlockGoose(_ gooseID: String, themeID: Int, score: Int) {
        guard !isUnlocked(gooseID) else { return }
        
        let newGoose = UnlockedGoose(
            id: UUID(),
            templateID: gooseID,
            unlockDate: Date(),
            unlockThemeID: themeID,
            score: score
        )
        unlockedGeese.append(newGoose)
    }
    
    /// 获取解锁数量
    var unlockedCount: Int {
        unlockedGeese.count
    }
    
    /// 计算收集进度百分比
    var collectionProgress: Double {
        Double(unlockedCount) / Double(GooseLibrary.totalCount)
    }
    
    /// 按稀有度统计
    func countByRarity(_ rarity: GooseRarity) -> Int {
        unlockedGeese.compactMap { $0.template }
            .filter { $0.rarity == rarity }
            .count
    }
}
