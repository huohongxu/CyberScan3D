//
//  ScanProject.swift
//  CyberScan3D
//
//  扫描项目数据模型
//

import Foundation
import RealityKit
import ARKit

// MARK: - Scan Project

/// 扫描项目模型
struct ScanProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdAt: Date
    var modifiedAt: Date
    var thumbnailData: Data?
    var modelURL: URL?
    var meshStatistics: MeshStatistics?
    var exportFormats: [ExportFormat]
    
    init(name: String = "新扫描") {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.thumbnailData = nil
        self.modelURL = nil
        self.meshStatistics = nil
        self.exportFormats = []
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: createdAt)
    }
}

// MARK: - Mesh Statistics

/// 网格统计信息
struct MeshStatistics: Codable {
    var vertexCount: Int
    var faceCount: Int
    var boundingBox: BoundingBox
    var scanDuration: TimeInterval
    var textureResolution: Int?
    
    var formattedVertices: String {
        formatNumber(vertexCount)
    }
    
    var formattedFaces: String {
        formatNumber(faceCount)
    }
    
    var formattedDuration: String {
        let minutes = Int(scanDuration) / 60
        let seconds = Int(scanDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatNumber(_ n: Int) -> String {
        if n >= 1_000_000 {
            return String(format: "%.1fM", Double(n) / 1_000_000)
        } else if n >= 1_000 {
            return String(format: "%.1fK", Double(n) / 1_000)
        }
        return "\(n)"
    }
}

// MARK: - Bounding Box

struct BoundingBox: Codable {
    var minX: Float
    var maxX: Float
    var minY: Float
    var maxY: Float
    var minZ: Float
    var maxZ: Float
    
    var width: Float { maxX - minX }
    var height: Float { maxY - minY }
    var depth: Float { maxZ - minZ }
    
    var formattedSize: String {
        String(format: "%.2f × %.2f × %.2f m", width, height, depth)
    }
}

// MARK: - Export Format

enum ExportFormat: String, Codable, CaseIterable {
    case usdz = "USDZ"
    case obj = "OBJ"
    case ply = "PLY"
    
    var fileExtension: String {
        switch self {
        case .usdz: return "usdz"
        case .obj: return "obj"
        case .ply: return "ply"
        }
    }
    
    var displayName: String {
        rawValue
    }
    
    var description: String {
        switch self {
        case .usdz: return "Apple AR 格式，支持 Quick Look"
        case .obj: return "通用 3D 格式，兼容 Blender/Maya"
        case .ply: return "点云格式，保留原始数据"
        }
    }
    
    var icon: String {
        switch self {
        case .usdz: return "arkit"
        case .obj: return "cube"
        case .ply: return "point.3.connected"
        }
    }
}

// MARK: - Scan Session

/// 扫描会话状态
enum ScanState {
    case idle           // 空闲
    case preparing      // 准备中
    case scanning       // 扫描中
    case processing     // 处理中
    case completed      // 完成
    case error(String)  // 错误
    
    var title: String {
        switch self {
        case .idle: return "准备扫描"
        case .preparing: return "正在准备..."
        case .scanning: return "正在扫描"
        case .processing: return "正在处理..."
        case .completed: return "扫描完成"
        case .error: return "扫描失败"
        }
    }
    
    var canStart: Bool {
        self == .idle || self == .completed || self == .error("")
    }
}

// MARK: - Scan Settings

/// 扫描设置
struct ScanSettings {
    var meshResolution: MeshResolution = .medium
    var enableTexture: Bool = true
    var enableClassification: Bool = true
    var autoSave: Bool = true
    var showWireframe: Bool = false
    
    enum MeshResolution: String, CaseIterable {
        case low = "低"
        case medium = "中"
        case high = "高"
        
        var arKitValue: ARMeshAnchor.MeshClassification {
            switch self {
            case .low: return .none
            case .medium: return .none
            case .high: return .none
            }
        }
        
        var smoothingFactor: Float {
            switch self {
            case .low: return 0.5
            case .medium: return 0.3
            case .high: return 0.1
            }
        }
    }
}