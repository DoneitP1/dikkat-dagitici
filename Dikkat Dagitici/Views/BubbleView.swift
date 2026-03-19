//
//  BubbleView.swift
//  Dikkat Dagitici
//

import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var isPopped: Bool = false
}

struct BubbleView: View {

    @State private var bubbles: [Bubble] = []
    @State private var screenSize: CGSize = .zero

    private let bubbleColors: [Color] = [
        Color(red: 0.84, green: 0.78, blue: 0.95), // lavender
        Color(red: 0.76, green: 0.93, blue: 0.86), // soft mint
        Color(red: 0.97, green: 0.82, blue: 0.86), // blush pink
        Color(red: 0.98, green: 0.95, blue: 0.88), // cream
        Color(red: 0.78, green: 0.88, blue: 0.97), // sky blue
        Color(red: 0.95, green: 0.85, blue: 0.97), // lilac
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.97, green: 0.96, blue: 0.99)
                    .ignoresSafeArea()

                ForEach(bubbles) { bubble in
                    BubbleCircle(bubble: bubble) {
                        popBubble(id: bubble.id)
                    }
                }
            }
            .onAppear {
                screenSize = geometry.size
                spawnInitialBubbles()
            }
            .onChange(of: geometry.size) { _, newSize in
                screenSize = newSize
            }
        }
    }

    private func spawnInitialBubbles() {
        for _ in 0..<10 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                bubbles.append(newBubble())
            }
        }
    }

    private func newBubble() -> Bubble {
        let size = CGFloat.random(in: 52...108)
        let padding = size / 2 + 8
        let x = CGFloat.random(in: padding...(screenSize.width - padding))
        let y = CGFloat.random(in: padding...(screenSize.height - 100 - padding))
        return Bubble(
            position: CGPoint(x: x, y: y),
            size: size,
            color: bubbleColors.randomElement()!
        )
    }

    private func popBubble(id: UUID) {
        HapticManager.shared.bubblePop()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            if let i = bubbles.firstIndex(where: { $0.id == id }) {
                bubbles[i].isPopped = true
            }
        }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            bubbles.removeAll { $0.id == id }
            let alive = bubbles.filter { !$0.isPopped }.count
            let needed = max(0, 8 - alive)
            for _ in 0..<(needed + 2) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                    bubbles.append(newBubble())
                }
            }
        }
    }
}

struct BubbleCircle: View {
    let bubble: Bubble
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [bubble.color.opacity(0.7), bubble.color],
                    center: UnitPoint(x: 0.35, y: 0.3),
                    startRadius: 0,
                    endRadius: bubble.size * 0.6
                )
            )
            .frame(width: bubble.size, height: bubble.size)
            .overlay(
                Circle()
                    .stroke(bubble.color.opacity(0.35), lineWidth: 1.5)
            )
            .overlay(alignment: .topLeading) {
                // Specular highlight
                Ellipse()
                    .fill(.white.opacity(0.45))
                    .frame(width: bubble.size * 0.3, height: bubble.size * 0.18)
                    .offset(x: bubble.size * 0.18, y: bubble.size * 0.14)
                    .blur(radius: 2)
            }
            .shadow(color: bubble.color.opacity(0.35), radius: 10, x: 0, y: 4)
            .scaleEffect(bubble.isPopped ? 0.01 : 1.0)
            .opacity(bubble.isPopped ? 0 : 1)
            .position(bubble.position)
            .onTapGesture { onTap() }
    }
}

#Preview {
    BubbleView()
}
