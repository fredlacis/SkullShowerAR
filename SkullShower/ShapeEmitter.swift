//
//  ShapeEmitter.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 25/09/20.
//

import Foundation
import SceneKit
import ARKit

class ShapeEmitter: SCNNode {
    
    private var isEmitting = false
    private var emissionView: ARSCNView
    private var radius: Float = 0.12
    
    init(emissionView: ARSCNView) {
        self.emissionView = emissionView
        
        super.init()
        
        let emitterGeometry = SCNCylinder(radius: CGFloat(self.radius), height: 0.02)
        self.geometry = emitterGeometry
        self.opacity = 0.0
        
    }
    
    func emit(){
        
//        let sphereGeometry = SCNSphere(radius: 0.005)
        let sphereGeometry = SCNCylinder(radius: 0.002, height: 0.0075)
        sphereGeometry.materials.first?.lightingModel = .physicallyBased
        
        sphereGeometry.materials.first?.diffuse.contents = UIColor(red: 0.63, green: 0.77, blue: 0.78, alpha: 1.0)
//        sphereGeometry.materials.first?.transparency = 0.75
        
//        sphereGeometry.materials.first?.diffuse.contents = UIImage(named: "others_0004_basecolor_2k")
//        sphereGeometry.materials.first?.roughness.contents = UIImage(named: "others_0004_roughness_2k")
//        sphereGeometry.materials.first?.ambientOcclusion.contents = UIImage(named: "others_0004_ao_2k")
//        sphereGeometry.materials.first?.normal.contents = UIImage(named: "others_0004_normal_2k")
//        sphereGeometry.materials.first?.transparent.contents = UIImage(named: "others_0004_opacity_2k")//?.invertedImage()
//        sphereGeometry.materials.first?.transparencyMode = .rgbZero
        
        let spherePhysics = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphereGeometry))
        spherePhysics.mass = 0.00005
        spherePhysics.restitution = 0.1
        spherePhysics.isAffectedByGravity = true
        
        DispatchQueue.global().async {
            while true {
                let sphereNode = SCNNode(geometry: sphereGeometry)
                sphereNode.movabilityHint = .movable
                
                sphereNode.scale = SCNVector3(1.0,Float.random(in: 1.0...3.0),1.0)
                
                sphereNode.physicsBody = spherePhysics.copy() as? SCNPhysicsBody
                
                let newPosition = SCNVector3(
                    Float.random(in: (self.position.x - self.radius)...(self.position.x + self.radius)),
                    self.position.y,
                    Float.random(in: (self.position.z - self.radius)...(self.position.z + self.radius))
                )
                
                sphereNode.position = newPosition
                                
                self.emissionView.scene.rootNode.addChildNode(sphereNode)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    sphereNode.removeFromParentNode()
                }
                usleep(useconds_t(5/*ms*/ * 1000))
            }
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
