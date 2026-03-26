//
//  ProjectStorage.swift
//  CyberScan3D
//
//  项目存储服务
//

import Foundation

/// 项目存储服务
final class ProjectStorage {
    
    static let shared = ProjectStorage()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var projectsDirectory: URL {
        fileManager.documentsDirectory
            .appendingPathComponent("Projects", isDirectory: true)
    }
    
    private var exportsDirectory: URL {
        fileManager.documentsDirectory
            .appendingPathComponent("Exports", isDirectory: true)
    }
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        createDirectoriesIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// 保存项目
    func save(_ project: ScanProject) throws {
        let url = projectsDirectory
            .appendingPathComponent("\(project.id.uuidString).json")
        
        let data = try encoder.encode(project)
        try data.write(to: url, options: .atomic)
    }
    
    /// 加载项目
    func load(id: UUID) throws -> ScanProject {
        let url = projectsDirectory
            .appendingPathComponent("\(id.uuidString).json")
        
        let data = try Data(contentsOf: url)
        return try decoder.decode(ScanProject.self, from: data)
    }
    
    /// 加载所有项目
    func loadAll() throws -> [ScanProject] {
        let files = try fileManager.contentsOfDirectory(
            at: projectsDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> ScanProject? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(ScanProject.self, from: data)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 删除项目
    func delete(_ project: ScanProject) throws {
        // 删除项目文件
        let projectURL = projectsDirectory
            .appendingPathComponent("\(project.id.uuidString).json")
        try fileManager.removeItem(at: projectURL)
        
        // 删除导出文件
        for format in ExportFormat.allCases {
            let exportURL = exportsDirectory
                .appendingPathComponent("\(project.name).\(format.fileExtension)")
            try? fileManager.removeItem(at: exportURL)
        }
    }
    
    /// 重命名项目
    func rename(_ project: ScanProject, to newName: String) throws -> ScanProject {
        var updatedProject = project
        updatedProject.name = newName
        updatedProject.modifiedAt = Date()
        
        try save(updatedProject)
        return updatedProject
    }
    
    /// 保存缩略图
    func saveThumbnail(_ imageData: Data, for project: ScanProject) throws {
        let url = projectsDirectory
            .appendingPathComponent("\(project.id.uuidString)_thumbnail.jpg")
        try imageData.write(to: url, options: .atomic)
    }
    
    /// 加载缩略图
    func loadThumbnail(for project: ScanProject) throws -> Data {
        let url = projectsDirectory
            .appendingPathComponent("\(project.id.uuidString)_thumbnail.jpg")
        return try Data(contentsOf: url)
    }
    
    /// 获取导出目录
    func getExportsDirectory() -> URL {
        exportsDirectory
    }
    
    /// 清理所有数据
    func clearAll() throws {
        try fileManager.removeItem(at: projectsDirectory)
        try fileManager.removeItem(at: exportsDirectory)
        createDirectoriesIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(
            at: projectsDirectory,
            withIntermediateDirectories: true
        )
        
        try? fileManager.createDirectory(
            at: exportsDirectory,
            withIntermediateDirectories: true
        )
    }
}

// MARK: - Storage Error

enum StorageError: LocalizedError {
    case projectNotFound
    case invalidData
    case writeFailed
    
    var errorDescription: String? {
        switch self {
        case .projectNotFound:
            return "项目未找到"
        case .invalidData:
            return "数据格式无效"
        case .writeFailed:
            return "写入失败"
        }
    }
}