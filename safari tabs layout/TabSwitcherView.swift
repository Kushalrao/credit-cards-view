//
//  TabSwitcherView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

// Extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TabSwitcherView: View {
    @Binding var tabs: [Tab]
    @Binding var isShowingTabSwitcher: Bool
    let onSelectTab: (Tab) -> Void
    @State private var scrollOffset: CGFloat = 0
    @State private var cardPositions: [CGFloat] = []
    @State private var scrollViewContentOffset: CGFloat = 0
    @State private var tappedCardId: UUID? = nil
    @State private var isPinchedView: Bool = false
    @GestureState private var pinchScale: CGFloat = 1.0
    @State private var animatedCardIndices: Set<Int> = []
    @State private var cardsInFinalPosition: Set<Int> = []
    
    var body: some View {
                ZStack {
                    // Background
                    Color(hex: "F3F9E7")
                        .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Total bill display (only visible in pinched view)
                if isPinchedView {
                    VStack(alignment: .center, spacing: 8) {
                        Text("YOUR TOTAL BILL")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                            .tracking(0.75) // 5% letter spacing (15 * 0.05 = 0.75)
                        
                        AnimatedNumberView(
                            number: tabs.reduce(0) { $0 + $1.rupeeAmount },
                            fontSize: 43
                        )
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // Tabs scroll view with stacking effect
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: isPinchedView ? -145 : -100) { // Pinched view spacing adjusted to -145px
                        ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                            TabCardView(
                                tab: tab,
                                onClose: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        tabs.removeAll { $0.id == tab.id }
                                    }
                                },
                                onTap: {
                                    if !isPinchedView {
                                        toggleCardRotation(for: tab)
                                    }
                                },
                                isPinchedView: isPinchedView
                            )
                            .shadow(
                                color: (index > 0 && !isPinchedView) ? .black.opacity(0.24) : .clear, // Disable shadows in pinched view
                                radius: (index > 0 && !isPinchedView) ? 104 : 0,
                                x: (index > 0 && !isPinchedView) ? 0 : 0,
                                y: (index > 0 && !isPinchedView) ? -28 : 0
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
                            .opacity(isPinchedView ? 1.0 : 1.0) // Force 100% opacity in pinched view
                            .padding(.horizontal, getHorizontalPadding(for: index))
                            .animation(
                                isPinchedView ? 
                                    .easeInOut(duration: 0.3).delay(Double(index) * 0.1) : 
                                    .easeInOut(duration: 0.3),
                                value: isPinchedView
                            )
                            .animation(.easeInOut(duration: 0.3), value: cardsInFinalPosition)
                            .animation(.easeInOut(duration: 0.2), value: cardPositions)
                            .animation(.easeInOut(duration: 0.2), value: scrollViewContentOffset)
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
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    scrollViewContentOffset = geometry.frame(in: .named("scroll")).minY
                                }
                                .onChange(of: geometry.frame(in: .named("scroll")).minY) { newValue in
                                    scrollViewContentOffset = newValue
                                }
                        }
                    )
                }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(CardPositionPreferenceKey.self) { cardData in
                    updateCardPosition(cardData)
                }
                .disabled(false) // Keep scrolling enabled to test if scroll disabling is the issue
                
                Spacer()
            }
        }
        .highPriorityGesture(
            MagnificationGesture()
                .updating($pinchScale) { value, state, _ in
                    state = value
                }
                .onEnded { value in
                    print("Pinch gesture detected with value: \(value)")
                    // Pinch in (zoom out) - value < 1.0
                    if value < 0.8 && !isPinchedView {
                        print("Pinch in detected - switching to pinched view")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPinchedView = true
                            tappedCardId = nil // Disable card interactions
                        }
                        
                        // Start two-phase animation
                        startTwoPhaseAnimation()
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                    // Pinch out (zoom in) - value > 1.2
                    else if value > 1.2 && isPinchedView {
                        print("Pinch out detected - switching to normal view")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPinchedView = false
                            cardsInFinalPosition.removeAll() // Reset final positions
                        }
                    }
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded {
                    print("Double tap detected - toggling pinched view")
                    if !isPinchedView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPinchedView = true
                            tappedCardId = nil // Disable card interactions
                        }
                        startTwoPhaseAnimation()
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPinchedView = false
                            cardsInFinalPosition.removeAll() // Reset final positions
                        }
                    }
                }
        )
    }
    
    // Helper functions for stacking effect
    private func getScaleEffect(for index: Int) -> CGFloat {
        // All cards same size
        return 1.0
    }
    
    private func getOffsetY(for index: Int) -> CGFloat {
        if isPinchedView {
            if cardsInFinalPosition.contains(index) {
                return CGFloat(index) * 8 + 40 // Final position: 40px down
            } else {
                return CGFloat(index) * 8 // First phase: original position
            }
        }
        return CGFloat(index) * 8 // Normal view: original position
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
        
        // Debug logging
        print("Updated card \(cardData.index) position to: \(cardData.position)")
    }
    
    private func startTwoPhaseAnimation() {
        // Reset final position tracking
        cardsInFinalPosition.removeAll()
        
        // Phase 1: Cards rotate to 0° one by one (already handled by existing animation)
        // Phase 2: After a delay, move each card down by 40px one by one with haptic feedback
        for index in 0..<tabs.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1 + 0.4) {
                cardsInFinalPosition.insert(index)
                // Add haptic feedback for each card when it reaches final position
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        }
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
        if isPinchedView {
            return 0.0 // All cards at 0° in pinched view
        }
        if tappedCardId == tab.id {
            return 0.0 // Tapped card rotates to 0°
        }
        
        // Dynamic rotation based on card index and scroll position
        if let tabIndex = tabs.firstIndex(where: { $0.id == tab.id }) {
            let deviceHeight = UIScreen.main.bounds.height
            let cardHeight: CGFloat = 200 // Approximate card height
            let cardSpacing: CGFloat = -100 // Current spacing
            
            // Calculate the card's base position in the stack
            let baseCardPosition = CGFloat(tabIndex) * (cardHeight + cardSpacing)
            
            // Calculate the card's current position considering scroll offset
            let currentCardPosition = baseCardPosition + scrollViewContentOffset
            
            // Calculate rotation based on how far the card is from the top of the screen
            // Cards closer to top (negative or small positive values) should be less rotated
            let screenTop: CGFloat = 200 // Account for top padding and bill display
            let distanceFromTop = currentCardPosition - screenTop
            
            // Normalize the distance to a 0-1 range for rotation interpolation
            let maxDistance = deviceHeight * 0.6 // Maximum distance for full rotation
            let normalizedDistance = max(0, min(1, distanceFromTop / maxDistance))
            
            // Interpolate between -5° (top) and -40° (bottom)
            let topRotation = -5.0
            let bottomRotation = -40.0
            let dynamicRotation = topRotation + normalizedDistance * (bottomRotation - topRotation)
            
            print("Card \(tabIndex): basePos=\(baseCardPosition), scrollOffset=\(scrollViewContentOffset), currentPos=\(currentCardPosition), distanceFromTop=\(distanceFromTop), normalized=\(normalizedDistance), rotation=\(dynamicRotation)")
            
            return dynamicRotation
        }
        
        return -40.0 // Default fallback
    }
}
