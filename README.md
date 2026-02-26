# 抓大鹅 (Catch the Big Goose)

<p align="center">
  <img src="Anser/Assets.xcassets/AppIcon.appiconset/Icon.png" width="120" alt="App Icon">
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+"></a>
  <a href="#"><img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" alt="iOS 16.0+"></a>
  <a href="#"><img src="https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS-lightgrey.svg" alt="Platform"></a>
</p>

## 🎮 游戏介绍

《抓大鹅》是一款基于 3D 物理堆叠消除机制的休闲益智手游，融合了经典三消游戏的简洁规则与创新的空间立体交互体验。

### 核心玩法
- **3D消除**：在"大锅"容器中，从随机堆叠的物品中识别、选取并消除三个相同类型的物品
- **体感颠锅**：摇晃手机触发"颠锅"效果，重新排列物品位置，创造新的消除机会
- **每日主题**：基于日期自动切换全球统一主题，每天都有新鲜体验
- **无限重玩**：当日主题可重复挑战，无次数限制，不断突破自我

## ✨ 核心特性

| 特性 | 说明 |
|------|------|
| 🎨 **每日主题** | 基于系统日期自动切换，全球玩家同步体验 |
| 📴 **纯本地架构** | 无需联网，完整离线体验 |
| 🔄 **无限重玩** | 当日主题可无限次挑战，保留最佳成绩 |
| 📳 **体感交互** | 支持摇晃手机"颠锅"，也可使用触摸按钮 |
| 🦢 **大鹅收藏** | 通关解锁不同造型大鹅，填充收藏册 |
| 🎯 **双关卡结构** | 首关教学引导，次关核心挑战 |

## 🏗️ 技术架构

### 技术栈
- **开发语言**: Swift 5.9+
- **UI框架**: SwiftUI
- **3D渲染**: SceneKit（物理模拟、动画）
- **数据持久化**: SwiftData
- **体感交互**: Core Motion（加速度计）

### 项目结构
```
Anser/
├── App/
│   └── AnserApp.swift              # 应用入口
├── Core/
│   ├── Models/                     # 数据模型
│   │   ├── GameItem.swift          # 游戏物品
│   │   ├── Theme.swift             # 主题模型
│   │   ├── Goose.swift             # 大鹅收藏
│   │   └── GameRecord.swift        # 游戏记录
│   ├── ThemeEngine/                # 主题引擎
│   │   └── ThemeEngine.swift
│   ├── GameLogic/                  # 游戏逻辑
│   │   └── GameSession.swift
│   └── Storage/                    # 数据存储
│       └── GameDataManager.swift
├── Views/
│   ├── GameSceneView.swift         # 3D游戏场景
│   ├── HomeView.swift              # 主界面
│   ├── GameView.swift              # 游戏界面
│   └── ResultView.swift            # 结果界面
├── Managers/
│   ├── ShakeDetector.swift         # 颠锅检测器
│   └── AudioManager.swift          # 音频管理
└── Resources/                      # 资源文件
```

## 🚀 快速开始

### 环境要求
- iOS 16.0+
- iPhone 11 系列及以上 / iPad 第8代及以上
- Xcode 15.0+

### 安装运行

1. 克隆仓库
```bash
git clone git@github.com:AlvinNiu/Anser.git
cd Anser
```

2. 使用 Xcode 打开项目
```bash
open Anser.xcodeproj
```

3. 选择目标设备/模拟器，点击运行

## 🎮 游戏操作指南

### 基础操作
- **点击选取**: 点击可见物品将其放入待消除栏
- **三消规则**: 待消除栏中三个相同类型物品自动消除
- **胜负判定**: 清空目标物品获胜，待消除栏满或时间耗尽则失败

### 体感颠锅
- **触发方式**: 快速摇晃手机
- **效果**: 锅中物品重新排列、散落
- **策略**: 在僵局时使用，创造新的消除机会
- **冷却**: 颠锅后有短暂冷却时间

### 替代操作
如不想使用体感或设备不支持，可使用屏幕边缘的**颠锅按钮**达到相同效果。

## 📅 每日主题系统

主题切换基于日期算法：
```swift
func getDailyThemeID() -> Int {
    let calendar = Calendar.current
    let startDate = calendar.date(from: DateComponents(year: 2026, month: 2, day: 16))!
    let daysDiff = calendar.dateComponents([.day], from: startDate, to: Date()).day!
    return daysDiff % totalThemes
}
```

- **全球同步**: 同一自然日的玩家体验相同主题
- **无限重玩**: 同一主题可重复挑战，每次布局随机生成
- **最佳成绩**: 系统记录当日最高分数

## 🦢 大鹅收藏系统

通关后可解锁对应主题的大鹅，大鹅分为四个稀有度等级：
- **普通** (Common): 基础通关即可解锁
- **稀有** (Rare): 达到指定分数解锁
- **史诗** (Epic): 高难度挑战成功解锁
- **传说** (Legendary): 完美通关（无道具、无颠锅）解锁

## 📊 性能指标

- **帧率**: 稳定 60fps (iPhone 12+)，最低 30fps
- **启动时间**: 冷启动至可交互 ≤ 3秒
- **内存占用**: 峰值 ≤ 500MB

## 🔒 隐私说明

本应用采用纯本地架构：
- ✅ 无需网络连接
- ✅ 不收集任何个人数据
- ✅ 数据仅存储于本地设备
- ✅ 支持 iCloud 备份

## 📝 开发里程碑

- [x] 第一阶段: 核心验证（SceneKit原型、体感原型）
- [x] 第二阶段: 完整玩法（主题系统、游戏闭环）
- [x] 第三阶段: 品质打磨（性能优化、动效细化）
- [ ] 第四阶段: 测试发布（全面测试、商店准备）

## 👨‍💻 开发者

**牛慧升** (Alvin Niu)

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

<p align="center">
  <i>Made with ❤️ using SwiftUI & SceneKit</i>
</p>
