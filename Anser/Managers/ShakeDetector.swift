//
//  ShakeDetector.swift
//  Anser
//
//  颠锅检测器：加速度计体感交互
//

import Foundation
import CoreMotion
import UIKit

/// 颠锅模式
enum ShakeMode {
    case vertical    // 上下颠（Y轴主导）
    case horizontal  // 左右晃（X轴主导）
    case none
}

/// 颠锅检测器
@Observable
class ShakeDetector: ObservableObject {
    /// 单例
    static let shared = ShakeDetector()
    
    /// 运动管理器
    private let motionManager = CMMotionManager()
    
    /// 是否可用
    private(set) var isAvailable: Bool = true
    
    /// 冷却进度（0.0 - 1.0）
    private(set) var cooldownProgress: Double = 1.0
    
    /// 当前颠锅模式
    private(set) var currentMode: ShakeMode = .none
    
    /// 是否正在冷却
    var isOnCooldown: Bool {
        cooldownProgress < 1.0
    }
    
    /// 回调
    var onShakeDetected: (() -> Void)?
    
    // MARK: - 配置参数
    
    /// 触发阈值（G力）
    var shakeThreshold: Double = 1.5
    
    /// 冷却时间（秒）
    var cooldownDuration: TimeInterval = 2.0
    
    /// 灵敏度倍数
    var sensitivityMultiplier: Double = 1.0
    
    // MARK: - 内部状态
    private var lastShakeTime: Date?
    private var cooldownTimer: Timer?
    private var isMonitoring = false
    
    private init() {
        checkAvailability()
    }
    
    // MARK: - 可用性检查
    
    /// 检查设备是否支持加速度计
    private func checkAvailability() {
        isAvailable = motionManager.isAccelerometerAvailable
    }
    
    /// 请求运动权限（iOS 17+）
    func requestPermission() {
        // iOS 17+ 需要 NSMotionUsageDescription
        // 权限会在首次使用加速度计时自动请求
        if motionManager.isAccelerometerAvailable {
            isAvailable = true
        }
    }
    
    // MARK: - 监测控制
    
    /// 开始监测加速度计
    func startMonitoring() {
        guard motionManager.isAccelerometerAvailable, !isMonitoring else { return }
        
        isMonitoring = true
        motionManager.accelerometerUpdateInterval = 0.01  // 100Hz采样率
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let acceleration = data?.acceleration else { return }
            self.processAcceleration(acceleration)
        }
    }
    
    /// 停止监测
    func stopMonitoring() {
        isMonitoring = false
        motionManager.stopAccelerometerUpdates()
    }
    
    // MARK: - 加速度处理
    
    /// 处理加速度数据
    private func processAcceleration(_ acceleration: CMAcceleration) {
        // 检查是否在冷却中
        guard !isOnCooldown else { return }
        
        // 计算总G力
        let magnitude = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )
        
        let gForce = magnitude / 9.8
        let threshold = shakeThreshold * sensitivityMultiplier
        
        // 检测是否超过阈值
        guard gForce >= threshold else { return }
        
        // 识别颠锅模式
        let absX = abs(acceleration.x)
        let absY = abs(acceleration.y)
        
        if absY > absX * 1.5 {
            currentMode = .vertical
        } else if absX > absY * 1.2 {
            currentMode = .horizontal
        } else {
            currentMode = .none
        }
        
        // 触发颠锅
        triggerShake()
    }
    
    /// 触发颠锅
    private func triggerShake() {
        lastShakeTime = Date()
        cooldownProgress = 0.0
        
        // 触发回调
        onShakeDetected?()
        
        // 启动冷却计时器
        startCooldownTimer()
        
        // 触觉反馈
        provideHapticFeedback()
    }
    
    /// 启动冷却计时器
    private func startCooldownTimer() {
        cooldownTimer?.invalidate()
        
        let updateInterval = 0.05
        let totalSteps = Int(cooldownDuration / updateInterval)
        var currentStep = 0
        
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            self.cooldownProgress = Double(currentStep) / Double(totalSteps)
            
            if currentStep >= totalSteps {
                self.cooldownProgress = 1.0
                self.currentMode = .none
                timer.invalidate()
            }
        }
    }
    
    /// 提供触觉反馈
    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 手动触发颠锅（按钮替代方案）
    func triggerManualShake() {
        guard !isOnCooldown else { return }
        triggerShake()
    }
    
    /// 重置冷却
    func resetCooldown() {
        cooldownTimer?.invalidate()
        cooldownProgress = 1.0
        currentMode = .none
    }
    
    deinit {
        stopMonitoring()
        cooldownTimer?.invalidate()
    }
}
