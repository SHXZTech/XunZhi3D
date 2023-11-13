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
//    func addCoaching() {
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.delegate = self
//        coachingOverlay.session = self.session
//        coachingOverlay.activatesAutomatically=true
//        #if DEBUG
//        coachingOverlay.setActive(true, animated: true)
//        #endif
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        coachingOverlay.goal = .tracking
//        self.addSubview(coachingOverlay)
//    }
        func addCoaching() {
            let coachingOverlay = ARCoachingOverlayView()
            coachingOverlay.delegate = self
            coachingOverlay.session = self.session
            coachingOverlay.activatesAutomatically = true
            #if DEBUG
            coachingOverlay.setActive(true, animated: true)
            #endif
            coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            coachingOverlay.goal = .tracking

            // Adjust the frame or add constraints here
            // Example: Leave space at the top of the view
            let topPadding: CGFloat = 100 // Adjust this value as needed
            coachingOverlay.frame = CGRect(x: 0, y: topPadding, width: self.frame.width, height: self.frame.height - topPadding)

            // Or use Auto Layout constraints
            coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(coachingOverlay)
            NSLayoutConstraint.activate([
                coachingOverlay.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding),
                coachingOverlay.leftAnchor.constraint(equalTo: self.leftAnchor),
                coachingOverlay.rightAnchor.constraint(equalTo: self.rightAnchor),
                coachingOverlay.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }



