//
//  ARSCNViewExtention.swift
//  scenemesh
//
//  Created by Tao Hu on 2023/4/20.
//

import Foundation
import SceneKit
import ARKit

extension ARSCNView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.activatesAutomatically = true
        #if DEBUG
        coachingOverlay.setActive(true, animated: true)
        #endif
        coachingOverlay.goal = .tracking
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(coachingOverlay)

        // Determine the top padding needed to avoid covering the exit button
        let topPadding: CGFloat = 70 // Adjust this value based on the size of your exit button

        // Set constraints
        NSLayoutConstraint.activate([
            coachingOverlay.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding),
            coachingOverlay.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            coachingOverlay.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            coachingOverlay.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}






