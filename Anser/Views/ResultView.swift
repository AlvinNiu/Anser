//
//  ResultView.swift
//  Anser
//
//  游戏结果界面（胜利/失败）
//

import SwiftUI

enum GameResult {
    case win
    case lose
}

struct ResultView: View {
    let result: GameResult
    let score: Int
    let goose: GooseTemplate?
    let onReplay: () -> Void
    let onExit: () -> Void
    
    @State private var showGooseAnimation = false
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            VStack(spacing: 24) {
                Spacer()
                
                // 结果标题
                resultTitle
                
                // 大鹅展示（胜利时）
                if result == .win, let goose = goose {
                    gooseDisplay(goose: goose)
                }
                
                // 失败动画（失败时）
                if result == .lose {
                    loseAnimation
                }
                
                // 分数显示
                scoreDisplay
                
                Spacer()
                
                // 按钮
                if showButtons {
                    actionButtons
                }
            }
            .padding()
        }
        .onAppear {
            // 延迟动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showGooseAnimation = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut) {
                    showButtons = true
                }
            }
        }
    }
    
    // MARK: - 背景
    private var backgroundView: some View {
        Group {
            if result == .win {
                // 胜利背景 - 渐变色彩
                LinearGradient(
                    colors: [
                        Color.yellow.opacity(0.3),
                        Color.orange.opacity(0.2),
                        Color.pink.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                // 失败背景 - 灰暗色调
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - 结果标题
    private var resultTitle: some View {
        VStack(spacing: 8) {
            if result == .win {
                Text("🎉")
                    .font(.system(size: 60))
                
                Text("抓到大鹅了！")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                
                Text("恭喜你成功通关！")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                Text("😢")
                    .font(.system(size: 60))
                
                Text("差一点就抓到了")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                
                Text("要抓我你还早个十年咧~")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
    }
    
    // MARK: - 大鹅展示
    private func gooseDisplay(goose: GooseTemplate) -> some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景光环
                Circle()
                    .fill(
                        RadialGradient(
                            colors: goose.rarity.gradient,
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .opacity(0.3)
                    .scaleEffect(showGooseAnimation ? 1.0 : 0.5)
                
                // 大鹅圆形卡片
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: goose.rarity.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 150, height: 150)
                    
                    Text(goose.emoji)
                        .font(.system(size: 80))
                }
                .scaleEffect(showGooseAnimation ? 1.0 : 0.0)
                .rotationEffect(.degrees(showGooseAnimation ? 0 : -180))
            }
            
            VStack(spacing: 4) {
                Text(goose.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goose.rarity.color)
                        .frame(width: 12, height: 12)
                    
                    Text(goose.rarity.displayName)
                        .font(.subheadline)
                        .foregroundStyle(goose.rarity.color)
                }
                
                Text(goose.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(showGooseAnimation ? 1.0 : 0.0)
            .offset(y: showGooseAnimation ? 0 : 20)
        }
    }
    
    // MARK: - 失败动画
    private var loseAnimation: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Text("🦢")
                    .font(.system(size: 80))
                    .rotationEffect(.degrees(180))
                    .offset(y: showGooseAnimation ? 0 : -50)
            }
            
            Text("大鹅逃跑了...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - 分数显示
    private var scoreDisplay: some View {
        VStack(spacing: 8) {
            Text("本局得分")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("\(score)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(result == .win ? .orange : .gray)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 操作按钮
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 再玩一次按钮
            Button {
                AudioManager.shared.playEffect(.button)
                onReplay()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("再玩一次")
                        .fontWeight(.semibold)
                }
                .font(.title3)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // 返回主界面按钮
            Button {
                AudioManager.shared.playEffect(.button)
                onExit()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("返回主界面")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 20)
    }
    
    private var buttonColor: Color {
        result == .win ? .orange : .gray
    }
}

// MARK: - 分享卡片（用于系统分享）
struct ShareCard: View {
    let goose: GooseTemplate
    let score: Int
    let date: Date
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("抓大鹅")
                .font(.title)
                .fontWeight(.bold)
            
            Text("今日捕获")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 大鹅展示
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: goose.rarity.gradient,
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Text(goose.emoji)
                    .font(.system(size: 70))
            }
            
            VStack(spacing: 4) {
                Text(goose.name)
                    .font(.headline)
                
                Text(goose.rarity.displayName)
                    .font(.caption)
                    .foregroundStyle(goose.rarity.color)
            }
            
            Text("得分: \(score)")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(formattedDate())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(30)
        .background(.white)
        .cornerRadius(20)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
}

#Preview("Win") {
    ResultView(
        result: .win,
        score: 2580,
        goose: GooseLibrary.allGeese[0],
        onReplay: {},
        onExit: {}
    )
}

#Preview("Lose") {
    ResultView(
        result: .lose,
        score: 1200,
        goose: nil,
        onReplay: {},
        onExit: {}
    )
}
