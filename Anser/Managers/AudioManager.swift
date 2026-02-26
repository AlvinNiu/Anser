//
//  AudioManager.swift
//  Anser
//
//  音频管理器
//

import Foundation
import AVFoundation
import UIKit

/// 音效类型
enum SoundEffect: String {
    case select = "select"
    case eliminate = "eliminate"
    case shake = "shake"
    case win = "win"
    case lose = "lose"
    case button = "button"
    case countdown = "countdown"
}

/// 背景音乐类型
enum BackgroundMusic: String {
    case main = "main_theme"
    case game = "game_theme"
    case victory = "victory_theme"
}

/// 音频管理器
@Observable
class AudioManager {
    static let shared = AudioManager()
    
    /// 音频播放器
    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    /// 设置
    var soundEnabled: Bool {
        get { GameDataManager.shared.gameSettings.soundEnabled }
        set { GameDataManager.shared.updateSettings { $0.soundEnabled = newValue } }
    }
    
    var musicEnabled: Bool {
        get { GameDataManager.shared.gameSettings.musicEnabled }
        set { 
            GameDataManager.shared.updateSettings { $0.musicEnabled = newValue }
            if newValue {
                resumeBackgroundMusic()
            } else {
                pauseBackgroundMusic()
            }
        }
    }
    
    private init() {
        setupAudioSession()
        preloadEffects()
    }
    
    /// 设置音频会话
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    /// 预加载音效
    private func preloadEffects() {
        // 在实际应用中，这里会加载音频文件
        // 为了演示，我们只是初始化播放器
        for _ in [SoundEffect.select, .eliminate, .shake, .win, .lose, .button] {
            // 预加载音效（资源就绪后启用）
            // effectPlayers[effect] = createPlayer(for: effect)
        }
    }
    
    // MARK: - 背景音乐
    
    /// 播放背景音乐
    func playBackgroundMusic(_ music: BackgroundMusic) {
        guard musicEnabled else { return }
        
        // 停止当前音乐
        backgroundPlayer?.stop()
        
        // 创建新播放器（实际应用中从资源加载）
        // backgroundPlayer = createPlayer(for: music)
        backgroundPlayer?.numberOfLoops = -1  // 无限循环
        backgroundPlayer?.volume = 0.5
        backgroundPlayer?.play()
    }
    
    /// 暂停背景音乐
    func pauseBackgroundMusic() {
        backgroundPlayer?.pause()
    }
    
    /// 恢复背景音乐
    func resumeBackgroundMusic() {
        guard musicEnabled else { return }
        backgroundPlayer?.play()
    }
    
    /// 停止背景音乐
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }
    
    // MARK: - 音效
    
    /// 播放音效
    func playEffect(_ effect: SoundEffect) {
        guard soundEnabled else { return }
        
        // 简单的触觉反馈作为音效的替代
        provideHapticFeedback(for: effect)
        
        // 实际音频播放（资源就绪后启用）
        // if let player = effectPlayers[effect] {
        //     player.currentTime = 0
        //     player.play()
        // }
    }
    
    /// 提供触觉反馈
    private func provideHapticFeedback(for effect: SoundEffect) {
        guard GameDataManager.shared.gameSettings.hapticEnabled else { return }
        
        switch effect {
        case .select:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case .eliminate:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case .shake:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        case .win:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case .lose:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case .button:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            
        case .countdown:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }
    
    // MARK: - 音量控制
    
    /// 设置背景音乐音量
    func setMusicVolume(_ volume: Float) {
        backgroundPlayer?.volume = max(0, min(1, volume))
    }
    
    /// 设置音效音量
    func setEffectVolume(_ volume: Float) {
        effectPlayers.values.forEach { $0.volume = max(0, min(1, volume)) }
    }
}
