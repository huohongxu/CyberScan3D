//
//  ARPreviewView.swift
//  CyberScan3D
//
//  AR 预览界面
//

import SwiftUI
import ARKit
import RealityKit

struct ARPreviewView: View {
    let project: ScanProject
    @Environment(\.dismiss) var dismiss
    @State private var showControls: Bool = true
    
    var body: some View {
        ZStack {
            // AR 场景
            ARPreviewSceneView(modelURL: project.modelURL)
                .edgesIgnoringSafeArea(.all)
            
            // 顶部控制栏
            VStack {
                if showControls {
                    HStack {
                        // 关闭按钮
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.cyberBlack)
                                .frame(width: 44, height: 44)
                                .background(Color.cyberCyan)
                                .cornerRadius(22)
                                .glow(color: .cyberCyan, radius: 10)
                        }
                        
                        Spacer()
                        
                        // 项目名称
                        Text(project.name)
                            .font(.cyberHeadline)
                            .foregroundColor(.cyberWhite)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.cyberDarker.opacity(0.8))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        // 占位
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.cyberBlack.opacity(0.6), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                Spacer()
                
                // 底部提示
                if showControls {
                    VStack(spacing: 8) {
                        Text("移动设备查看模型")
                            .font(.cyberBody)
                            .foregroundColor(.cyberWhite)
                        
                        Text("双指缩放 · 单指旋转")
                            .font(.cyberCaption)
                            .foregroundColor(.cyberGray)
                    }
                    .padding()
                    .background(Color.cyberDarker.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.bottom, 40)
                }
            }
        }
        .onTapGesture {
            withAnimation {
                showControls.toggle()
            }
        }
    }
}

// MARK: - AR Preview Scene View

struct ARPreviewSceneView: UIViewRepresentable {
    let modelURL: URL?
    
    func makeUIView(context: Context) -> ARQuickLookPreviewView {
        let view = ARQuickLookPreviewView()
        
        if let url = modelURL {
            view.loadModel(from: url)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: ARQuickLookPreviewView, context: Context) {}
}

// MARK: - AR Quick Look Preview View

class ARQuickLookPreviewView: UIView {
    private var arView: ARView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let arView = ARView(frame: bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 配置 AR
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)
        
        self.arView = arView
        addSubview(arView)
    }
    
    func loadModel(from url: URL) {
        guard let arView = arView else { return }
        
        Task {
            do {
                let model = try await ModelEntity(contentsOf: url)
                
                // 生成碰撞形状
                model.generateCollisionShapes(recursive: true)
                
                // 添加到场景
                let anchor = AnchorEntity(plane: .any)
                anchor.addChild(model)
                arView.scene.anchors.append(anchor)
            } catch {
                print("加载模型失败: \(error)")
            }
        }
    }
}

#Preview {
    ARPreviewView(project: ScanProject(name: "测试模型"))
}