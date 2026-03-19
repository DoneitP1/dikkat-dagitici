//
//  BreathView.swift
//  Dikkat Dagitici
//

import SwiftUI

// MARK: - Phase Model

enum BreathPhase: CaseIterable {
    case inhale, hold, exhale

    var duration: Double {
        switch self {
        case .inhale: 4
        case .hold:   4
        case .exhale: 6
        }
    }

    var label: String {
        switch self {
        case .inhale: "Nefes Al"
        case .hold:   "Tut"
        case .exhale: "Nefes Ver"
        }
    }

    var targetScale: CGFloat {
        switch self {
        case .inhale: 1.38
        case .hold:   1.38
        case .exhale: 0.72
        }
    }

    var hapticIntensity: CGFloat {
        switch self {
        case .inhale: 0.6
        case .hold:   0.3
        case .exhale: 0.5
        }
    }

    var next: BreathPhase {
        switch self {
        case .inhale: .hold
        case .hold:   .exhale
        case .exhale: .inhale
        }
    }
}

// MARK: - Controller

@Observable
@MainActor
final class BreathController {
    var phase: BreathPhase  = .inhale
    var circleScale: CGFloat = 0.72
    private var task: Task<Void, Never>?

    func start() {
        task?.cancel()
        task = Task { @MainActor in
            while !Task.isCancelled {
                let current = self.phase
                HapticManager.shared.breathTransition(intensity: current.hapticIntensity)
                withAnimation(.easeInOut(duration: current.duration)) {
                    self.circleScale = current.targetScale
                }
                try? await Task.sleep(for: .seconds(current.duration))
                guard !Task.isCancelled else { break }
                self.phase = current.next
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}

// MARK: - View

struct BreathView: View {

    @State private var controller = BreathController()
    @State private var pulse = false

    private let circleColor = Color(red: 0.75, green: 0.68, blue: 0.96)
    private let bgColor     = Color(red: 0.96, green: 0.94, blue: 0.99)
    private let accentColor = Color(red: 0.52, green: 0.42, blue: 0.78)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack(spacing: 48) {
                Text("Nefes Egzersizi")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(accentColor)

                ZStack {
                    // Ambient pulsing halo
                    Circle()
                        .fill(circleColor.opacity(0.12))
                        .frame(width: 310, height: 310)
                        .scaleEffect(pulse ? 1.08 : 0.94)
                        .animation(
                            .easeInOut(duration: 2.4).repeatForever(autoreverses: true),
                            value: pulse
                        )

                    // Outer ring
                    Circle()
                        .stroke(circleColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 248, height: 248)
                        .scaleEffect(controller.circleScale)
                        .animation(.easeInOut(duration: controller.phase.duration), value: controller.circleScale)

                    // Main breath circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.88, green: 0.82, blue: 0.99),
                                    circleColor,
                                ],
                                center: UnitPoint(x: 0.38, y: 0.32),
                                startRadius: 8,
                                endRadius: 130
                            )
                        )
                        .frame(width: 210, height: 210)
                        .scaleEffect(controller.circleScale)
                        .animation(.easeInOut(duration: controller.phase.duration), value: controller.circleScale)
                        .shadow(color: circleColor.opacity(0.45), radius: 24, x: 0, y: 10)

                    // Label
                    Text(controller.phase.label)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                        .id(controller.phase.label)
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                        .animation(.easeInOut(duration: 0.4), value: controller.phase.label)
                }

                // Phase dots
                HStack(spacing: 10) {
                    ForEach(BreathPhase.allCases, id: \.label) { p in
                        Capsule()
                            .fill(
                                controller.phase == p
                                    ? accentColor
                                    : accentColor.opacity(0.25)
                            )
                            .frame(
                                width: controller.phase == p ? 24 : 10,
                                height: 10
                            )
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: controller.phase.label)
                    }
                }

                // Duration label
                Text(durationText)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(accentColor.opacity(0.6))
            }
        }
        .onAppear {
            pulse = true
            controller.start()
        }
        .onDisappear {
            controller.stop()
        }
    }

    private var durationText: String {
        let d = Int(controller.phase.duration)
        return "\(d) saniye"
    }
}

#Preview {
    BreathView()
}
