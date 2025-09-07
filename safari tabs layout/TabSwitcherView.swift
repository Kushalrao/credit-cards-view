//
//  TabSwitcherView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CardPositionData: Equatable {
    let index: Int
    let position: CGFloat
}

struct CardPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CardPositionData = CardPositionData(index: 0, position: 0)
    
    static func reduce(value: inout CardPositionData, nextValue: () -> CardPositionData) {
        value = nextValue()
    }
}

struct TabSwitcherView: View {
    @Binding var tabs: [Tab]
    @Binding var isShowingTabSwitcher: Bool
    let onSelectTab: (Tab) -> Void
    @State private var scrollOffset: CGFloat = 0
    @State private var cardPositions: [CGFloat] = []
    @State private var tappedCardId: UUID? = nil
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Tabs scroll view with stacking effect
                ScrollView {
                    LazyVStack(spacing: -100) { // Maximum negative spacing for dramatic stacking
                        ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                            TabCardView(
                                tab: tab,
                                onClose: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        tabs.removeAll { $0.id == tab.id }
                                    }
                                },
                                onTap: {
                                    toggleCardRotation(for: tab)
                                }
                            )
                            .shadow(
                                color: index > 0 ? .black.opacity(0.24) : .clear,
                                radius: index > 0 ? 104 : 0,
                                x: index > 0 ? 0 : 0,
                                y: index > 0 ? -28 : 0
                            )
                            .scaleEffect(getScaleEffect(for: index))
                            .offset(y: getOffsetY(for: index))
                            .padding(.top, getCardTopPadding(for: tab))
                            .padding(.bottom, getCardBottomPadding(for: tab))
                            .rotation3DEffect(
                                .degrees(getCardRotationAngle(for: tab)),
                                axis: (x: 1, y: 0, z: 0),
                                perspective: 0.5
                            )
                            .zIndex(Double(index))
                            .padding(.horizontal, getHorizontalPadding(for: index))
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: CardPositionPreferenceKey.self, value: CardPositionData(index: index, position: geometry.frame(in: .named("scroll")).minY))
                                }
                            )
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(CardPositionPreferenceKey.self) { cardData in
                    updateCardPosition(cardData)
                }
                
                Spacer()
                
                // Bottom toolbar
                HStack {
                    // Private button
                    Button("Private") {
                        // Handle private browsing toggle
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    // New tab button
                    Button(action: {
                        let urls = [
                            "https://google.com",
                            "https://github.com", 
                            "https://stackoverflow.com",
                            "https://developer.apple.com",
                            "https://swift.org",
                            "https://xcode.com"
                        ]
                        let randomURL = urls.randomElement() ?? "https://apple.com"
                        let newTab = Tab(
                            title: "New Tab",
                            url: randomURL,
                            favicon: "🌐"
                        )
                        withAnimation(.easeInOut(duration: 0.3)) {
                            tabs.append(newTab)
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Done button
                    Button("Done") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isShowingTabSwitcher = false
                        }
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34) // Account for home indicator
                .background(Color.black)
            }
        }
    }
    
    // Helper functions for stacking effect
    private func getScaleEffect(for index: Int) -> CGFloat {
        // All cards same size
        return 1.0
    }
    
    private func getOffsetY(for index: Int) -> CGFloat {
        return CGFloat(index) * 8 // Reduced vertical offset for better spacing
    }
    
    private func getCardTopPadding(for tab: Tab) -> CGFloat {
        if tappedCardId == tab.id {
            return 100 // Add 100px top padding when tapped
        }
        return 0 // No padding when not tapped
    }
    
    private func getCardBottomPadding(for tab: Tab) -> CGFloat {
        if tappedCardId == tab.id {
            return 125 // Add 125px bottom padding when tapped
        }
        return 0 // No padding when not tapped
    }
    
    private func getHorizontalPadding(for index: Int) -> CGFloat {
        return 0 // No horizontal offset
    }
    
    private func updateCardPosition(_ cardData: CardPositionData) {
        // Ensure we have enough space in the array
        while cardPositions.count <= cardData.index {
            cardPositions.append(0)
        }
        cardPositions[cardData.index] = cardData.position
    }
    
    private func getDynamicRotationAngle(for index: Int) -> Double {
        // Fixed rotation for all cards
        return -40.0
    }
    
    // Card rotation toggle functions
    private func toggleCardRotation(for tab: Tab) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.4)) {
            if tappedCardId == tab.id {
                // If this card is already tapped, untap it (return to -40°)
                tappedCardId = nil
            } else {
                // If another card is tapped, untap it first, then tap this one
                tappedCardId = tab.id
            }
        }
    }
    
    private func getCardRotationAngle(for tab: Tab) -> Double {
        if tappedCardId == tab.id {
            return 0.0 // Tapped card rotates to 0°
        }
        return -40.0 // All other cards stay at -40°
    }
}
