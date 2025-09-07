//
//  SafariTabsView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

struct SafariTabsView: View {
    @State private var tabs: [Tab] = Tab.sampleTabs
    @State private var selectedTab: Tab? = nil
    @State private var isShowingTabSwitcher: Bool = true
    
    var body: some View {
        ZStack {
            if isShowingTabSwitcher {
                // Tab switcher view with stacked cards
                TabSwitcherView(
                    tabs: $tabs,
                    isShowingTabSwitcher: $isShowingTabSwitcher,
                    onSelectTab: { tab in
                        selectedTab = tab
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isShowingTabSwitcher = false
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 1.1).combined(with: .opacity)
                ))
            } else if let selectedTab = selectedTab {
                // Individual tab content view
                TabContentView(
                    tab: selectedTab,
                    isShowingTabSwitcher: $isShowingTabSwitcher
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 1.1).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            // Set the first tab as selected by default
            if selectedTab == nil && !tabs.isEmpty {
                selectedTab = tabs.first
            }
        }
        .onChange(of: tabs) { newTabs in
            // Handle tab removal - if selected tab was removed, select another one
            if let selectedTab = selectedTab,
               !newTabs.contains(where: { $0.id == selectedTab.id }) {
                self.selectedTab = newTabs.first
                
                // If no tabs left, stay in tab switcher mode
                if newTabs.isEmpty {
                    isShowingTabSwitcher = true
                }
            }
        }
    }
}

