//
//  Theme.swift
//  Anser
//
//  主题模型
//

import Foundation
import SwiftUI

/// 主题分类
enum ThemeCategory: String, Codable, CaseIterable {
    case daily = "daily"           // 日常主题
    case seasonal = "seasonal"     // 季节主题
    case festival = "festival"     // 节日主题
    case cultural = "cultural"     // 文化主题
    
    var displayName: String {
        switch self {
        case .daily: return "日常"
        case .seasonal: return "季节"
        case .festival: return "节日"
        case .cultural: return "文化"
        }
    }
}

/// 主题配置
struct Theme: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let category: ThemeCategory
    let description: String
    let itemTypes: [ItemType]
    let backgroundColor: String  // 存储颜色hex值
    let accentColor: String
    let unlockGooseID: String    // 通关后解锁的大鹅ID
    let difficulty: Int          // 难度等级 1-5
    
    /// 背景色解析
    var themeBackgroundColor: Color {
        Color(hex: backgroundColor) ?? .blue
    }
    
    /// 主题色解析
    var themeAccentColor: Color {
        Color(hex: accentColor) ?? .orange
    }
    
    /// 获取主题的大鹅
    var unlockGoose: GooseTemplate {
        GooseLibrary.getGoose(byID: unlockGooseID) ?? GooseLibrary.defaultGoose
    }
}

/// 主题库
struct ThemeLibrary {
    /// 主题起始日期（2026年2月16日）
    static let startDate = DateComponents(year: 2026, month: 2, day: 16).date!
    
    /// 所有可用主题
    static let allThemes: [Theme] = [
        // 日常主题
        Theme(
            id: 0,
            name: "清新果蔬",
            category: .daily,
            description: "健康美味的水果蔬菜大集合",
            itemTypes: [.apple, .banana, .carrot, .grape, .kiwi, .lemon],
            backgroundColor: "#90EE90",
            accentColor: "#32CD32",
            unlockGooseID: "goose_fresh",
            difficulty: 1
        ),
        Theme(
            id: 1,
            name: "甜蜜点心",
            category: .daily,
            description: "令人心情愉悦的甜点时光",
            itemTypes: [.donut, .icecream, .juice, .hamburger, .apple, .banana],
            backgroundColor: "#FFB6C1",
            accentColor: "#FF69B4",
            unlockGooseID: "goose_sweet",
            difficulty: 1
        ),
        Theme(
            id: 2,
            name: "海洋盛宴",
            category: .daily,
            description: "来自大海的鲜美滋味",
            itemTypes: [.fish, .egg, .lemon, .juice, .carrot, .kiwi],
            backgroundColor: "#87CEEB",
            accentColor: "#4169E1",
            unlockGooseID: "goose_ocean",
            difficulty: 2
        ),
        Theme(
            id: 3,
            name: "早餐时光",
            category: .daily,
            description: "美好的一天从早餐开始",
            itemTypes: [.egg, .hamburger, .juice, .apple, .banana, .donut],
            backgroundColor: "#FFE4B5",
            accentColor: "#FFA500",
            unlockGooseID: "goose_breakfast",
            difficulty: 2
        ),
        Theme(
            id: 4,
            name: "热带风情",
            category: .seasonal,
            description: "热情洋溢的热带水果派对",
            itemTypes: [.banana, .kiwi, .lemon, .grape, .juice, .icecream],
            backgroundColor: "#FFD700",
            accentColor: "#FF8C00",
            unlockGooseID: "goose_tropical",
            difficulty: 3
        ),
        Theme(
            id: 5,
            name: "健康轻食",
            category: .daily,
            description: "轻盈健康的饮食选择",
            itemTypes: [.carrot, .kiwi, .fish, .egg, .apple, .grape],
            backgroundColor: "#98FB98",
            accentColor: "#228B22",
            unlockGooseID: "goose_healthy",
            difficulty: 2
        ),
        Theme(
            id: 6,
            name: "周末聚餐",
            category: .daily,
            description: "与家人朋友共享美食时光",
            itemTypes: [.hamburger, .donut, .icecream, .juice, .fish, .egg],
            backgroundColor: "#FFA07A",
            accentColor: "#FF6347",
            unlockGooseID: "goose_weekend",
            difficulty: 3
        ),
        Theme(
            id: 7,
            name: "果汁吧",
            category: .daily,
            description: "清凉解渴的果汁特调",
            itemTypes: [.juice, .apple, .carrot, .grape, .lemon, .kiwi],
            backgroundColor: "#F0E68C",
            accentColor: "#DAA520",
            unlockGooseID: "goose_juice",
            difficulty: 2
        ),
    ]
    
    /// 获取指定ID的主题
    static func getTheme(byID id: Int) -> Theme? {
        let index = id % allThemes.count
        guard index >= 0 && index < allThemes.count else { return nil }
        return allThemes[index]
    }
    
    /// 获取当前日期的主题
    static func getCurrentTheme() -> Theme {
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        let themeID = daysDiff % allThemes.count
        return getTheme(byID: themeID) ?? allThemes[0]
    }
    
    /// 获取指定日期的主题
    static func getTheme(for date: Date) -> Theme {
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        let themeID = daysDiff % allThemes.count
        return getTheme(byID: themeID) ?? allThemes[0]
    }
    
    /// 获取主题总数
    static var totalCount: Int {
        allThemes.count
    }
}

// MARK: - Color Hex Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


