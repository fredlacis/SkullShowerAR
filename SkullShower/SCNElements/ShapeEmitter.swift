//
//  ShapeEmitter.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 25/09/20.
//

import Foundation
import SceneKit
import ARKit
import AVFoundation

class ShapeEmitter: SCNNode {
    
    private var isEmitting = false
    private var emissionView: ARSCNView
    private var radius: Float = 0.18
    private var audioPlayer: AVAudioPlayer?
    
    init(emissionView: ARSCNView) {
        self.emissionView = emissionView
        
        super.init()
        
        let emitterGeometry = SCNCylinder(radius: CGFloat(self.radius), height: 0.02)
        self.geometry = emitterGeometry
        self.opacity = 0.0
        
        guard let audioData = NSDataAsset(name: "RainSFX")?.data else {
            fatalError("Asset not found")
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            self.audioPlayer = try AVAudioPlayer(data: audioData, fileTypeHint: "m4a")
            self.audioPlayer?.play()
            self.audioPlayer?.numberOfLoops = -1
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func emit(){

        var allNodes: [RainDrop] = []
        
        for _ in 0...200 {
            allNodes.append(RainDrop())
        }

        var i = 0
        var firstLoop = true
        DispatchQueue.global().async {
            while true{
                let rainDropNode = allNodes[i]

                let newPosition = SCNVector3(
                    Float.random(in: (self.position.x - self.radius)...(self.position.x + self.radius)),
                    self.position.y,
                    Float.random(in: (self.position.z - self.radius)...(self.position.z + self.radius))
                )
                
                rainDropNode.physicsBody?.velocity = SCNVector3.init(x: 0, y: -2, z: 0)
                rainDropNode.position = newPosition
                      
                if firstLoop {
                    self.emissionView.scene.rootNode.addChildNode(rainDropNode)
                }
                
                rainDropNode.show()
                
                usleep(useconds_t(Int.random(in: 2...4)/*ms*/ * 1000))
                
                if i == allNodes.count - 1{
                    i = 0
                    firstLoop = false
                } else {
                    i += 1
                }
            }
        }
    }
    
//    func emit(){
//
//        let rainDropScene = SCNScene(named: "art.scnassets/RainDrop.scn")
//        var shapeGeometry: SCNGeometry?
//        rainDropScene?.rootNode.enumerateChildNodes { (node, _) in
//            if node.name == "RainDrop"{
//                shapeGeometry = node.geometry
//            }
//        }
//
//        shapeGeometry?.materials.first?.diffuse.contents = UIColor(red: 0.63, green: 0.77, blue: 0.78, alpha: 0.5)
//        shapeGeometry?.materials.first?.metalness.contents = UIColor.white
//
//        let physicsShape = SCNPhysicsShape(geometry: shapeGeometry!, options: [SCNPhysicsShape.Option.scale : SCNVector3(0.3,0.3,0.3)])
//        let shapePhysics = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
//        shapePhysics.mass = 0.00005
//        shapePhysics.restitution = 0.0
//        shapePhysics.isAffectedByGravity = true
//        shapePhysics.categoryBitMask = BitMaskCategory.rainDrop
//        shapePhysics.collisionBitMask = BitMaskCategory.character + BitMaskCategory.plane
//        shapePhysics.contactTestBitMask = BitMaskCategory.character + BitMaskCategory.plane
//
//        DispatchQueue.global().async {
//            while true {
//                let shapeNode = SCNNode(geometry: shapeGeometry)
//                shapeNode.movabilityHint = .movable
//
//                shapeNode.scale = SCNVector3(0.3,Float.random(in: 0.3...0.6),0.3)
//
//                shapeNode.physicsBody = shapePhysics.copy() as? SCNPhysicsBody
//
//                let newPosition = SCNVector3(
//                    Float.random(in: (self.position.x - self.radius)...(self.position.x + self.radius)),
//                    self.position.y,
//                    Float.random(in: (self.position.z - self.radius)...(self.position.z + self.radius))
//                )
//
//                shapeNode.position = newPosition
//
//                self.emissionView.scene.rootNode.addChildNode(shapeNode)
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    shapeNode.removeFromParentNode()
//                }
//
//                usleep(useconds_t(Int.random(in: 5...10)/*ms*/ * 1000))
//            }
//        }
//    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
