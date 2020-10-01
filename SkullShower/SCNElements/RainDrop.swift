//
//  RainDrop.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 29/09/20.
//

import Foundation
import SceneKit

class RainDrop: SCNNode {
    
    override init() {
        super.init()
        
        let rainDropScene = SCNScene(named: "art.scnassets/RainDrop.scn")
        var rainDropGeometry: SCNGeometry?
        rainDropScene?.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "RainDrop"{
                rainDropGeometry = node.geometry
            }
        }
        rainDropGeometry?.materials.first?.diffuse.contents = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        rainDropGeometry?.materials.first?.roughness.contents = 0.0
        rainDropGeometry?.materials.first?.metalness.contents = 1.0
        
        let yScale = Float.random(in: 0.3...0.6)
        
        let physicsShape = SCNPhysicsShape(geometry: rainDropGeometry!, options: [SCNPhysicsShape.Option.scale : SCNVector3(0.3,yScale,0.3)])
        let rainDropPhysics = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        rainDropPhysics.mass = 0.00005
        rainDropPhysics.restitution = 0.0
        rainDropPhysics.isAffectedByGravity = true
        rainDropPhysics.categoryBitMask = BitMaskCategory.rainDrop
        rainDropPhysics.collisionBitMask = 0
        rainDropPhysics.contactTestBitMask = BitMaskCategory.character + BitMaskCategory.plane
    
        self.geometry = rainDropGeometry
        self.movabilityHint = .movable
        self.scale = SCNVector3(0.3,yScale,0.3)
        self.physicsBody = rainDropPhysics
        
    }
    
    func hide() {
        self.opacity = 0.0
    }
    
    func show() {
        self.opacity = 1.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
