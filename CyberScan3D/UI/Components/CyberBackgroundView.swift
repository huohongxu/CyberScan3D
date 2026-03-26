//
//  CyberBackgroundView.swift
//  CyberScan3D
//
//  赛博朋克动态背景
//

import SwiftUI

/// 赛博朋克风格背景视图
struct CyberBackgroundView: View {
    @State private var particles: [Particle] = []
    @State private var gridOffset: CGFloat = 0
    @State private var scanLineY: CGFloat = 0
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 深空背景
                Color.cyberBlack
                
                // 网格线
                gridView(geometry: geometry)
                
                // 扫描线动画
                scanLineView(geometry: geometry)
                
                // 粒子效果
                particlesView(geometry: geometry)
                
                // 边角装饰
                cornerDecorations(geometry: geometry)
            }
            .onAppear {
                initializeParticles(in: geometry.size)
                startAnimations(geometry: geometry)
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Grid View
    
    private func gridView(geometry: GeometryProxy) -> some View {
        Canvas { context, size in
            // 水平线
            for i in stride(from: 0, through: Int(size.height), by: 40) {
                let y = CGFloat(i) + gridOffset.truncatingRemainder(dividingBy: 40)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(
                    path,
                    with: .color(Color.cyberCyan.opacity(0.05)),
                    lineWidth: 1
                )
            }
            
            // 垂直线
            for i in stride(from: 0, through: Int(size.width), by: 40) {
                let x = CGFloat(i)
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(
                    path,
                    with: .color(Color.cyberCyan.opacity(0.05)),
                    lineWidth: 1
                )
            }
        }
    }
    
    // MARK: - Scan Line
    
    private func scanLineView(geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .cyberCyan.opacity(0.3),
                        .cyberCyan.opacity(0.5),
                        .cyberCyan.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .offset(y: scanLineY)
            .shadow(color: .cyberCyan, radius: 10)
    }
    
    // MARK: - Particles
    
    private func particlesView(geometry: GeometryProxy) -> some View {
        ForEach(particles) { particle in
            Circle()
                .fill(particle.color)
                .frame(width: particle.size, height: particle.size)
                .offset(x: particle.x, y: particle.y)
                .opacity(particle.opacity)
        }
    }
    
    // MARK: - Corner Decorations
    
    private func cornerDecorations(geometry: GeometryProxy) -> some View {
        ZStack {
            // 左上角
            CornerDecoration()
                .position(x: 30, y: 30)
            
            // 右上角
            CornerDecoration()
                .rotationEffect(.degrees(90))
                .position(x: geometry.size.width - 30, y: 30)
            
            // 右下角
            CornerDecoration()
                .rotationEffect(.degrees(180))
                .position(x: geometry.size.width - 30, y: geometry.size.height - 30)
            
            // 左下角
            CornerDecoration()
                .rotationEffect(.degrees(270))
                .position(x: 30, y: geometry.size.height - 30)
        }
    }
    
    // MARK: - Animation Logic
    
    private func initializeParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 1...3),
                color: [.cyberCyan, .cyberPink, .cyberPurple].randomElement()!,
                speed: CGFloat.random(in: 0.5...2),
                opacity: Double.random(in: 0.3...0.7)
            )
        }
    }
    
    private func startAnimations(geometry: GeometryProxy) {
        // 网格移动
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            gridOffset = 40
        }
        
        // 扫描线
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            scanLineY = geometry.size.height
        }
    }
    
    private func updateParticles(in size: CGSize) {
        for i in particles.indices {
            particles[i].y += particles[i].speed
            if particles[i].y > size.height {
                particles[i].y = 0
                particles[i].x = CGFloat.random(in: 0...size.width)
            }
        }
    }
}

// MARK: - Particle Model

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    let speed: CGFloat
    let opacity: Double
}

// MARK: - Corner Decoration

struct CornerDecoration: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Color.cyberCyan.opacity(0.5), lineWidth: 2)
        .frame(width: 20, height: 20)
    }
}

// MARK: - Data Matrix View (用于扫描界面)

/// 数据流矩阵背景
struct DataMatrixView: View {
    @State private var columns: [DataColumn] = []
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(columns) { column in
                    HStack(spacing: 0) {
                        Spacer()
                        VStack(spacing: 2) {
                            ForEach(column.chars, id: \.self) { char in
                                Text(char)
                                    .font(.system(size: 10, weight: .light, design: .monospaced))
                                    .foregroundColor(.cyberCyan.opacity(column.opacity))
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 20)
                    .offset(x: column.x, y: column.y)
                }
            }
            .onAppear {
                initializeColumns(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateColumns(in: geometry.size)
            }
        }
    }
    
    private func initializeColumns(in size: CGSize) {
        let columnCount = Int(size.width / 25)
        columns = (0..<columnCount).map { i in
            DataColumn(
                x: CGFloat(i * 25),
                y: CGFloat.random(in: -size.height...0),
                chars: randomChars(count: Int(size.height / 12)),
                speed: CGFloat.random(in: 2...5),
                opacity: Double.random(in: 0.1...0.3)
            )
        }
    }
    
    private func updateColumns(in size: CGSize) {
        for i in columns.indices {
            columns[i].y += columns[i].speed
            if columns[i].y > size.height {
                columns[i].y = -CGFloat(columns[i].chars.count * 12)
                columns[i].chars = randomChars(count: columns[i].chars.count)
            }
        }
    }
    
    private func randomChars(count: Int) -> [String] {
        let chars = "01アイウエオカキクケコサシスセソ"
        return (0..<count).map { _ in
            String(chars.randomElement()!)
        }
    }
}

struct DataColumn: Identifiable {
    let id = UUID()
    let x: CGFloat
    var y: CGFloat
    var chars: [String]
    let speed: CGFloat
    let opacity: Double
}