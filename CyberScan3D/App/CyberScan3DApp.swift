//
//  CyberScan3DApp.swift
//  CyberScan3D
//
//  赛博朋克风格 3D 扫描应用
//  Created by 霍桑 on 2025/03/25.
//

import SwiftUI

@main
struct CyberScan3DApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - App State

/// 全局应用状态
final class AppState: ObservableObject {
    @Published var isScanning: Bool = false
    @Published var currentProject: ScanProject?
    @Published var projects: [ScanProject] = []
    @Published var deviceCapability: DeviceCapability = .check()
    
    init() {
        loadProjects()
    }
    
    private func loadProjects() {
        if let loaded = try? ProjectStorage.shared.loadAll() {
            projects = loaded
        }
    }
}

// MARK: - Device Capability

/// 设备能力检测
enum DeviceCapability {
    case supported
    case noLidar
    case outdatedOS
    
    static func check() -> DeviceCapability {
        // 检测 LiDAR 支持
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
            return .noLidar
        }
        return .supported
    }
    
    var errorMessage: String? {
        switch self {
        case .supported:
            return nil
        case .noLidar:
            return "此设备不支持 LiDAR 扫描。\n请使用 iPhone 12 Pro 及以上或 iPad Pro 2020 及以上设备。"
        case .outdatedOS:
            return "系统版本过低。\n请升级至 iOS 17.0 或更高版本。"
        }
    }
}

// MARK: - Root View

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.deviceCapability.errorMessage != nil {
                DeviceNotSupportedView(
                    message: appState.deviceCapability.errorMessage ?? ""
                )
            } else {
                MainTabView()
            }
        }
        .cyberBackground()
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: Tab = .scan
    
    enum Tab: Int, CaseIterable {
        case scan = 0
        case projects = 1
        case settings = 2
        
        var title: String {
            switch self {
            case .scan: return "扫描"
            case .projects: return "项目"
            case .settings: return "设置"
            }
        }
        
        var icon: String {
            switch self {
            case .scan: return "camera.viewfinder"
            case .projects: return "folder.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 赛博朋克背景
            CyberBackgroundView()
            
            VStack(spacing: 0) {
                // 内容区域
                Group {
                    switch selectedTab {
                    case .scan:
                        ScanView()
                    case .projects:
                        ProjectsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 自定义 Tab Bar
                CyberTabBar(
                    selectedTab: $selectedTab,
                    tabs: Tab.allCases
                )
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Device Not Supported View

struct DeviceNotSupportedView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.cyberPink)
                .glow(color: .cyberPink, radius: 20)
            
            Text("设备不支持")
                .font(.cyberTitle2)
                .foregroundColor(.cyberCyan)
            
            Text(message)
                .font(.cyberBody)
                .foregroundColor(.cyberGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cyberBackground()
    }
}

// MARK: - Preview

#Preview {
    CyberScan3DApp()
}