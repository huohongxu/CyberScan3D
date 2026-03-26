//
//  ScanView.swift
//  CyberScan3D
//
//  扫描主界面
//

import SwiftUI

struct ScanView: View {
    @StateObject private var viewModel = ScanViewModel()
    @State private var showARPreview: Bool = false
    
    var body: some View {
        ZStack {
            // AR 相机视图
            ARCameraViewRepresentable()
                .edgesIgnoringSafeArea(.all)
            
            // 数据流背景（半透明）
            DataMatrixView()
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            // 主内容
            VStack {
                // 顶部状态栏
                statusBarView
                
                Spacer()
                
                // 中央信息显示
                centerInfoView
                
                Spacer()
                
                // 底部控制栏
                controlBarView
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ExportSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsSheet(settings: $viewModel.settings)
        }
        .fullScreenCover(isPresented: $showARPreview) {
            if let project = viewModel.currentProject {
                ARPreviewView(project: project)
            }
        }
    }
    
    // MARK: - Status Bar
    
    private var statusBarView: some View {
        HStack {
            // 状态指示
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .glow(color: statusColor, radius: 5)
                
                Text(viewModel.state.title)
                    .font(.cyberCaption)
                    .foregroundColor(.cyberWhite)
            }
            
            Spacer()
            
            // 统计信息
            if let stats = viewModel.meshStatistics {
                HStack(spacing: 16) {
                    statItem(icon: "point.3.connected", value: stats.formattedVertices)
                    statItem(icon: "square.grid.3x3", value: stats.formattedFaces)
                    statItem(icon: "clock", value: stats.formattedDuration)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cyberDarker.opacity(0.8))
        .cornerRadius(12)
        .neonBorder(color: .cyberCyan, lineWidth: 1)
    }
    
    private func statItem(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.cyberCyan)
            Text(value)
                .font(.cyberCaption)
                .foregroundColor(.cyberWhite)
        }
    }
    
    private var statusColor: Color {
        switch viewModel.state {
        case .idle, .completed:
            return .cyberCyan
        case .preparing, .processing:
            return .cyberYellow
        case .scanning:
            return .cyberSuccess
        case .error:
            return .cyberError
        }
    }
    
    // MARK: - Center Info
    
    private var centerInfoView: some View {
        VStack(spacing: 24) {
            if viewModel.state == .idle {
                // 空闲状态提示
                VStack(spacing: 16) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.cyberCyan)
                        .glow(color: .cyberCyan, radius: 20)
                    
                    Text("对准目标物体")
                        .font(.cyberTitle3)
                        .foregroundColor(.cyberWhite)
                    
                    Text("缓慢移动设备进行扫描")
                        .font(.cyberBody)
                        .foregroundColor(.cyberGray)
                }
            } else if viewModel.state == .scanning {
                // 扫描进度
                VStack(spacing: 16) {
                    // 圆形进度
                    ZStack {
                        Circle()
                            .stroke(Color.cyberDark, lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                Color.cyberCyan,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .glow(color: .cyberCyan, radius: 10)
                        
                        VStack(spacing: 4) {
                            Text(viewModel.formattedProgress)
                                .font(.cyberDataLarge)
                                .foregroundColor(.cyberWhite)
                            
                            Text("完成")
                                .font(.cyberCaption)
                                .foregroundColor(.cyberGray)
                        }
                    }
                    
                    // 提示
                    Text("保持稳定，缓慢移动")
                        .font(.cyberBody)
                        .foregroundColor(.cyberCyan)
                }
            } else if viewModel.state == .processing {
                // 处理中
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CyberProgressStyle())
                    
                    Text("正在生成模型...")
                        .font(.cyberBody)
                        .foregroundColor(.cyberYellow)
                }
            }
        }
    }
    
    // MARK: - Control Bar
    
    private var controlBarView: some View {
        VStack(spacing: 16) {
            // 主控制按钮
            HStack(spacing: 24) {
                // 设置按钮
                Button {
                    viewModel.showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                        .foregroundColor(.cyberCyan)
                        .frame(width: 50, height: 50)
                        .background(Color.cyberDark)
                        .cornerRadius(25)
                        .neonBorder(color: .cyberCyan)
                }
                
                // 扫描按钮
                Button {
                    if viewModel.isScanning {
                        viewModel.stopScan()
                    } else {
                        viewModel.startScan()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(viewModel.isScanning ? Color.cyberPink : Color.cyberCyan)
                            .frame(width: 70, height: 70)
                            .glow(color: viewModel.isScanning ? .cyberPink : .cyberCyan, radius: 15)
                        
                        Image(systemName: viewModel.isScanning ? "stop.fill" : "camera.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.cyberBlack)
                    }
                }
                
                // 导出按钮
                Button {
                    viewModel.showExportSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.cyberPink)
                        .frame(width: 50, height: 50)
                        .background(Color.cyberDark)
                        .cornerRadius(25)
                        .neonBorder(color: .cyberPink)
                }
                .disabled(viewModel.state != .completed)
                .opacity(viewModel.state == .completed ? 1 : 0.5)
            }
            
            // 次要操作
            if viewModel.state == .completed {
                Button {
                    showARPreview = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "eye.fill")
                        Text("AR 预览")
                    }
                    .font(.cyberHeadline)
                    .foregroundColor(.cyberPurple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.cyberDark)
                    .cornerRadius(8)
                    .neonBorder(color: .cyberPurple)
                }
            }
        }
    }
}

// MARK: - AR Camera View Representable

import ARKit

struct ARCameraViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .mesh
        config.environmentTexturing = .automatic
        
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// MARK: - AR View

class ARView: UIView {
    let session = ARSession()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // 配置 AR 显示
        let sceneView = ARSCNView(frame: bounds)
        sceneView.session = session
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.debugOptions = [.showWireframe]
        
        addSubview(sceneView)
    }
}

#Preview {
    ScanView()
}