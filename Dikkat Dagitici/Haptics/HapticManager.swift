//
//  HapticManager.swift
//  Dikkat Dagitici
//

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class HapticManager {

    static let shared = HapticManager()

    #if canImport(UIKit)
    private let bubbleFeedback  = UIImpactFeedbackGenerator(style: .medium)
    private let scratchFeedback = UIImpactFeedbackGenerator(style: .light)
    private let breathFeedback  = UIImpactFeedbackGenerator(style: .soft)
    #endif

    private init() {
        #if canImport(UIKit)
        bubbleFeedback.prepare()
        scratchFeedback.prepare()
        breathFeedback.prepare()
        #endif
    }

    func bubblePop() {
        #if canImport(UIKit)
        bubbleFeedback.impactOccurred(intensity: 0.9)
        #endif
    }

    func scratchReveal() {
        #if canImport(UIKit)
        scratchFeedback.impactOccurred(intensity: 0.4)
        #endif
    }

    func scratchComplete() {
        #if canImport(UIKit)
        scratchFeedback.impactOccurred(intensity: 1.0)
        #endif
    }

    func breathTransition(intensity: CGFloat) {
        #if canImport(UIKit)
        breathFeedback.impactOccurred(intensity: intensity)
        breathFeedback.prepare()
        #endif
    }
}
