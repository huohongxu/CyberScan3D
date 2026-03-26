//
//  ARScanner.swift
//  CyberScan3D
//
//  AR 扫描引擎
//

import Foundation
import ARKit
import Combine

/// AR 扫描引擎
@MainActor
final class ARScanner: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var meshAnchors: [ARMeshAnchor] = []
    @Published var scanState: ScanState = .idle
    @Published var trackingState: ARCamera.TrackingState = .notAvailable
    @Published var meshExtent: simd_float3 = .zero
    
    // MARK: - Private Properties
    
    private(set) var session: ARSession
    private var configuration: ARWorldTrackingConfiguration
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    
    var onMeshUpdated: ((ARMeshAnchor) -> Void)?
    var onScanCompleted: (([ARMeshAnchor]) -> Void)?
    
    // MARK: - Initialization
    
    override init() {
        self.session = ARSession()
        self.configuration = ARWorldTrackingConfiguration()
        super.init()
        
        session.delegate = self
        setupConfiguration()
    }
    
    private func setupConfiguration() {
        // 场景重建
        configuration.sceneReconstruction = .meshWithClassification
        
        // 环境纹理
        configuration.environmentTexturing = .automatic
        
        // 平面检测
        configuration.planeDetection = [.horizontal, .vertical]
        
        // 世界追踪
        configuration.worldAlignment = .gravity
        
        // 自动对焦
        configuration.isAutoFocusEnabled = true
    }
    
    // MARK: - Public Methods
    
    /// 开始扫描
    func startScan() {
        guard scanState.canStart else { return }
        
        scanState = .preparing
        meshAnchors.removeAll()
        startTime = Date()
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        scanState = .scanning
    }
    
    /// 暂停扫描
    func pauseScan() {
        guard scanState == .scanning else { return }
        
        session.pause()
        scanState = .idle
    }
    
    /// 继续扫描
    func resumeScan() {
        guard scanState == .idle else { return }
        
        session.run(configuration)
        scanState = .scanning
    }
    
    /// 停止扫描
    func stopScan() {
        guard scanState == .scanning || scanState == .idle else { return }
        
        scanState = .processing
        session.pause()
        
        // 通知完成
        onScanCompleted?(meshAnchors)
        
        scanState = .completed
    }
    
    /// 重置扫描
    func resetScan() {
        session.pause()
        meshAnchors.removeAll()
        meshExtent = .zero
        scanState = .idle
    }
    
    /// 获取扫描时长
    func getScanDuration() -> TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// 获取网格统计
    func getMeshStatistics() -> MeshStatistics? {
        guard !meshAnchors.isEmpty else { return nil }
        
        var totalVertices = 0
        var totalFaces = 0
        var boundingBox = BoundingBox(
            minX: .infinity, maxX: -.infinity,
            minY: .infinity, maxY: -.infinity,
            minZ: .infinity, maxZ: -.infinity
        )
        
        for anchor in meshAnchors {
            let geometry = anchor.geometry
            totalVertices += geometry.vertices.count
            totalFaces += geometry.faces.count
            
            // 更新包围盒
            let vertices = geometry.vertices.buffer.contents()
                .assumingMemoryBound(to: SIMD3<Float>.self)
            
            for i in 0..<geometry.vertices.count {
                let vertex = vertices[i]
                let transformed = anchor.transform * SIMD4<Float>(vertex, 1)
                
                boundingBox.minX = min(boundingBox.minX, transformed.x)
                boundingBox.maxX = max(boundingBox.maxX, transformed.x)
                boundingBox.minY = min(boundingBox.minY, transformed.y)
                boundingBox.maxY = max(boundingBox.maxY, transformed.y)
                boundingBox.minZ = min(boundingBox.minZ, transformed.z)
                boundingBox.maxZ = max(boundingBox.maxZ, transformed.z)
            }
        }
        
        return MeshStatistics(
            vertexCount: totalVertices,
            faceCount: totalFaces,
            boundingBox: boundingBox,
            scanDuration: getScanDuration(),
            textureResolution: 2048
        )
    }
}

// MARK: - ARSessionDelegate

extension ARScanner: ARSessionDelegate {
    
    nonisolated func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        Task { @MainActor in
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    updateMeshAnchor(meshAnchor)
                }
            }
        }
    }
    
    nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    addMeshAnchor(meshAnchor)
                }
            }
        }
    }
    
    nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        Task { @MainActor in
            trackingState = camera.trackingState
        }
    }
    
    private func addMeshAnchor(_ anchor: ARMeshAnchor) {
        meshAnchors.append(anchor)
        updateMeshExtent(anchor)
        onMeshUpdated?(anchor)
    }
    
    private func updateMeshAnchor(_ anchor: ARMeshAnchor) {
        if let index = meshAnchors.firstIndex(where: { $0.identifier == anchor.identifier }) {
            meshAnchors[index] = anchor
        } else {
            meshAnchors.append(anchor)
        }
        
        updateMeshExtent(anchor)
        onMeshUpdated?(anchor)
    }
    
    private func updateMeshExtent(_ anchor: ARMeshAnchor) {
        let extent = anchor.geometry.boundingBox.extent
        meshExtent = max(meshExtent, extent)
    }
}