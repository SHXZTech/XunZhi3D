//
//  SCNMaterialExtension.swift
//  scenemesh
//
//  Created by Tao Hu on 2023/4/4.
//


import SceneKit


extension SCNMaterial {
    static var tranparent : SCNMaterial{
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        material.metalness.contents = 1
        material.roughness.contents = 0.1
        material.transparency = 1 // Set transparency to 50%
        material.fillMode = .lines // Set fill mode to show lines
        material.accessibilityPath?.lineWidth = 100
        return material
    }
}

