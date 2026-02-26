//
//  GameRecord.swift
//  Anser
//
//  游戏记录模型
//

import Foundation

/// 游戏状态
enum GameState: String, Codable {
    case idle = "idle"           // 空闲/等待开始
    case playing = "playing"     // 游戏进行中
    case paused = "paused"       // 暂停
    case won = "won"             // 胜利
    case lost = "lost"           // 失败
}

/// 每日游戏记录
struct DailyRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let themeID: Int
    var bestScore: Int
    var attempts: Int
    var bestTimeRemaining: TimeInterval
    var isFirstTimePlayed: Bool = true
    
    init(date: Date = Date(), themeID: Int, bestScore: Int = 0, attempts: Int = 0, bestTimeRemaining: TimeInterval = 0) {
        self.id = UUID()
        self.date = date
        self.themeID = themeID
        self.bestScore = bestScore
        self.attempts = attempts
        self.bestTimeRemaining = bestTimeRemaining
    }
    
    /// 记录新的尝试
    mutating func recordAttempt(score: Int, timeRemaining: TimeInterval) {
        attempts += 1
        if score > bestScore {
            bestScore = score
        }
        if timeRemaining > bestTimeRemaining {
            bestTimeRemaining = timeRemaining
        }
        if attempts > 1 {
            isFirstTimePlayed = false
        }
    }
}

/// 玩家档案
struct PlayerProfile: Codable {
    var totalGamesPlayed: Int = 0
    var totalGeeseCaptured: Int = 0
    var highestScore: Int = 0
    var fastestWin: TimeInterval = 0
    var totalPlayTime: TimeInterval = 0
    var firstLaunchDate: Date?
    
    /// 更新最高分数
    mutating func updateHighestScore(_ score: Int) {
        if score > highestScore {
            highestScore = score
        }
    }
    
    /// 更新最快通关时间
    mutating func updateFastestWin(_ time: TimeInterval) {
        if fastestWin == 0 || time < fastestWin {
            fastestWin = time
        }
    }
    
    /// 增加游戏次数
    mutating func incrementGamesPlayed() {
        totalGamesPlayed += 1
    }
    
    /// 增加捕获大鹅数量
    mutating func incrementGeeseCaptured() {
        totalGeeseCaptured += 1
    }
    
    /// 增加游戏时间
    mutating func addPlayTime(_ time: TimeInterval) {
        totalPlayTime += time
    }
}

/// 游戏设置
struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hapticEnabled: Bool = true
    var shakeSensitivity: Double = 1.0  // 颠锅灵敏度 0.5-2.0
    var useButtonInsteadOfShake: Bool = false  // 使用按钮代替摇晃
    var dynamicFontSize: Bool = true
    
    /// 灵敏度范围检查
    var clampedSensitivity: Double {
        max(0.5, min(2.0, shakeSensitivity))
    }
}

/// 游戏统计数据（用于成就系统）
struct GameStatistics: Codable {
    var totalEliminations: Int = 0
    var totalShakes: Int = 0
    var perfectWins: Int = 0  // 不使用道具通关
    var consecutiveDays: Int = 0  // 连续游玩天数
    var lastPlayDate: Date?
    
    /// 更新连续天数
    mutating func updateStreak() {
        let calendar = Calendar.current
        if let lastDate = lastPlayDate {
            if calendar.isDateInYesterday(lastDate) {
                consecutiveDays += 1
            } else if !calendar.isDateInToday(lastDate) {
                consecutiveDays = 1
            }
        } else {
            consecutiveDays = 1
        }
        lastPlayDate = Date()
    }
}
