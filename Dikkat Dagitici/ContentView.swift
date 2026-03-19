//
//  ContentView.swift
//  Dikkat Dagitici
//

import SwiftUI

enum AppMode: String, CaseIterable {
    case breath  = "Nefes"
    case bubble  = "Balonlar"
    case scratch = "Kazı Kazan"

    var icon: String {
        switch self {
        case .breath:  "wind"
        case .bubble:  "circle.fill"
        case .scratch: "sparkles"
        }
    }
}

struct ContentView: View {

    @State private var selected: AppMode = .breath

    private let tabBarColor  = Color(red: 0.96, green: 0.94, blue: 0.99)
    private let activeColor  = Color(red: 0.52, green: 0.42, blue: 0.78)
    private let inactiveColor = Color(red: 0.72, green: 0.67, blue: 0.80)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Active screen
            Group {
                switch selected {
                case .breath:  BreathView()
                case .bubble:  BubbleView()
                case .scratch: ScratchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .top)

            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(AppMode.allCases, id: \.rawValue) { mode in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                            selected = mode
                        }
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 22, weight: .medium))
                                .scaleEffect(selected == mode ? 1.15 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)

                            Text(mode.rawValue)
                                .font(.system(.caption2, design: .rounded).weight(.semibold))
                        }
                        .foregroundStyle(selected == mode ? activeColor : inactiveColor)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                        .padding(.bottom, 10)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: -4)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    ContentView()
}
