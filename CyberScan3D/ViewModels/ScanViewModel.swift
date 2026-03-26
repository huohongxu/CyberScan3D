//
//  ScanViewModel.swift
//  CyberScan3D
//
//  扫描视图模型
//

import SwiftUI
import ARKit
import RealityKit
import Combine

@MainActor
final class ScanViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var state: ScanState = .idle
    @Published var progress: Double = 0
    @Published var meshStatistics: MeshStatistics?
    @Published var currentProject: ScanProject?
    @Published var showExportSheet: Bool = false
    @Published var showSettings: Bool = false
    @Published var settings: ScanSettings = ScanSettings()
    
    // MARK: - Private Properties
    
    private var arSession: ARSession?
    private var meshAnchors: [ARMeshAnchor] = []
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var formattedProgress: String {
        String(format: "%.0f%%", progress * 100)
    }
    
    var isScanning: Bool {
        state == .scanning
    }
    
    // MARK: - Actions
    
    func startScan() {
        guard state.canStart else { return }
        
        state = .preparing
        
        // 配置 AR Session
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.environmentTexturing = .automatic
        
        if settings.enableClassification {
            configuration.sceneReconstruction = .meshWithClassification
        }
        
        // 创建新项目
        currentProject = ScanProject(name: "扫描 \(Date().formatted(date: .abbreviated, time: .shortened))")
        startTime = Date()
        meshAnchors.removeAll()
        
        // 启动扫描
        state = .scanning
        progress = 0
        
        // 模拟进度更新（实际由 ARKit 回调驱动）
        startProgressTimer()
    }
    
    func pauseScan() {
        guard state == .scanning else { return }
        state = .idle
        arSession?.pause()
    }
    
    func stopScan() {
        guard state == .scanning || state == .idle else { return }
        
        state = .processing
        
        // 处理网格数据
        Task {
            await processMesh()
        }
    }
    
    func exportModel(format: ExportFormat) async throws -> URL {
        guard let project = currentProject else {
            throw ExportError.noProject
        }
        
        let outputURL = try await MeshExporter.export(
            meshAnchors: meshAnchors,
            format: format,
            projectName: project.name
        )
        
        return outputURL
    }
    
    func saveProject() async {
        guard var project = currentProject else { return }
        
        project.modifiedAt = Date()
        project.meshStatistics = meshStatistics
        
        // 保存到本地
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(project)
            let url = FileManager.default
                .documentsDirectory
                .appendingPathComponent("Projects")
                .appendingPathComponent("\(project.id.uuidString).json")
            
            try data.write(to: url)
        } catch {
            print("保存项目失败: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func startProgressTimer() {
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.state == .scanning else { return }
                
                // 根据扫描时间计算进度
                if let startTime = self.startTime {
                    let elapsed = Date().timeIntervalSince(startTime)
                    // 5 分钟扫描为 100%
                    self.progress = min(elapsed / 300, 1.0)
                }
                
                // 更新统计信息
                self.updateStatistics()
            }
            .store(in: &cancellables)
    }
    
    private func updateStatistics() {
        var totalVertices = 0
        var totalFaces = 0
        
        for anchor in meshAnchors {
            let geometry = anchor.geometry
            totalVertices += geometry.vertices.count
            totalFaces += geometry.faces.count
        }
        
        meshStatistics = MeshStatistics(
            vertexCount: totalVertices,
            faceCount: totalFaces,
            boundingBox: BoundingBox(
                minX: 0, maxX: 1,
                minY: 0, maxY: 1,
                minZ: 0, maxZ: 1
            ),
            scanDuration: startTime.map { Date().timeIntervalSince($0) } ?? 0,
            textureResolution: settings.enableTexture ? 2048 : nil
        )
    }
    
    private func processMesh() async {
        // 模拟处理延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 更新最终统计
        updateStatistics()
        
        state = .completed
        progress = 1.0
    }
}

// MARK: - Export Error

enum ExportError: LocalizedError {
    case noProject
    case noMesh
    case exportFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noProject:
            return "没有可导出的项目"
        case .noMesh:
            return "没有扫描数据"
        case .exportFailed(let message):
            return "导出失败: \(message)"
        }
    }
}