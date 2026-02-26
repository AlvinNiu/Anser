//
//  HomeView.swift
//  Anser
//
//  主界面视图
//

import SwiftUI

struct HomeView: View {
    @State private var themeEngine = ThemeEngine.shared
    @State private var gameData = GameDataManager.shared
    @State private var showGame = false
    @State private var showCollection = false
    @State private var showSettings = false
    @State private var showThemeChangeAlert = false
    
    private var todayRecord: DailyRecord {
        gameData.getTodayRecord(themeID: themeEngine.currentTheme.id)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                themeEngine.currentTheme.themeBackgroundColor
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部信息区
                    headerSection
                    
                    Spacer()
                    
                    // 中央视觉区
                    centerSection
                    
                    Spacer()
                    
                    // 底部操作区
                    bottomSection
                }
                .padding(.vertical, 20)
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(theme: themeEngine.currentTheme)
            }
        }
        .onAppear {
            // 检查主题是否更新
            if themeEngine.checkAndUpdateTheme() {
                showThemeChangeAlert = true
            }
            // 播放背景音乐
            AudioManager.shared.playBackgroundMusic(.main)
        }
        .alert("今日主题已更新", isPresented: $showThemeChangeAlert) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text("今天的主题是「\(themeEngine.currentThemeName)」，快来挑战吧！")
        }
    }
    
    // MARK: - 顶部信息区
    private var headerSection: some View {
        VStack(spacing: 12) {
            // 日期
            Text(formattedDate())
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // 主题名称
            Text(themeEngine.currentThemeName)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(themeEngine.currentTheme.themeAccentColor)
            
            // 主题描述
            Text(themeEngine.currentThemeDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // 今日最佳成绩
            if todayRecord.bestScore > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("今日最佳: \(todayRecord.bestScore)")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 中央视觉区
    private var centerSection: some View {
        VStack(spacing: 20) {
            // 大鹅展示（如果有）
            if let latestGoose = gameData.collectionManager.unlockedGeese.last,
               let template = latestGoose.template {
                VStack(spacing: 8) {
                    Text("最新捕获")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        Circle()
                            .fill(template.rarity.gradient[0])
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(template.rarity.gradient[1], lineWidth: 3)
                            )
                        
                        Text(template.emoji)
                            .font(.system(size: 60))
                    }
                    
                    Text(template.name)
                        .font(.headline)
                    
                    Text(template.rarity.displayName)
                        .font(.caption)
                        .foregroundStyle(template.rarity.color)
                }
            } else {
                // 默认展示
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(themeEngine.currentTheme.themeAccentColor.opacity(0.2))
                            .frame(width: 140, height: 140)
                        
                        Text("🦢")
                            .font(.system(size: 80))
                    }
                    
                    Text("今天能抓到什么大鹅呢？")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 收集进度
            if gameData.collectionManager.unlockedCount > 0 {
                VStack(spacing: 4) {
                    HStack {
                        Text("收集进度")
                            .font(.caption)
                        Spacer()
                        Text("\(gameData.collectionManager.unlockedCount)/\(GooseLibrary.totalCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ProgressView(value: gameData.collectionManager.collectionProgress)
                        .tint(themeEngine.currentTheme.themeAccentColor)
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - 底部操作区
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // 开始游戏按钮
            Button {
                AudioManager.shared.playEffect(.button)
                showGame = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                    Text("开始游戏")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [themeEngine.currentTheme.themeAccentColor, 
                                themeEngine.currentTheme.themeAccentColor.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: themeEngine.currentTheme.themeAccentColor.opacity(0.4), 
                       radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 32)
            
            // 次要按钮
            HStack(spacing: 20) {
                // 收藏册按钮
                Button {
                    AudioManager.shared.playEffect(.button)
                    showCollection = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.title2)
                        Text("收藏册")
                            .font(.caption)
                    }
                    .foregroundStyle(themeEngine.currentTheme.themeAccentColor)
                    .frame(width: 80, height: 70)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // 设置按钮
                Button {
                    AudioManager.shared.playEffect(.button)
                    showSettings = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                        Text("设置")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .frame(width: 80, height: 70)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .sheet(isPresented: $showCollection) {
            CollectionView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - 辅助方法
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }
}

// MARK: - 收藏册视图
struct CollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameData = GameDataManager.shared
    
    private let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(GooseLibrary.allGeese) { goose in
                        GooseCard(
                            goose: goose,
                            isUnlocked: gameData.collectionManager.isUnlocked(goose.id),
                            unlockDate: gameData.collectionManager.unlockedGeese
                                .first { $0.templateID == goose.id }?.unlockDate
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("大鹅收藏册")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 大鹅卡片
struct GooseCard: View {
    let goose: GooseTemplate
    let isUnlocked: Bool
    let unlockDate: Date?
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? goose.rarity.gradient[0] : Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(isUnlocked ? goose.rarity.gradient[1] : Color.gray.opacity(0.5), 
                                   lineWidth: 2)
                    )
                
                if isUnlocked {
                    Text(goose.emoji)
                        .font(.system(size: 40))
                } else {
                    Image(systemName: "questionmark")
                        .font(.title)
                        .foregroundStyle(.gray)
                }
            }
            
            Text(goose.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isUnlocked ? .primary : .secondary)
            
            if isUnlocked {
                Text(goose.rarity.displayName)
                    .font(.caption2)
                    .foregroundStyle(goose.rarity.color)
            } else {
                Text("未解锁")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameData = GameDataManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section("音频") {
                    Toggle("音效", isOn: .init(
                        get: { gameData.gameSettings.soundEnabled },
                        set: { _ in
                            gameData.updateSettings { $0.soundEnabled.toggle() }
                            AudioManager.shared.playEffect(.button)
                        }
                    ))
                    
                    Toggle("背景音乐", isOn: .init(
                        get: { gameData.gameSettings.musicEnabled },
                        set: { _ in
                            gameData.updateSettings { $0.musicEnabled.toggle() }
                        }
                    ))
                }
                
                Section("触觉反馈") {
                    Toggle("震动反馈", isOn: .init(
                        get: { gameData.gameSettings.hapticEnabled },
                        set: { _ in
                            gameData.updateSettings { $0.hapticEnabled.toggle() }
                        }
                    ))
                }
                
                Section("体感控制") {
                    Toggle("使用按钮代替摇晃", isOn: .init(
                        get: { gameData.gameSettings.useButtonInsteadOfShake },
                        set: { _ in
                            gameData.updateSettings { $0.useButtonInsteadOfShake.toggle() }
                        }
                    ))
                    
                    if !gameData.gameSettings.useButtonInsteadOfShake {
                        VStack(alignment: .leading) {
                            Text("颠锅灵敏度")
                            Slider(
                                value: .init(
                                    get: { gameData.gameSettings.shakeSensitivity },
                                    set: { newValue in gameData.updateSettings { $0.shakeSensitivity = newValue } }
                                ),
                                in: 0.5...2.0,
                                step: 0.1
                            )
                        }
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("牛慧升")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
