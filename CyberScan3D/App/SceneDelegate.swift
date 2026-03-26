//
//  SceneDelegate.swift
//  CyberScan3D
//
//  场景委托 - 处理场景生命周期
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - Scene Lifecycle
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        print("🎬 场景即将连接")
        
        // 获取 WindowScene
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // 创建 SwiftUI 根视图
        let rootView = RootView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
        
        // 创建 UIHostingController
        let hostingController = UIHostingController(rootViewController: rootView)
        
        // 创建窗口
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        self.window = window
        
        // 处理启动选项
        handleConnectionOptions(connectionOptions)
        
        print("✅ 场景已连接")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("✅ 场景变为活跃")
        
        // 恢复应用状态
        restoreAppState()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("⏸️ 场景即将失活")
        
        // 保存应用状态
        saveAppState()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("📱 场景即将进入前台")
        
        // 恢复 AR 扫描
        NotificationCenter.default.post(name: NSNotification.Name("ARScannerResume"), object: nil)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("📱 场景已进入后台")
        
        // 暂停 AR 扫描
        NotificationCenter.default.post(name: NSNotification.Name("ARScannerPause"), object: nil)
        
        // 保存项目
        saveProjects()
    }
    
    // MARK: - URL Handling
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        
        for context in URLContexts {
            let url = context.url
            print("🔗 场景处理 URL: \(url)")
            
            // 处理文件打开
            if url.isFileURL {
                handleFileOpen(url)
            }
        }
    }
    
    // MARK: - User Activity (Handoff)
    
    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        
        print("🔄 继续用户活动: \(userActivity.activityType)")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                print("🌐 打开网页: \(url)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleConnectionOptions(_ options: UIScene.ConnectionOptions) {
        // 处理 URL
        for context in options.urlContexts {
            let url = context.url
            print("📂 启动时打开文件: \(url)")
            handleFileOpen(url)
        }
        
        // 处理通知
        if let notification = options.notificationResponse {
            print("🔔 启动时收到通知")
            handleNotification(notification)
        }
    }
    
    private func handleFileOpen(_ url: URL) {
        // 处理文件打开（如导入 3D 模型）
        if url.pathExtension == "usdz" || url.pathExtension == "obj" || url.pathExtension == "ply" {
            print("📦 导入 3D 模型: \(url.lastPathComponent)")
            
            // 发送通知给 ViewModel
            NotificationCenter.default.post(
                name: NSNotification.Name("ImportModel"),
                object: url
            )
        }
    }
    
    private func handleNotification(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        if let action = userInfo["action"] as? String {
            print("执行通知动作: \(action)")
        }
    }
    
    private func saveAppState() {
        print("💾 保存应用状态")
        
        // 保存当前时间
        UserDefaults.standard.set(Date(), forKey: "lastActiveTime")
        
        // 保存其他状态
        UserDefaults.standard.synchronize()
    }
    
    private func restoreAppState() {
        print("📂 恢复应用状态")
        
        // 从 UserDefaults 恢复状态
        if let lastActiveTime = UserDefaults.standard.object(forKey: "lastActiveTime") as? Date {
            let elapsed = Date().timeIntervalSince(lastActiveTime)
            print("距离上次活跃已过 \(Int(elapsed)) 秒")
        }
    }
    
    private func saveProjects() {
        print("💾 保存项目")
        
        // 保存所有项目到本地存储
        do {
            let projects = try ProjectStorage.shared.loadAll()
            print("已保存 \(projects.count) 个项目")
        } catch {
            print("❌ 保存项目失败: \(error)")
        }
    }
}

// MARK: - Helper Extension

extension UIHostingController {
    convenience init<Content: View>(rootViewController: Content) {
        self.init(rootView: rootViewController)
    }
}