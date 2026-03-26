//
//  MeshExporter.swift
//  CyberScan3D
//
//  3D 网格导出器
//

import Foundation
import ARKit
import SceneKit

/// 网格导出器
struct MeshExporter {
    
    /// 导出网格数据
    static func export(
        meshAnchors: [ARMeshAnchor],
        format: ExportFormat,
        projectName: String
    ) async throws -> URL {
        switch format {
        case .usdz:
            return try await exportUSDZ(meshAnchors: meshAnchors, projectName: projectName)
        case .obj:
            return try await exportOBJ(meshAnchors: meshAnchors, projectName: projectName)
        case .ply:
            return try await exportPLY(meshAnchors: meshAnchors, projectName: projectName)
        }
    }
    
    // MARK: - USDZ Export
    
    private static func exportUSDZ(
        meshAnchors: [ARMeshAnchor],
        projectName: String
    ) async throws -> URL {
        // 创建 SceneKit 场景
        let scene = SCNScene()
        
        // 合并所有网格
        for anchor in meshAnchors {
            let node = createSCNNode(from: anchor)
            scene.rootNode.addChildNode(node)
        }
        
        // 导出 USDZ
        let outputURL = FileManager.default
            .documentsDirectory
            .appendingPathComponent("Exports")
            .appendingPathComponent("\(projectName).usdz")
        
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent,
            withIntermediateDirectories: true
        )
        
        // 使用 SceneKit 导出
        scene.write(to: outputURL, options: [
            .exportAsUsdz: true
        ])
        
        return outputURL
    }
    
    // MARK: - OBJ Export
    
    private static func exportOBJ(
        meshAnchors: [ARMeshAnchor],
        projectName: String
    ) async throws -> URL {
        var objContent = "# CyberScan3D Export\n"
        objContent += "# Project: \(projectName)\n"
        objContent += "# Date: \(Date().ISO8601Format())\n\n"
        
        var vertexOffset: Int = 0
        var allVertices: [String] = []
        var allFaces: [String] = []
        
        for anchor in meshAnchors {
            let geometry = anchor.geometry
            
            // 顶点
            let vertices = geometry.vertices
            let verticesBuffer = vertices.buffer.contents()
                .assumingMemoryBound(to: SIMD3<Float>.self)
            
            for i in 0..<vertices.count {
                let vertex = verticesBuffer[i]
                let transformed = anchor.transform * SIMD4<Float>(vertex, 1)
                allVertices.append("v \(transformed.x) \(transformed.y) \(transformed.z)")
            }
            
            // 面
            let faces = geometry.faces
            let facesBuffer = faces.buffer.contents()
                .assumingMemoryBound(to: UInt32.self)
            
            for i in stride(from: 0, to: faces.count * faces.indexCountPerFace, by: faces.indexCountPerFace) {
                let i0 = Int(facesBuffer[i]) + vertexOffset + 1
                let i1 = Int(facesBuffer[i + 1]) + vertexOffset + 1
                let i2 = Int(facesBuffer[i + 2]) + vertexOffset + 1
                allFaces.append("f \(i0) \(i1) \(i2)")
            }
            
            vertexOffset += vertices.count
        }
        
        objContent += allVertices.joined(separator: "\n")
        objContent += "\n\n"
        objContent += allFaces.joined(separator: "\n")
        
        // 保存文件
        let outputURL = FileManager.default
            .documentsDirectory
            .appendingPathComponent("Exports")
            .appendingPathComponent("\(projectName).obj")
        
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent,
            withIntermediateDirectories: true
        )
        
        try objContent.write(to: outputURL, atomically: true, encoding: .utf8)
        
        return outputURL
    }
    
    // MARK: - PLY Export
    
    private static func exportPLY(
        meshAnchors: [ARMeshAnchor],
        projectName: String
    ) async throws -> URL {
        var vertices: [SIMD3<Float>] = []
        var faces: [(Int, Int, Int)] = []
        
        var vertexOffset: Int = 0
        
        for anchor in meshAnchors {
            let geometry = anchor.geometry
            
            // 收集顶点
            let verticesBuffer = geometry.vertices.buffer.contents()
                .assumingMemoryBound(to: SIMD3<Float>.self)
            
            for i in 0..<geometry.vertices.count {
                let vertex = verticesBuffer[i]
                let transformed = anchor.transform * SIMD4<Float>(vertex, 1)
                vertices.append(SIMD3(transformed.x, transformed.y, transformed.z))
            }
            
            // 收集面
            let facesBuffer = geometry.faces.buffer.contents()
                .assumingMemoryBound(to: UInt32.self)
            
            for i in stride(from: 0, to: geometry.faces.count * geometry.faces.indexCountPerFace, by: geometry.faces.indexCountPerFace) {
                let i0 = Int(facesBuffer[i]) + vertexOffset
                let i1 = Int(facesBuffer[i + 1]) + vertexOffset
                let i2 = Int(facesBuffer[i + 2]) + vertexOffset
                faces.append((i0, i1, i2))
            }
            
            vertexOffset += geometry.vertices.count
        }
        
        // 生成 PLY 内容
        var plyContent = "ply\n"
        plyContent += "format ascii 1.0\n"
        plyContent += "element vertex \(vertices.count)\n"
        plyContent += "property float x\n"
        plyContent += "property float y\n"
        plyContent += "property float z\n"
        plyContent += "element face \(faces.count)\n"
        plyContent += "property list uchar int vertex_indices\n"
        plyContent += "end_header\n"
        
        for v in vertices {
            plyContent += "\(v.x) \(v.y) \(v.z)\n"
        }
        
        for f in faces {
            plyContent += "3 \(f.0) \(f.1) \(f.2)\n"
        }
        
        // 保存文件
        let outputURL = FileManager.default
            .documentsDirectory
            .appendingPathComponent("Exports")
            .appendingPathComponent("\(projectName).ply")
        
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent,
            withIntermediateDirectories: true
        )
        
        try plyContent.write(to: outputURL, atomically: true, encoding: .utf8)
        
        return outputURL
    }
    
    // MARK: - Helper
    
    private static func createSCNNode(from anchor: ARMeshAnchor) -> SCNNode {
        let geometry = anchor.geometry
        let vertices = geometry.vertices
        let faces = geometry.faces
        
        // 创建 SCNGeometry
        let sources = SCNGeometrySource(
            data: Data(bytes: vertices.buffer.contents(), count: vertices.buffer.length),
            semantic: .vertex,
            vectorCount: vertices.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SIMD3<Float>>.size
        )
        
        let elements = SCNGeometryElement(
            data: Data(bytes: faces.buffer.contents(), count: faces.buffer.length),
            primitiveType: .triangles,
            primitiveCount: faces.count,
            bytesPerIndex: MemoryLayout<UInt32>.size
        )
        
        let scnGeometry = SCNGeometry(sources: [sources], elements: [elements])
        scnGeometry.firstMaterial?.diffuse.contents = UIColor.cyan
        
        let node = SCNNode(geometry: scnGeometry)
        node.simdTransform = anchor.transform
        
        return node
    }
}

// MARK: - FileManager Extension

extension FileManager {
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}