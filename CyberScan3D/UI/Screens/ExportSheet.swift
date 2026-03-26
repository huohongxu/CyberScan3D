//
//  ExportSheet.swift
//  CyberScan3D
//
//  导出界面
//

import SwiftUI

struct ExportSheet: View {
    @ObservedObject var viewModel: ScanViewModel
    @State private var selectedFormat: ExportFormat = .usdz
    @State private var isExporting: Bool = false
    @State private var exportedURL: URL?
    @State private var showShareSheet: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.cyberBlack.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // 预览
                    previewSection
                    
                    // 格式选择
                    formatSelectionSection
                    
                    // 导出按钮
                    exportButton
                }
                .padding()
            }
            .navigationTitle("导出模型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.cyberGray)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(spacing: 16) {
            // 3D 预览占位
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cyberDarker)
                    .frame(height: 200)
                
                VStack(spacing: 12) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 48))
                        .foregroundColor(.cyberCyan)
                        .glow(color: .cyberCyan, radius: 10)
                    
                    if let stats = viewModel.meshStatistics {
                        VStack(spacing: 4) {
                            Text("\(stats.formattedVertices) 顶点")
                                .font(.cyberCaption)
                            Text("\(stats.formattedFaces) 面")
                                .font(.cyberCaption)
                        }
                        .foregroundColor(.cyberGray)
                    }
                }
            }
            .neonBorder(color: .cyberCyan)
            
            // 项目名称
            if let project = viewModel.currentProject {
                Text(project.name)
                    .font(.cyberHeadline)
                    .foregroundColor(.cyberWhite)
            }
        }
    }
    
    // MARK: - Format Selection
    
    private var formatSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("导出格式")
                .font(.cyberHeadline)
                .foregroundColor(.cyberCyan)
            
            VStack(spacing: 12) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    FormatOptionRow(
                        format: format,
                        isSelected: selectedFormat == format
                    ) {
                        selectedFormat = format
                    }
                }
            }
        }
    }
    
    // MARK: - Export Button
    
    private var exportButton: some View {
        Button {
            exportModel()
        } label: {
            HStack(spacing: 12) {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(CyberProgressStyle(color: .cyberBlack))
                        .scaleEffect(0.5)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                }
                
                Text(isExporting ? "导出中..." : "导出 \(selectedFormat.displayName)")
                    .font(.cyberHeadline)
            }
            .foregroundColor(.cyberBlack)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isExporting ? Color.cyberGray : Color.cyberCyan)
            )
            .glow(color: .cyberCyan, radius: isExporting ? 0 : 15)
        }
        .disabled(isExporting)
    }
    
    // MARK: - Actions
    
    private func exportModel() {
        isExporting = true
        
        Task {
            do {
                let url = try await viewModel.exportModel(format: selectedFormat)
                exportedURL = url
                isExporting = false
                showShareSheet = true
            } catch {
                isExporting = false
                print("导出失败: \(error)")
            }
        }
    }
}

// MARK: - Format Option Row

struct FormatOptionRow: View {
    let format: ExportFormat
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cyberDark)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: format.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .cyberCyan : .cyberGray)
                }
                
                // 信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.displayName)
                        .font(.cyberHeadline)
                        .foregroundColor(.cyberWhite)
                    
                    Text(format.description)
                        .font(.cyberCaption)
                        .foregroundColor(.cyberGray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 选中指示
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.cyberCyan)
                        .glow(color: .cyberCyan, radius: 5)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.cyberDarker : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.cyberCyan : Color.cyberDark, lineWidth: 1)
            )
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportSheet(viewModel: ScanViewModel())
}