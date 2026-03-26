//
//  ProjectsView.swift
//  CyberScan3D
//
//  项目列表界面
//

import SwiftUI

struct ProjectsView: View {
    @State private var projects: [ScanProject] = []
    @State private var selectedProject: ScanProject?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cyberBlack.ignoresSafeArea()
                
                if projects.isEmpty {
                    emptyStateView
                } else {
                    projectListView
                }
            }
            .navigationTitle("我的项目")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // 刷新项目列表
                        loadProjects()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.cyberCyan)
                    }
                }
            }
        }
        .onAppear {
            loadProjects()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.cyberCyan)
                .glow(color: .cyberCyan, radius: 20)
            
            VStack(spacing: 8) {
                Text("还没有项目")
                    .font(.cyberTitle3)
                    .foregroundColor(.cyberWhite)
                
                Text("开始你的第一次扫描吧")
                    .font(.cyberBody)
                    .foregroundColor(.cyberGray)
            }
        }
    }
    
    // MARK: - Project List
    
    private var projectListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(projects) { project in
                    ProjectCard(project: project)
                        .onTapGesture {
                            selectedProject = project
                        }
                        .contextMenu {
                            Button {
                                selectedProject = project
                            } label: {
                                Label("查看详情", systemImage: "eye")
                            }
                            
                            Button {
                                // 分享
                            } label: {
                                Label("分享", systemImage: "square.and.arrow.up")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                deleteProject(project)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Actions
    
    private func loadProjects() {
        // 从本地加载项目
        let documentsPath = FileManager.default.documentsDirectory
            .appendingPathComponent("Projects")
        
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: documentsPath,
            includingPropertiesForKeys: nil
        ) else { return }
        
        projects = files.compactMap { url -> ScanProject? in
            guard url.pathExtension == "json" else { return nil }
            let data = try? Data(contentsOf: url)
            return try? JSONDecoder().decode(ScanProject.self, from: data!)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }
    
    private func deleteProject(_ project: ScanProject) {
        // 删除文件
        let url = FileManager.default.documentsDirectory
            .appendingPathComponent("Projects")
            .appendingPathComponent("\(project.id.uuidString).json")
        
        try? FileManager.default.removeItem(at: url)
        
        // 更新列表
        projects.removeAll { $0.id == project.id }
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    let project: ScanProject
    
    var body: some View {
        HStack(spacing: 16) {
            // 缩略图
            ZStack {
                if let thumbnailData = project.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "cube")
                        .font(.system(size: 32))
                        .foregroundColor(.cyberCyan)
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.cyberDark)
            .cornerRadius(8)
            
            // 信息
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.cyberHeadline)
                    .foregroundColor(.cyberWhite)
                    .lineLimit(1)
                
                Text(project.formattedDate)
                    .font(.cyberCaption)
                    .foregroundColor(.cyberGray)
                
                if let stats = project.meshStatistics {
                    HStack(spacing: 12) {
                        label(icon: "point.3.connected", text: stats.formattedVertices)
                        label(icon: "square.grid.3x3", text: stats.formattedFaces)
                    }
                }
            }
            
            Spacer()
            
            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.cyberGray)
        }
        .padding(16)
        .background(Color.cyberDarker)
        .cornerRadius(12)
        .neonBorder(color: .cyberCyan.opacity(0.3))
    }
    
    private func label(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.cyberCaption2)
        }
        .foregroundColor(.cyberCyan)
    }
}

#Preview {
    ProjectsView()
}