//
//  TabContentView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

struct TabContentView: View {
    let tab: Tab
    @Binding var isShowingTabSwitcher: Bool
    
    var body: some View {
        ZStack {
            // Full colored background matching the tab
            tab.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Simple tab switcher button to go back
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isShowingTabSwitcher = true
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                            .frame(width: 24, height: 18)
                        
                        // Small stacked rectangles to represent tabs
                        VStack(spacing: 1) {
                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 16, height: 2)
                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 14, height: 2)
                        }
                        .offset(y: -1)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
