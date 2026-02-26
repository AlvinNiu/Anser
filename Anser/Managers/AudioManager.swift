//
//  AudioManager.swift
//  Anser
//
//  音频管理器 - 使用系统音效和触觉反馈
//

import Foundation
import AVFoundation
import UIKit
import AudioToolbox

/// 音效类型
enum SoundEffect {
    case select
    case eliminate
    case shake
    case win
    case lose
    case button
    case countdown
}

/// 背景音乐类型
enum BackgroundMusic {
    case main
    case game
    case victory
}

/// 音频管理器
@Observable
class AudioManager {
    static let shared = AudioManager()
    
    /// 音频引擎（用于生成简单音效）
    private var audioEngine: AVAudioEngine?
    private var backgroundPlayer: AVAudioPlayer?
    
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
        setupAudioEngine()
    }
    
    /// 设置音频会话
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[AudioManager] Failed to setup audio session: \(error)")
        }
    }
    
    /// 设置音频引擎
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
    }
    
    // MARK: - 背景音乐
    
    /// 播放背景音乐（使用简单的循环音效模拟）
    func playBackgroundMusic(_ music: BackgroundMusic) {
        guard musicEnabled else { return }
        
        // 停止当前音乐
        backgroundPlayer?.stop()
        backgroundPlayer = nil
        
        // 由于我们没有音频文件，这里使用触觉反馈模式代替
        // 实际项目中应该加载真实的音频文件
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
    
    /// 播放音效（系统音效 + 触觉反馈）
    func playEffect(_ effect: SoundEffect) {
        guard soundEnabled else { return }
        
        // 播放系统音效
        playSystemSound(for: effect)
        
        // 触觉反馈
        provideHapticFeedback(for: effect)
    }
    
    /// 播放系统音效
    private func playSystemSound(for effect: SoundEffect) {
        var soundID: SystemSoundID = 0
        
        switch effect {
        case .select:
            // 点击声 - 使用标准点击声
            soundID = 1104  // 标准点击声
        case .eliminate:
            // 消除成功声
            soundID = 1057  // 成功提示音
        case .shake:
            // 摇晃声
            soundID = 1109  // 摇晃声
        case .win:
            // 胜利声
            soundID = 1025  // 胜利音效
        case .lose:
            // 失败声
            soundID = 1073  // 失败音效
        case .button:
            // 按钮声
            soundID = 1104  // 标准点击声
        case .countdown:
            // 倒计时声
            soundID = 1111  // 提示音
        }
        
        if soundID != 0 {
            AudioServicesPlaySystemSound(soundID)
        }
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
            // 胜利时连续震动
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let lightGenerator = UIImpactFeedbackGenerator(style: .light)
                lightGenerator.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
                mediumGenerator.impactOccurred()
            }
            
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
    
    /// 播放自定义频率音效（使用 AudioEngine）
    func playTone(frequency: Double, duration: Double) {
        guard soundEnabled, let engine = audioEngine else { return }
        
        // 简单的正弦波音效生成
        let sampleRate = 44100.0
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: engine.mainMixerNode.outputFormat(forBus: 0), frameCapacity: frameCount) else {
            return
        }
        
        buffer.frameLength = frameCount
        
        let channels = Int(buffer.format.channelCount)
        let data = buffer.floatChannelData![0]
        
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let value = sin(2.0 * .pi * frequency * time)
            // 简单的衰减
            let amplitude = max(0, 1.0 - (time / duration))
            data[frame] = Float(value * amplitude * 0.5)
        }
        
        if channels > 1 {
            let data2 = buffer.floatChannelData![1]
            for frame in 0..<Int(frameCount) {
                data2[frame] = data[frame]
            }
        }
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        
        do {
            try engine.start()
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            player.play()
        } catch {
            print("[AudioManager] Failed to play tone: \(error)")
        }
    }
}
