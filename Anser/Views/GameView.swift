//
//  GameView.swift
//  Anser
//
//  游戏界面视图
//

import SwiftUI

struct GameView: View {
    let theme: Theme
    
    @State private var gameSession: GameSession
    @State private var sceneController = GameSceneController()
    @State private var shakeDetector = ShakeDetector.shared
    @State private var gameData = GameDataManager.shared
    @State private var showPauseMenu = false
    @State private var showResult = false
    @State private var resultType: GameResultType = .win
    @State private var shakeCooldown: Double = 1.0
    
    @Environment(\.dismiss) private var dismiss
    
    enum GameResultType {
        case win
        case lose
    }
    
    init(theme: Theme) {
        self.theme = theme
        _gameSession = State(initialValue: GameSession(theme: theme))
    }
    
    var body: some View {
        ZStack {
            // 背景
            theme.themeBackgroundColor
                .opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部HUD
                topHUD
                
                // 游戏场景
                gameScene
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 底部交互区
                bottomPanel
            }
            
            // 暂停遮罩
            if showPauseMenu {
                pauseOverlay
            }
            
            // 结果界面
            if showResult {
                ResultView(
                    result: resultType == .win ? .win : .lose,
                    score: gameSession.score,
                    goose: resultType == .win ? theme.unlockGoose : nil,
                    onReplay: replayGame,
                    onExit: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            setupGame()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    // MARK: - 顶部HUD
    private var topHUD: some View {
        VStack(spacing: 8) {
            HStack {
                // 暂停按钮
                Button {
                    pauseGame()
                } label: {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                // 倒计时
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(timeColor)
                    Text(gameSession.formattedTime)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(timeColor)
                }
                
                Spacer()
                
                // 占位保持对称
                Image(systemName: "pause.circle.fill")
                    .font(.title2)
                    .opacity(0)
            }
            .padding(.horizontal)
            
            // 进度条
            ProgressView(value: gameSession.progress)
                .tint(theme.themeAccentColor)
                .padding(.horizontal)
            
            // 分数
            HStack {
                Text("目标: \(gameSession.eliminationCount)/\(gameSession.configuration.targetEliminations)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("分数: \(gameSession.score)")
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    private var timeColor: Color {
        if gameSession.timeRemaining < 30 {
            return .red
        } else if gameSession.timeRemaining < 60 {
            return .orange
        }
        return .primary
    }
    
    // MARK: - 游戏场景
    private var gameScene: some View {
        GameSceneView(controller: sceneController)
            .onTapGesture { location in
                // 点击由SceneKit处理
            }
    }
    
    // MARK: - 底部交互区
    private var bottomPanel: some View {
        VStack(spacing: 12) {
            // 待消除栏（3槽位）
            eliminationTray
            
            // 颠锅控制
            shakeControl
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 待消除栏
    private var eliminationTray: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                TraySlotView(
                    item: index < gameSession.tray.count ? gameSession.tray.items[index] : nil,
                    isActive: index < gameSession.tray.count,
                    isWarning: gameSession.tray.isFull
                )
            }
        }
        .frame(height: 60)
    }
    
    // MARK: - 颠锅控制
    private var shakeControl: some View {
        HStack(spacing: 20) {
            // 颠锅按钮（当不使用体感或体感不可用时显示）
            if gameData.gameSettings.useButtonInsteadOfShake || !shakeDetector.isAvailable {
                ShakeButton(
                    cooldown: shakeDetector.cooldownProgress,
                    themeColor: theme.themeAccentColor,
                    onTap: {
                        // 使用 ShakeDetector 的手动触发，它会处理冷却
                        shakeDetector.triggerManualShake()
                    }
                )
            } else {
                // 提示用户摇晃手机
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                    Text("摇晃手机颠锅")
                        .font(.callout)
                }
                .foregroundStyle(shakeDetector.isOnCooldown ? .secondary : theme.themeAccentColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(shakeDetector.isOnCooldown ? Color.gray.opacity(0.2) : theme.themeAccentColor.opacity(0.2))
                )
                .overlay(
                    // 冷却进度
                    GeometryReader { geometry in
                        if shakeDetector.cooldownProgress < 1.0 {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(theme.themeAccentColor.opacity(0.3))
                                .frame(width: geometry.size.width * shakeDetector.cooldownProgress)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - 暂停遮罩
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("游戏暂停")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                VStack(spacing: 12) {
                    Button("继续游戏") {
                        resumeGame()
                    }
                    .buttonStyle(GameButtonStyle(color: .green))
                    
                    Button("重新开始") {
                        restartGame()
                    }
                    .buttonStyle(GameButtonStyle(color: .orange))
                    
                    Button("返回主界面") {
                        dismiss()
                    }
                    .buttonStyle(GameButtonStyle(color: .gray))
                }
                .frame(width: 200)
            }
        }
    }
    
    // MARK: - 游戏控制
    
    private func setupGame() {
        // 设置回调
        gameSession.onWin = {
            handleWin()
        }
        gameSession.onLose = {
            handleLose()
        }
        
        // 设置场景控制器回调
        sceneController.gameSession = gameSession
        sceneController.onItemSelected = { item in
            handleItemSelected(item)
        }
        
        // 设置颠锅回调
        shakeDetector.onShakeDetected = {
            performShake()
        }
        shakeDetector.shakeThreshold = 1.5 / gameData.gameSettings.shakeSensitivity
        
        // 开始游戏
        gameSession.startGame()
        sceneController.spawnItems(gameSession.sceneItems)
        
        // 开始监测加速度计
        if !gameData.gameSettings.useButtonInsteadOfShake {
            shakeDetector.startMonitoring()
        }
        
        // 播放游戏音乐
        AudioManager.shared.playBackgroundMusic(.game)
    }
    
    private func cleanup() {
        shakeDetector.stopMonitoring()
        gameSession.endGame()
        AudioManager.shared.playBackgroundMusic(.main)
    }
    
    private func handleItemSelected(_ item: GameItem) {
        guard gameSession.selectItem(item) else { return }
        
        // 更新选中的物品（添加到待消除栏）
        sceneController.updateItem(item)
        
        // 播放音效
        AudioManager.shared.playEffect(.select)
        
        // 检查是否有物品被消除
        let eliminatedItems = gameSession.getEliminatedItems()
        if !eliminatedItems.isEmpty {
            // 播放消除音效
            AudioManager.shared.playEffect(.eliminate)
            
            // 更新所有被消除的物品（从场景中移除）
            for eliminatedItem in eliminatedItems {
                sceneController.updateItem(eliminatedItem)
            }
        }
        
        // 检查胜利条件
        if gameSession.checkWinCondition() {
            AudioManager.shared.playEffect(.win)
        }
    }
    
    private func performShake() {
        // 触发游戏逻辑中的颠锅
        gameSession.triggerShake()
        
        // 触发场景中的颠锅效果
        sceneController.performShake()
        
        // 播放音效
        AudioManager.shared.playEffect(.shake)
        
        // 更新统计数据
        gameData.incrementShakes()
    }
    
    private func handleWin() {
        // 解锁大鹅
        gameData.unlockGoose(theme.unlockGooseID, themeID: theme.id, score: gameSession.score)
        
        // 更新今日记录
        gameData.updateTodayRecord(
            score: gameSession.score,
            timeRemaining: gameSession.timeRemaining,
            themeID: theme.id
        )
        
        // 显示胜利界面
        resultType = .win
        withAnimation {
            showResult = true
        }
        
        AudioManager.shared.playEffect(.win)
    }
    
    private func handleLose() {
        // 更新今日记录
        gameData.updateTodayRecord(
            score: gameSession.score,
            timeRemaining: gameSession.timeRemaining,
            themeID: theme.id
        )
        
        // 显示失败界面
        resultType = .lose
        withAnimation {
            showResult = true
        }
        
        AudioManager.shared.playEffect(.lose)
    }
    
    private func pauseGame() {
        gameSession.pauseGame()
        showPauseMenu = true
    }
    
    private func resumeGame() {
        showPauseMenu = false
        gameSession.resumeGame()
    }
    
    private func restartGame() {
        showPauseMenu = false
        showResult = false
        gameSession.startGame()
        sceneController.spawnItems(gameSession.sceneItems)
    }
    
    private func replayGame() {
        showResult = false
        gameSession.startGame()
        sceneController.spawnItems(gameSession.sceneItems)
    }
}

// MARK: - 槽位视图
struct TraySlotView: View {
    let item: GameItem?
    let isActive: Bool
    let isWarning: Bool
    
    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? (item?.type.color ?? Color.gray).opacity(0.2) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isWarning ? Color.red : (isActive ? item?.type.color ?? Color.gray : Color.gray.opacity(0.3)), 
                               lineWidth: isWarning ? 3 : (isActive ? 3 : 2))
                )
            
            if let item = item {
                // 显示物品图标
                ZStack {
                    Circle()
                        .fill(item.type.color.opacity(0.3))
                        .frame(width: 44, height: 44)
                    
                    Text(item.type.displayName.prefix(1))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(item.type.color)
                }
            } else {
                // 空槽位显示
                Image(systemName: "square.dashed")
                    .font(.title2)
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .frame(width: 70, height: 70)
    }
}

// MARK: - 颠锅按钮
struct ShakeButton: View {
    let cooldown: Double
    let themeColor: Color
    let onTap: () -> Void
    
    var isReady: Bool {
        cooldown >= 1.0
    }
    
    var body: some View {
        Button {
            if isReady {
                onTap()
            }
        } label: {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("颠锅")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isReady ? themeColor : Color.gray)
            )
            .overlay(
                // 冷却进度
                GeometryReader { geometry in
                    if !isReady {
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: geometry.size.width * (1 - cooldown))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .clipShape(Capsule())
            )
        }
        .disabled(!isReady)
    }
}

// MARK: - 游戏按钮样式
struct GameButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    GameView(theme: ThemeLibrary.allThemes[0])
}
