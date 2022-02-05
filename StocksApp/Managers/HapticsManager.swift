//
//  HapticsManager.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 25.01.2022.
//

import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    // MARK: - Public
    
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
