//
//  TabCardView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

struct TabCardView: View {
    let tab: Tab
    let onClose: () -> Void
    let onTap: () -> Void
    let isPinchedView: Bool // Add parameter to know if we're in pinched view
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // In pinched view, use images without background color
                if isPinchedView {
                    if let imageName = tab.backgroundImage {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                            .clipped()
                    } else {
                        tab.backgroundColor
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                    }
                } else {
                    // Try to load background image, fallback to color
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
                }
            }
            .cornerRadius(8)
            .allowsHitTesting(true)
            .disabled(false)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
