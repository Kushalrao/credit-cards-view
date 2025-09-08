//
//  TabCardView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

// Extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TabCardView: View {
    let tab: Tab
    let onClose: () -> Void
    let onTap: () -> Void
    let isPinchedView: Bool // Add parameter to know if we're in pinched view
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Use same rendering logic for both views - images with background fallback
                if let imageName = tab.backgroundImage {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                        .clipped()
                        .background(tab.backgroundColor) // Fallback color behind image
                } else {
                    tab.backgroundColor
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                }
                
                // Rupee amount overlay (only show in normal view, not in pinched view)
                if !isPinchedView {
                    VStack(spacing: 0) {
                        // Top rectangle - 4px height, card width only
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(height: 4)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                        
                        // Bottom rectangle - 28px height, 96px width, rounded corners
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 96, height: 28)
                            .cornerRadius(9, corners: [.bottomLeft, .bottomRight])
                            .overlay(
                                Text("Rs.\(tab.rupeeAmount)")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.black)
                                    .shadow(color: .white, radius: 1)
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .cornerRadius(13)
            .allowsHitTesting(true)
            .disabled(false)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
