//
//  AppDelegate.swift
//  CyberScan3D
//
//  应用委托 - 处理应用生命周期
//

import UIKit
import UserNotifications
import ARKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Application Lifecycle
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 1. 初始化日志系统
        setupLogging()
        
        // 2. 配置推送通知
        setupNotifications(application)
        
        // 3. 配置 AR 权限
        setupARPermissions()
        
        // 4. 配置应用外观
        setupAppearance()
        
        print("✅ App 启动完成")
        return true
    }
    
    // MARK: - Scene Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UISceneConnectionOptions
    ) -> UISceneConfiguration {
        
        let sceneConfig = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfig.delegateClass = SceneDelegate.self
        
        return sceneConfig
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // 场景被丢弃时调用
        print("🔄 场景被丢弃")
    }
    
    // MARK: - Background Tasks
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App 进入后台")
        
        // 暂停 AR 扫描
        NotificationCenter.default.post(name: NSNotification.Name("ARScannerPause"), object: nil)
        
        // 保存项目状态
        saveAppState()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 App 返回前台")
        
        // 恢复 AR 扫描
        NotificationCenter.default.post(name: NSNotification.Name("ARScannerResume"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("✅ App 变为活跃")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("❌ App 即将终止")
        
        // 清理资源
        cleanup()
    }
    
    // MARK: - URL Handling (Deep Link)
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        
        print("🔗 处理 Deep Link: \(url)")
        
        // 处理自定义 URL Scheme
        if url.scheme == "cyberscan3d" {
            handleDeepLink(url)
            return true
        }
        
        return false
    }
    
    // MARK: - Private Methods
    
    private func setupLogging() {
        #if DEBUG
        print("🔧 调试模式已启用")
        #else
        print("🚀 发布模式已启用")
        #endif
    }
    
    private func setupNotifications(_ application: UIApplication) {
        // 请求推送通知权限
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("✅ 推送通知已授权")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("❌ 推送通知授权失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupARPermissions() {
        // 检查 AR 支持
        guard ARWorldTrackingConfiguration.isSupported else {
            print("⚠️ 设备不支持 AR")
            return
        }
        
        // 检查 LiDAR 支持
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            print("✅ LiDAR 扫描已支持")
        } else {
            print("⚠️ 设备不支持 LiDAR")
        }
    }
    
    private func setupAppearance() {
        // 配置全局外观
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.09, alpha: 1.0) // cyberBlack
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // 解析 Deep Link
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        if let action = components.host {
            switch action {
            case "scan":
                // 打开扫描界面
                NotificationCenter.default.post(name: NSNotification.Name("OpenScanView"), object: nil)
            case "project":
                // 打开项目详情
                if let projectId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenProject"),
                        object: projectId
                    )
                }
            default:
                break
            }
        }
    }
    
    private func saveAppState() {
        // 保存应用状态
        UserDefaults.standard.set(Date(), forKey: "lastBackgroundTime")
    }
    
    private func cleanup() {
        // 清理资源
        print("🧹 清理资源")
    }
}

// MARK: - Remote Notifications

extension AppDelegate {
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📲 Device Token: \(token)")
        
        // 保存 token 到服务器
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ 远程通知注册失败: \(error.localizedDescription)")
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📬 收到远程通知: \(userInfo)")
        completionHandler(.newData)
    }
}

// MARK: - Local Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 前台收到通知: \(notification.request.content.body)")
        
        // 前台显示通知
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("👆 用户点击通知")
        
        let userInfo = response.notification.request.content.userInfo
        handleNotificationTap(userInfo)
        
        completionHandler()
    }
    
    private func handleNotificationTap(_ userInfo: [AnyHashable: Any]) {
        // 处理通知点击
        if let action = userInfo["action"] as? String {
            print("执行通知动作: \(action)")
        }
    }
}