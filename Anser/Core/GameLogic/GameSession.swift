//
//  GameSession.swift
//  Anser
//
//  游戏会话管理：核心游戏逻辑
//

import Foundation
import SwiftUI

/// 游戏配置
struct GameConfiguration {
    let level: Int
    let timeLimit: TimeInterval
    let targetEliminations: Int
    let itemCount: Int
    let itemTypes: [ItemType]
    
    /// 关卡1配置（教学关）
    static let level1 = GameConfiguration(
        level: 1,
        timeLimit: 120,  // 2分钟
        targetEliminations: 5,
        itemCount: 24,   // 8组 × 3个
        itemTypes: Array(ItemType.allCases.prefix(4))  // 4种类型
    )
    
    /// 关卡2配置（挑战关）
    static let level2 = GameConfiguration(
        level: 2,
        timeLimit: 180,  // 3分钟
        targetEliminations: 12,
        itemCount: 48,   // 12组 × 3个
        itemTypes: Array(ItemType.allCases.prefix(8))  // 8种类型
    )
}

/// 游戏会话
@Observable
class GameSession {
    // MARK: - 状态属性
    private(set) var state: GameState = .idle
    private(set) var score: Int = 0
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var level: Int = 1
    private(set) var selectedItems: [GameItem] = []
    private(set) var sceneItems: [GameItem] = []
    private(set) var eliminationCount: Int = 0
    private(set) var shakeCount: Int = 0
    private(set) var startTime: Date?
    private(set) var configuration: GameConfiguration = .level1
    
    // 待消除栏（3槽位）
    let tray = EliminationTray()
    
    // 当前主题
    let theme: Theme
    
    // 计时器
    private var timer: Timer?
    
    // 回调
    var onWin: (() -> Void)?
    var onLose: (() -> Void)?
    var onTimeUpdate: ((TimeInterval) -> Void)?
    
    // MARK: - 初始化
    init(theme: Theme) {
        self.theme = theme
    }
    
    // MARK: - 计算属性
    var isPlaying: Bool {
        state == .playing
    }
    
    var isPaused: Bool {
        state == .paused
    }
    
    var progress: Double {
        Double(eliminationCount) / Double(configuration.targetEliminations)
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - 游戏控制
    
    /// 开始新游戏
    func startGame(level: Int = 1) {
        self.level = level
        self.configuration = level == 1 ? .level1 : .level2
        self.state = .playing
        self.score = 0
        self.timeRemaining = configuration.timeLimit
        self.eliminationCount = 0
        self.shakeCount = 0
        self.startTime = Date()
        self.selectedItems.removeAll()
        self.tray.clear()
        
        // 生成场景物品
        generateItems()
        
        // 启动计时器
        startTimer()
    }
    
    /// 暂停游戏
    func pauseGame() {
        guard state == .playing else { return }
        state = .paused
        stopTimer()
    }
    
    /// 恢复游戏
    func resumeGame() {
        guard state == .paused else { return }
        state = .playing
        startTimer()
    }
    
    /// 结束游戏
    func endGame() {
        stopTimer()
        state = .idle
    }
    
    // MARK: - 游戏逻辑
    
    /// 生成场景物品
    private func generateItems() {
        sceneItems.removeAll()
        
        // 每种类型生成3个
        let types = configuration.itemTypes
        let itemsPerType = configuration.itemCount / types.count
        
        for type in types {
            for _ in 0..<itemsPerType {
                let item = GameItem(
                    type: type,
                    position: randomPosition(),
                    rotation: randomRotation(),
                    scale: 1.0
                )
                sceneItems.append(item)
            }
        }
        
        // 随机打乱
        sceneItems.shuffle()
    }
    
    /// 生成随机位置（在大锅范围内）
    private func randomPosition() -> SIMD3<Float> {
        // 大锅半径约为5，高度范围0-3
        let radius = Float.random(in: 0...4)
        let angle = Float.random(in: 0...(2 * .pi))
        let x = radius * cos(angle)
        let z = radius * sin(angle)
        let y = Float.random(in: 0.5...3)
        return SIMD3<Float>(x, y, z)
    }
    
    /// 生成随机旋转
    private func randomRotation() -> SIMD3<Float> {
        SIMD3<Float>(
            Float.random(in: 0...(2 * .pi)),
            Float.random(in: 0...(2 * .pi)),
            Float.random(in: 0...(2 * .pi))
        )
    }
    
    /// 选择物品
    func selectItem(_ item: GameItem) -> Bool {
        guard state == .playing,
              !item.isSelected,
              !item.isEliminated,
              !tray.isFull else {
            return false
        }
        
        // 添加到待消除栏
        let didEliminate = tray.addItem(item)
        
        if didEliminate {
            // 触发消除
            handleElimination()
        }
        
        // 检查待消除栏是否已满（失败条件之一）
        if tray.isFull && !didEliminate && checkLoseCondition() {
            loseGame()
        }
        
        return true
    }
    
    /// 处理消除
    private func handleElimination() {
        // 增加分数
        let baseScore = 100
        let timeBonus = Int(timeRemaining) / 10
        score += baseScore + timeBonus
        
        // 增加消除计数
        eliminationCount += 1
        
        // 更新统计数据
        GameDataManager.shared.incrementEliminations()
        
        // 检查胜利条件
        if checkWinCondition() {
            winGame()
        }
    }
    
    /// 获取刚被消除的物品列表（用于更新UI）
    func getEliminatedItems() -> [GameItem] {
        return sceneItems.filter { $0.isEliminated }
    }
    
    /// 触发颠锅
    func triggerShake() {
        guard state == .playing else { return }
        
        shakeCount += 1
        
        // 重新随机化物品位置
        for item in sceneItems where !item.isEliminated {
            item.position = randomPosition()
            item.rotation = randomRotation()
        }
    }
    
    // MARK: - 胜负判定
    
    /// 检查胜利条件
    func checkWinCondition() -> Bool {
        return eliminationCount >= configuration.targetEliminations
    }
    
    /// 检查失败条件
    func checkLoseCondition() -> Bool {
        return tray.isFull || timeRemaining <= 0
    }
    
    /// 胜利
    private func winGame() {
        state = .won
        stopTimer()
        onWin?()
    }
    
    /// 失败
    private func loseGame() {
        state = .lost
        stopTimer()
        onLose?()
    }
    
    // MARK: - 计时器
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard state == .playing else { return }
        
        timeRemaining -= 1
        onTimeUpdate?(timeRemaining)
        
        if timeRemaining <= 0 {
            loseGame()
        }
    }
    
    deinit {
        stopTimer()
    }
}
