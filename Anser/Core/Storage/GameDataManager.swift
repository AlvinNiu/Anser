//
//  GameDataManager.swift
//  Anser
//
//  游戏数据管理器：持久化存储
//

import Foundation
import SwiftData

/// 游戏数据管理器
@Observable
class GameDataManager {
    static let shared = GameDataManager()
    
    // MARK: - 存储键值
    private enum Keys {
        static let playerProfile = "playerProfile"
        static let dailyRecords = "dailyRecords"
        static let collectionManager = "collectionManager"
        static let gameSettings = "gameSettings"
        static let gameStatistics = "gameStatistics"
        static let lastPlayedThemeID = "lastPlayedThemeID"
    }
    
    // MARK: - 数据属性
    private(set) var playerProfile: PlayerProfile
    private(set) var collectionManager: CollectionManager
    private(set) var gameSettings: GameSettings
    private(set) var gameStatistics: GameStatistics
    private(set) var dailyRecords: [String: DailyRecord] = [:]  // DateString -> Record
    
    private init() {
        // 从本地存储加载数据
        self.playerProfile = GameDataManager.load(forKey: Keys.playerProfile) ?? PlayerProfile()
        self.collectionManager = GameDataManager.load(forKey: Keys.collectionManager) ?? CollectionManager()
        self.gameSettings = GameDataManager.load(forKey: Keys.gameSettings) ?? GameSettings()
        self.gameStatistics = GameDataManager.load(forKey: Keys.gameStatistics) ?? GameStatistics()
        
        // 加载每日记录
        if let records: [String: DailyRecord] = GameDataManager.load(forKey: Keys.dailyRecords) {
            self.dailyRecords = records
        }
        
        // 设置首次启动日期
        if playerProfile.firstLaunchDate == nil {
            playerProfile.firstLaunchDate = Date()
            savePlayerProfile()
        }
    }
    
    // MARK: - 通用存储方法
    
    private static func save<T: Codable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private static func load<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - 玩家档案
    
    func savePlayerProfile() {
        GameDataManager.save(playerProfile, forKey: Keys.playerProfile)
    }
    
    func updatePlayerProfile(_ update: (inout PlayerProfile) -> Void) {
        update(&playerProfile)
        savePlayerProfile()
    }
    
    // MARK: - 收藏管理
    
    func saveCollectionManager() {
        GameDataManager.save(collectionManager, forKey: Keys.collectionManager)
    }
    
    func unlockGoose(_ gooseID: String, themeID: Int, score: Int) {
        collectionManager.unlockGoose(gooseID, themeID: themeID, score: score)
        saveCollectionManager()
        
        // 更新玩家档案
        playerProfile.incrementGeeseCaptured()
        savePlayerProfile()
    }
    
    // MARK: - 游戏设置
    
    func saveGameSettings() {
        GameDataManager.save(gameSettings, forKey: Keys.gameSettings)
    }
    
    func updateSettings(_ update: (inout GameSettings) -> Void) {
        update(&gameSettings)
        saveGameSettings()
    }
    
    // MARK: - 每日记录
    
    func getTodayRecord(themeID: Int) -> DailyRecord {
        let todayKey = dateKey(Date())
        
        if let record = dailyRecords[todayKey], record.themeID == themeID {
            return record
        }
        
        // 创建新记录
        let newRecord = DailyRecord(date: Date(), themeID: themeID)
        dailyRecords[todayKey] = newRecord
        saveDailyRecords()
        return newRecord
    }
    
    func updateTodayRecord(score: Int, timeRemaining: TimeInterval, themeID: Int) {
        let todayKey = dateKey(Date())
        
        var record = dailyRecords[todayKey] ?? DailyRecord(date: Date(), themeID: themeID)
        record.recordAttempt(score: score, timeRemaining: timeRemaining)
        dailyRecords[todayKey] = record
        
        saveDailyRecords()
        
        // 更新玩家档案
        playerProfile.incrementGamesPlayed()
        playerProfile.updateHighestScore(score)
        savePlayerProfile()
        
        // 更新统计
        gameStatistics.updateStreak()
        saveGameStatistics()
    }
    
    func getBestScore(for date: Date, themeID: Int) -> Int {
        let key = dateKey(date)
        guard let record = dailyRecords[key], record.themeID == themeID else {
            return 0
        }
        return record.bestScore
    }
    
    private func saveDailyRecords() {
        GameDataManager.save(dailyRecords, forKey: Keys.dailyRecords)
    }
    
    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - 游戏统计
    
    func saveGameStatistics() {
        GameDataManager.save(gameStatistics, forKey: Keys.gameStatistics)
    }
    
    func incrementEliminations() {
        gameStatistics.totalEliminations += 1
        saveGameStatistics()
    }
    
    func incrementShakes() {
        gameStatistics.totalShakes += 1
        saveGameStatistics()
    }
    
    func recordPerfectWin() {
        gameStatistics.perfectWins += 1
        saveGameStatistics()
    }
    
    // MARK: - 清理旧数据
    
    func cleanupOldRecords(keepDays: Int = 30) {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -keepDays, to: Date())!
        let cutoffKey = dateKey(cutoffDate)
        
        dailyRecords = dailyRecords.filter { $0.key >= cutoffKey }
        saveDailyRecords()
    }
}
