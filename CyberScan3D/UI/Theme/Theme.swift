//
//  Theme.swift
//  CyberScan3D
//
//  赛博朋克主题定义
//

import SwiftUI

// MARK: - Cyber Colors

extension Color {
    // 主色调
    static let cyberCyan = Color(hex: "00F0FF")      // 霓虹青
    static let cyberPink = Color(hex: "FF0080")      // 赛博粉
    static let cyberYellow = Color(hex: "FFE600")    // 警示黄
    static let cyberPurple = Color(hex: "9D00FF")    // 电紫
    
    // 背景色
    static let cyberBlack = Color(hex: "0A0A0F")     // 深空黑
    static let cyberDark = Color(hex: "1A1A2E")      // 网格灰
    static let cyberDarker = Color(hex: "0F0F1A")    // 更深黑
    
    // 文字色
    static let cyberWhite = Color(hex: "E0E0E0")     // 主文字
    static let cyberGray = Color(hex: "8888AA")      // 次文字
    static let cyberMuted = Color(hex: "555566")     // 弱化文字
    
    // 状态色
    static let cyberSuccess = Color(hex: "00FF88")   // 成功绿
    static let cyberError = Color(hex: "FF3333")     // 错误红
    static let cyberWarning = Color(hex: "FFAA00")   // 警告橙
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Cyber Fonts

extension Font {
    static let cyberLargeTitle = Font.system(size: 34, weight: .heavy, design: .monospaced)
    static let cyberTitle = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let cyberTitle2 = Font.system(size: 22, weight: .semibold, design: .monospaced)
    static let cyberTitle3 = Font.system(size: 20, weight: .semibold, design: .monospaced)
    static let cyberHeadline = Font.system(size: 17, weight: .semibold, design: .monospaced)
    static let cyberBody = Font.system(size: 17, weight: .regular, design: .monospaced)
    static let cyberCallout = Font.system(size: 16, weight: .regular, design: .monospaced)
    static let cyberSubheadline = Font.system(size: 15, weight: .regular, design: .monospaced)
    static let cyberFootnote = Font.system(size: 13, weight: .regular, design: .monospaced)
    static let cyberCaption = Font.system(size: 12, weight: .regular, design: .monospaced)
    static let cyberCaption2 = Font.system(size: 11, weight: .regular, design: .monospaced)
    
    // 数据显示字体（等宽）
    static let cyberData = Font.system(size: 14, weight: .medium, design: .monospaced)
    static let cyberDataLarge = Font.system(size: 24, weight: .bold, design: .monospaced)
}

// MARK: - Glow Effect

extension View {
    /// 霓虹发光效果
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius)
    }
    
    /// 赛博朋克背景
    func cyberBackground() -> some View {
        self.background(Color.cyberBlack)
    }
    
    /// 赛博朋克卡片样式
    func cyberCard() -> some View {
        self
            .background(Color.cyberDark)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyberCyan.opacity(0.3), lineWidth: 1)
            )
    }
    
    /// 霓虹边框
    func neonBorder(color: Color = .cyberCyan, lineWidth: CGFloat = 1) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: lineWidth)
                .glow(color: color, radius: 5)
        )
    }
}

// MARK: - Cyber Button Style

struct CyberButtonStyle: ButtonStyle {
    let color: Color
    let isOutlined: Bool
    
    init(color: Color = .cyberCyan, isOutlined: Bool = false) {
        self.color = color
        self.isOutlined = isOutlined
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cyberHeadline)
            .foregroundColor(isOutlined ? color : .cyberBlack)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isOutlined {
                        Color.clear
                    } else {
                        configuration.isPressed ? color.opacity(0.8) : color
                    }
                }
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: isOutlined ? 2 : 0)
            )
            .glow(color: color, radius: configuration.isPressed ? 5 : 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CyberButtonStyle {
    static var cyberPrimary: CyberButtonStyle { CyberButtonStyle(color: .cyberCyan) }
    static var cyberSecondary: CyberButtonStyle { CyberButtonStyle(color: .cyberPink) }
    static var cyberOutlined: CyberButtonStyle { CyberButtonStyle(color: .cyberCyan, isOutlined: true) }
}

// MARK: - Cyber Progress Style

struct CyberProgressStyle: ProgressViewStyle {
    let color: Color
    
    init(color: Color = .cyberCyan) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // 背景轨道
            Circle()
                .stroke(Color.cyberDark, lineWidth: 4)
                .frame(width: 40, height: 40)
            
            // 进度环
            Circle()
                .trim(from: 0, to: configuration.fractionCompleted ?? 0)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .glow(color: color, radius: 5)
        }
    }
}

// MARK: - Glitch Effect

/// 故障艺术效果（用于错误/加载状态）
struct GlitchText: View {
    let text: String
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // RGB 分离效果
            Text(text)
                .foregroundColor(.cyberCyan)
                .offset(x: offset)
            
            Text(text)
                .foregroundColor(.cyberPink)
                .offset(x: -offset)
            
            Text(text)
                .foregroundColor(.cyberWhite)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                offset = 2
            }
        }
    }
}