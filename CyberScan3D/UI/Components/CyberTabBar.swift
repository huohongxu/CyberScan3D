//
//  CyberTabBar.swift
//  CyberScan3D
//
//  赛博朋克风格 Tab Bar
//

import SwiftUI

struct CyberTabBar<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == Int {
    @Binding var selectedTab: T
    let tabs: [T]
    
    private let tabTitle: (T) -> String
    private let tabIcon: (T) -> String
    
    init(
        selectedTab: Binding<T>,
        tabs: [T],
        title: @escaping (T) -> String,
        icon: @escaping (T) -> String
    ) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.tabTitle = title
        self.tabIcon = icon
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabBarItem(
                    icon: tabIcon(tab),
                    title: tabTitle(tab),
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // 背景
                Color.cyberDarker
                
                // 顶部霓虹线
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.cyberCyan, .cyberPink, .cyberCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    Spacer()
                }
            }
        )
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // 图标
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.cyberCyan.opacity(0.2))
                            .frame(width: 44, height: 44)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .cyberCyan : .cyberGray)
                        .scaleEffect(isSelected ? 1.1 : 1)
                }
                
                // 标签
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? .cyberCyan : .cyberGray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Convenience Initializer for MainTabView

extension CyberTabBar where T == MainTabView.Tab {
    init(selectedTab: Binding<T>, tabs: [T]) {
        self.init(
            selectedTab: selectedTab,
            tabs: tabs,
            title: { $0.title },
            icon: { $0.icon }
        )
    }
}

#Preview {
    CyberTabBar(
        selectedTab: .constant(.scan),
        tabs: MainTabView.Tab.allCases
    )
}