# CyberScan3D

<div align="center">
  
  **🌌 赛博朋克风格 3D 扫描应用**
  
  *用 iPhone/iPad 相机扫描现实世界，生成可导出的 3D 模型*
  
  <img src="https://img.shields.io/badge/Platform-iOS%2017%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-6.2-orange?style=flat-square" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/ARKit-LiDAR-purple?style=flat-square" alt="ARKit">
  
</div>

---

## ✨ 核心功能

| 功能 | 描述 |
|------|------|
| 📸 **LiDAR 扫描** | 利用 iPhone/iPad Pro 的 LiDAR 传感器进行高精度空间扫描 |
| 🎮 **3D 重建** | 实时生成网格模型，支持纹理映射 |
| 🌃 **赛博朋克 UI** | 霓虹光效、故障艺术、数据流背景 |
| 📦 **多格式导出** | 支持 USDZ、OBJ、PLY 格式导出 |
| 👁️ **AR 预览** | 在增强现实中预览扫描结果 |
| 💾 **项目管理** | 本地保存扫描历史，支持重命名/删除 |

---

## 🛠 技术栈

| 技术 | 用途 |
|------|------|
| **Swift 6.2** | 主要开发语言 |
| **SwiftUI** | 现代 UI 框架 |
| **ARKit** | AR 扫描与场景重建 |
| **RealityKit** | 3D 渲染引擎 |
| **SceneKit** | 3D 场景管理 |
| **Combine** | 响应式编程 |
| **MVVM** | 架构模式 |

---

## 📱 设备要求

⚠️ **必须支持 LiDAR 的设备**

- iPhone 12 Pro / Pro Max 及以上
- iPhone 13 Pro / Pro Max 及以上
- iPhone 14 Pro / Pro Max 及以上
- iPhone 15 Pro / Pro Max 及以上
- iPad Pro 2020 及以上
- iOS 17.0+

> 💡 无 LiDAR 的设备将显示"设备不支持"提示

---

## 🚀 快速开始

### 1️⃣ 克隆项目

```bash
git clone https://github.com/huohongxu/CyberScan3D.git
cd CyberScan3D
```

### 2️⃣ 打开项目

```bash
open CyberScan3D.xcodeproj
```

或使用 Xcode 打开 `CyberScan3D.xcodeproj`

### 3️⃣ 运行项目

- 选择真机设备（模拟器不支持 AR）
- 点击运行按钮 (⌘R)

---

## 📂 项目结构

```
CyberScan3D/
├── 📱 App/                    # 应用入口
│   ├── CyberScan3DApp.swift   # SwiftUI App 入口
│   └── AppDelegate.swift      # 应用委托
│
├── 🎯 Core/                   # 核心业务层
│   ├── AR/                    # ARKit 扫描引擎
│   │   └── ARScanner.swift    # 扫描控制器
│   ├── Reconstruction/        # 3D 重建算法
│   └── Export/                # 导出处理
│       └── MeshExporter.swift # 网格导出器
│
├── 🎨 UI/                     # 界面层
│   ├── Screens/               # 各页面
│   │   ├── ScanView.swift     # 扫描主界面
│   │   ├── ProjectsView.swift # 项目列表
│   │   ├── SettingsView.swift # 设置页面
│   │   ├── ExportSheet.swift  # 导出界面
│   │   └── ARPreviewView.swift# AR 预览
│   ├── Components/            # 可复用组件
│   │   ├── CyberTabBar.swift  # 赛博风 Tab Bar
│   │   └── CyberBackgroundView.swift
│   └── Theme/                 # 赛博朋克主题
│       └── Theme.swift        # 颜色/字体/样式
│
├── 📊 Models/                 # 数据模型
│   └── ScanProject.swift      # 扫描项目模型
│
├── 🔄 ViewModels/             # 视图模型
│   └── ScanViewModel.swift    # 扫描 VM
│
├── 💾 Services/               # 服务层
│   └── ProjectStorage.swift   # 项目存储
│
└── 🔧 Utils/                  # 工具类
```

---

## 🎨 设计规范

### 赛博朋克配色方案

| 用途 | 颜色名称 | Hex | 预览 |
|------|----------|-----|------|
| 主色 | 霓虹青 | `#00F0FF` | 🔵 |
| 强调 | 赛博粉 | `#FF0080` | 🔴 |
| 警告 | 警示黄 | `#FFE600` | 🟡 |
| 辅助 | 电紫 | `#9D00FF` | 🟣 |
| 背景 | 深空黑 | `#0A0A0F` | ⚫ |
| 次背景 | 网格灰 | `#1A1A2E` | 🔘 |

### UI 设计原则

1. **高对比度** - 确保在强光下可见
2. **霓虹光效** - 边框、按钮使用发光效果
3. **故障艺术** - 加载/错误状态使用 Glitch 动画
4. **数据流背景** - 扫描界面显示流动的数据矩阵

---

## 📄 导出格式支持

| 格式 | 文件扩展名 | 用途 | 特性 |
|------|-----------|------|------|
| **USDZ** | `.usdz` | Apple AR | Quick Look 原生支持，带纹理 |
| **OBJ** | `.obj` | 通用 3D | 兼容 Blender、Maya、Cinema 4D |
| **PLY** | `.ply` | 点云 | 保留原始点云数据，适合研究 |

---

## 🔧 开发路线图

### ✅ 已完成
- [x] 项目架构搭建
- [x] MVVM 架构实现
- [x] 赛博朋克 UI 主题
- [x] 自定义 Tab Bar

### 🚧 进行中
- [ ] LiDAR 扫描引擎
- [ ] 实时网格重建
- [ ] 3D 模型导出

### 📋 计划中
- [ ] AR 预览模式
- [ ] 扫描项目管理
- [ ] iCloud 同步
- [ ] 纹理贴图优化
- [ ] 网格简化算法

---

## 🧪 测试

```bash
# 运行单元测试
⌘U in Xcode

# 或使用命令行
xcodebuild test -scheme CyberScan3D -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## 📸 应用截图

> 将在开发完成后添加

---

## 👨‍💻 作者

**霍桑**
- GitHub: [@huohongxu](https://github.com/huohongxu)

---

## 📜 License

MIT License © 2025 霍桑

详见 [LICENSE](LICENSE) 文件

---

<div align="center">
  
  **Built with ❤️ by 霍桑**
  
  **Powered by ARKit & RealityKit**
  
  ![CyberScan3D](https://img.shields.io/badge/CyberScan3D-v1.0.0-cyan?style=for-the-badge)
  
</div>