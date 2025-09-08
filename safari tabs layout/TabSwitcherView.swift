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
    @State private var isPinchedView: Bool = false
    @GestureState private var pinchScale: CGFloat = 1.0
    @State private var animatedCardIndices: Set<Int> = []
    @State private var cardsInFinalPosition: Set<Int> = []
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Total bill display (only visible in pinched view)
                if isPinchedView {
                    VStack(alignment: .center, spacing: 8) {
                        Text("YOUR TOTAL BILL")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
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
        return -40.0 // All other cards stay at -40°
    }
}
