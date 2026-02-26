//
//  AnserApp.swift
//  Anser
//
//  抓大鹅 - 3D消除类休闲游戏
//

import SwiftUI

@main
struct AnserApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    // 请求运动权限（用于颠锅功能）
                    ShakeDetector.shared.requestPermission()
                }
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 配置音频会话（触发单例初始化）
        _ = AudioManager.shared
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 检查主题更新
        _ = ThemeEngine.shared.checkAndUpdateTheme()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 保存数据
        GameDataManager.shared.savePlayerProfile()
        GameDataManager.shared.saveCollectionManager()
        GameDataManager.shared.saveGameSettings()
        GameDataManager.shared.saveGameStatistics()
    }
}
