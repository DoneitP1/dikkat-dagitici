//
//  HapticManager.swift
//  Dikkat Dagitici
//

import UIKit

@MainActor
final class HapticManager {

    static let shared = HapticManager()

    private let bubbleFeedback  = UIImpactFeedbackGenerator(style: .medium)
    private let scratchFeedback = UIImpactFeedbackGenerator(style: .light)
    private let breathFeedback  = UIImpactFeedbackGenerator(style: .soft)

    private init() {
        bubbleFeedback.prepare()
        scratchFeedback.prepare()
        breathFeedback.prepare()
    }

    func bubblePop() {
        bubbleFeedback.impactOccurred(intensity: 0.9)
    }

    func scratchReveal() {
        scratchFeedback.impactOccurred(intensity: 0.4)
    }

    func scratchComplete() {
        scratchFeedback.impactOccurred(intensity: 1.0)
    }

    func breathTransition(intensity: CGFloat) {
        breathFeedback.impactOccurred(intensity: intensity)
        breathFeedback.prepare()
    }
}
