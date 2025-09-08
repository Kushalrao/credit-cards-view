//
//  AnimatedNumberView.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

struct AnimatedNumberView: View {
    let number: Int
    let fontSize: CGFloat
    @State private var displayNumber: Int = 0
    
    var body: some View {
        Text("Rs.\(displayNumber)")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(.black)
            .onAppear {
                animateToNumber()
            }
            .onChange(of: number) { _ in
                animateToNumber()
            }
    }
    
    private func animateToNumber() {
        let duration = 0.8
        let steps = 20
        let stepDuration = duration / Double(steps)
        let increment = max(1, number / steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                let targetValue = min(step * increment, number)
                withAnimation(.easeOut(duration: stepDuration)) {
                    displayNumber = targetValue
                }
            }
        }
    }
}

#Preview {
    AnimatedNumberView(number: 123456, fontSize: 43)
        .background(Color.black)
}
