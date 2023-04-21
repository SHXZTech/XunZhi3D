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
        coachingOverlay.activatesAutomatically=true
        //coachingOverlay.setActive(true, animated: true)
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .tracking
        self.addSubview(coachingOverlay)
    }
}

