//
//  ScratchView.swift
//  Dikkat Dagitici
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - SwiftUI Shell

struct ScratchView: View {

    @State private var revealPercent: CGFloat = 0
    @State private var isRevealed = false
    @State private var resetID = UUID()
    @State private var messageIndex = Int.random(in: 0..<6)

    private let messages = [
        "Sen harikasın! ✨",
        "Bu an geçecek.\nNefes al. 💙",
        "Güçlüsün,\ndevam et! 💪",
        "Kendine iyi bak. 🌸",
        "Her şey\nyoluna girecek. 🌈",
        "Bugün de\nyapabilirsin! 🦋",
    ]

    private let cardColor   = Color(red: 0.88, green: 0.82, blue: 0.97)
    private let accentColor = Color(red: 0.55, green: 0.44, blue: 0.78)
    private let bgColor     = Color(red: 0.96, green: 0.94, blue: 0.99)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Kazı Kazan")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(accentColor)

                // Card
                RoundedRectangle(cornerRadius: 28)
                    .fill(cardColor)
                    .frame(width: 300, height: 210)
                    .overlay {
                        Text(messages[messageIndex])
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(accentColor)
                            .multilineTextAlignment(.center)
                            .padding()
                            .opacity(
                                isRevealed
                                    ? 1.0
                                    : min(1.0, revealPercent / 0.45)
                            )
                    }
                    .overlay {
                        if !isRevealed {
                            scratchLayer
                                .id(resetID)
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                    }
                    .shadow(color: cardColor.opacity(0.5), radius: 16, x: 0, y: 8)

                // Progress bar
                if !isRevealed {
                    ProgressView(value: revealPercent)
                        .tint(accentColor.opacity(0.6))
                        .frame(width: 200)
                        .scaleEffect(y: 1.5)
                }

                // New message button
                if isRevealed {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            messageIndex = (messageIndex + 1 + Int.random(in: 1..<5)) % messages.count
                            revealPercent = 0
                            isRevealed = false
                            resetID = UUID()
                        }
                    } label: {
                        Label("Yeni Mesaj", systemImage: "arrow.clockwise")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(accentColor)
                            .clipShape(Capsule())
                            .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    // Scratch overlay — UIKit on iOS/visionOS, tap-to-reveal on macOS
    @ViewBuilder
    private var scratchLayer: some View {
        #if canImport(UIKit)
        ScratchableCanvas(
            onReveal: { pct in revealPercent = pct },
            onComplete: {
                withAnimation(.easeInOut(duration: 0.4)) { isRevealed = true }
                HapticManager.shared.scratchComplete()
            }
        )
        #else
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.68, green: 0.62, blue: 0.80))
            Text("Ortaya çıkarmak için tıkla")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.white)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.4)) { isRevealed = true }
        }
        #endif
    }
}

// MARK: - UIKit Implementation (iOS / visionOS only)

#if canImport(UIKit)

struct ScratchableCanvas: UIViewRepresentable {

    var onReveal: (CGFloat) -> Void
    var onComplete: () -> Void

    func makeUIView(context: Context) -> ScratchUIView {
        let view = ScratchUIView()
        view.onReveal   = onReveal
        view.onComplete = onComplete
        return view
    }

    func updateUIView(_ uiView: ScratchUIView, context: Context) {
        uiView.onReveal   = onReveal
        uiView.onComplete = onComplete
    }
}

final class ScratchUIView: UIView {

    var onReveal:   ((CGFloat) -> Void)?
    var onComplete: (() -> Void)?

    private var imageView    = UIImageView()
    private var currentImage: UIImage?

    private var scratchedCells = Set<String>()
    private var totalCells     = 0
    private let gridSize: CGFloat      = 22
    private let scratchRadius: CGFloat = 26

    private var didComplete    = false
    private var lastHapticDate = Date.distantPast

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        imageView.backgroundColor = .clear
        imageView.contentMode    = .scaleToFill
        addSubview(imageView)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        if currentImage == nil, bounds.width > 0, bounds.height > 0 {
            buildScratchSurface()
        }
    }

    private func buildScratchSurface() {
        totalCells = Int(ceil(bounds.width / gridSize)) * Int(ceil(bounds.height / gridSize))

        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        currentImage = renderer.image { _ in
            UIColor(red: 0.68, green: 0.62, blue: 0.80, alpha: 1).setFill()
            UIBezierPath(rect: bounds).fill()

            UIColor(red: 0.63, green: 0.57, blue: 0.75, alpha: 0.5).setFill()
            var x: CGFloat = 4
            while x < bounds.width {
                var y: CGFloat = 4
                while y < bounds.height {
                    if Bool.random() {
                        UIBezierPath(ovalIn: CGRect(x: x, y: y, width: 2, height: 2)).fill()
                    }
                    y += 6
                }
                x += 6
            }
        }
        imageView.image = currentImage
    }

    // MARK: Scratch Logic

    private func scratch(at point: CGPoint) {
        guard let base = currentImage, !didComplete else { return }

        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        currentImage = renderer.image { ctx in
            base.draw(at: .zero)
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.fillEllipse(in: CGRect(
                x: point.x - scratchRadius,
                y: point.y - scratchRadius,
                width: scratchRadius * 2,
                height: scratchRadius * 2
            ))
        }
        imageView.image = currentImage

        let col = Int(point.x / gridSize)
        let row = Int(point.y / gridSize)
        let key = "\(col),\(row)"
        guard !scratchedCells.contains(key) else { return }
        scratchedCells.insert(key)

        let pct = CGFloat(scratchedCells.count) / CGFloat(max(totalCells, 1))
        DispatchQueue.main.async { [weak self] in
            self?.onReveal?(pct)
            if pct >= 0.6, self?.didComplete == false {
                self?.didComplete = true
                self?.onComplete?()
            }
        }
    }

    // MARK: Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        scratch(at: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let points = event?.coalescedTouches(for: touch) ?? [touch]
        for t in points { scratch(at: t.location(in: self)) }

        let now = Date()
        if now.timeIntervalSince(lastHapticDate) > 0.08 {
            lastHapticDate = now
            Task { @MainActor in HapticManager.shared.scratchReveal() }
        }
    }
}

#endif // canImport(UIKit)

#Preview {
    ScratchView()
}
