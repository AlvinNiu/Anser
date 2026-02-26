//
//  ThemeEngine.swift
//  Anser
//
//  主题引擎：管理每日主题切换
//

import Foundation
import SwiftUI

/// 主题引擎协议
protocol ThemeEngineProtocol {
    var currentTheme: Theme { get }
    func theme(for date: Date) -> Theme
    func preloadTheme(id: Int) async
    func unloadTheme(id: Int)
}

/// 主题引擎实现
@Observable
class ThemeEngine: ThemeEngineProtocol {
    /// 单例实例
    static let shared = ThemeEngine()
    
    /// 当前主题
    private(set) var currentTheme: Theme
    
    /// 主题起始日期
    private let startDate: Date
    
    /// 今日已更新标记
    private var hasUpdatedToday: Bool = false
    
    /// 缓存的主题资源
    private var cachedThemes: [Int: Theme] = [:]
    
    private init() {
        // 设置起始日期（2026年2月16日）
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 16
        self.startDate = Calendar.current.date(from: components) ?? Date()
        
        // 计算当前主题
        self.currentTheme = ThemeEngine.calculateTheme(for: Date(), startDate: self.startDate)
        
        // 开始监听日期变化
        startDateMonitoring()
    }
    
    /// 计算指定日期的主题
    static func calculateTheme(for date: Date, startDate: Date) -> Theme {
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        let themeID = daysDiff % ThemeLibrary.totalCount
        let normalizedID = themeID < 0 ? themeID + ThemeLibrary.totalCount : themeID
        return ThemeLibrary.getTheme(byID: normalizedID) ?? ThemeLibrary.allThemes[0]
    }
    
    /// 获取当前日期的主题ID
    func getCurrentThemeID() -> Int {
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        let themeID = daysDiff % ThemeLibrary.totalCount
        return themeID < 0 ? themeID + ThemeLibrary.totalCount : themeID
    }
    
    /// 获取指定日期的主题
    func theme(for date: Date) -> Theme {
        return ThemeEngine.calculateTheme(for: date, startDate: startDate)
    }
    
    /// 检查是否需要更新主题
    func checkAndUpdateTheme() -> Bool {
        let newTheme = ThemeEngine.calculateTheme(for: Date(), startDate: startDate)
        if newTheme.id != currentTheme.id {
            currentTheme = newTheme
            hasUpdatedToday = true
            return true
        }
        return false
    }
    
    /// 预加载主题资源
    func preloadTheme(id: Int) async {
        // 在实际应用中，这里会加载3D模型、纹理、音频等资源
        // 为了演示，我们只是将主题放入缓存
        if let theme = ThemeLibrary.getTheme(byID: id) {
            cachedThemes[id] = theme
        }
    }
    
    /// 卸载主题资源
    func unloadTheme(id: Int) {
        cachedThemes.removeValue(forKey: id)
    }
    
    /// 获取主题名称
    var currentThemeName: String {
        currentTheme.name
    }
    
    /// 获取主题描述
    var currentThemeDescription: String {
        currentTheme.description
    }
    
    /// 开始监听日期变化
    private func startDateMonitoring() {
        // 监听应用进入前台通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // 设置定时器检查日期变化（每小时检查一次）
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            _ = self?.checkAndUpdateTheme()
        }
    }
    
    @objc private func handleAppDidBecomeActive() {
        _ = checkAndUpdateTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIApplication 导入
import UIKit
