//
//  SettingsView.swift
//  CyberScan3D
//
//  设置界面
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.cyberBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 应用信息
                    appInfoSection
                    
                    // 扫描设置
                    scanSettingsSection
                    
                    // 导出设置
                    exportSettingsSection
                    
                    // 关于
                    aboutSection
                }
                .padding()
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - App Info
    
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundColor(.cyberCyan)
                .glow(color: .cyberCyan, radius: 15)
            
            Text("CyberScan3D")
                .font(.cyberTitle2)
                .foregroundColor(.cyberWhite)
            
            Text("版本 1.0.0")
                .font(.cyberCaption)
                .foregroundColor(.cyberGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - Scan Settings
    
    private var scanSettingsSection: some View {
        SettingsSection(title: "扫描设置", icon: "camera") {
            VStack(spacing: 0) {
                SettingsRow(title: "网格精度") {
                    Menu {
                        Button("低") {}
                        Button("中") {}
                        Button("高") {}
                    } label: {
                        Text("中")
                            .font(.cyberBody)
                            .foregroundColor(.cyberCyan)
                    }
                }
                
                Divider().background(Color.cyberDark)
                
                SettingsRow(title: "纹理映射") {
                    Toggle("", isOn: .constant(true))
                        .tint(.cyberCyan)
                }
                
                Divider().background(Color.cyberDark)
                
                SettingsRow(title: "场景分类") {
                    Toggle("", isOn: .constant(true))
                        .tint(.cyberCyan)
                }
                
                Divider().background(Color.cyberDark)
                
                SettingsRow(title: "自动保存") {
                    Toggle("", isOn: .constant(true))
                        .tint(.cyberCyan)
                }
            }
        }
    }
    
    // MARK: - Export Settings
    
    private var exportSettingsSection: some View {
        SettingsSection(title: "导出设置", icon: "square.and.arrow.up") {
            VStack(spacing: 0) {
                SettingsRow(title: "默认格式") {
                    Menu {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Button(format.displayName) {}
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("USDZ")
                                .font(.cyberBody)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.cyberCyan)
                    }
                }
                
                Divider().background(Color.cyberDark)
                
                SettingsRow(title: "纹理分辨率") {
                    Menu {
                        Button("1024") {}
                        Button("2048") {}
                        Button("4096") {}
                    } label: {
                        HStack(spacing: 4) {
                            Text("2048")
                                .font(.cyberBody)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.cyberCyan)
                    }
                }
            }
        }
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        SettingsSection(title: "关于", icon: "info.circle") {
            VStack(spacing: 0) {
                SettingsRow(title: "开发者") {
                    Text("霍桑")
                        .font(.cyberBody)
                        .foregroundColor(.cyberGray)
                }
                
                Divider().background(Color.cyberDark)
                
                SettingsRow(title: "技术支持") {
                    Link(destination: URL(string: "https://github.com/huohongxu/CyberScan3D")!) {
                        HStack(spacing: 4) {
                            Text("GitHub")
                                .font(.cyberBody)
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.cyberCyan)
                    }
                }
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.cyberHeadline)
                .foregroundColor(.cyberCyan)
            
            content()
                .padding(16)
                .background(Color.cyberDarker)
                .cornerRadius(12)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack {
            Text(title)
                .font(.cyberBody)
                .foregroundColor(.cyberWhite)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings Sheet

struct SettingsSheet: View {
    @Binding var settings: ScanSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            SettingsView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            dismiss()
                        }
                        .foregroundColor(.cyberCyan)
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}