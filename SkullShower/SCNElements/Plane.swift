//
//  Plane.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 23/09/20.
//

import Foundation
import ARKit

class Plane: SCNNode {
  
  // MARK: - Properties
  
  var anchor: ARPlaneAnchor
  var height: CGFloat = 0.01
  
  // MARK: - Initialization
  
  init(_ anchor: ARPlaneAnchor) {
    self.anchor = anchor
    super.init()
    
    self.movabilityHint = .fixed
    
    // init geometry
    self.geometry = SCNBox(width: CGFloat(anchor.extent.x), height: height, length: CGFloat(anchor.extent.z), chamferRadius: 0.0)
    self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
    
    // init position
    self.position = SCNVector3(
      anchor.center.x,
      anchor.center.y,
      anchor.center.z
    )
    
    // physics
    self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: geometry!, options: nil))
    self.physicsBody?.categoryBitMask = BitMaskCategory.plane
    self.physicsBody?.collisionBitMask = 0
    self.physicsBody?.contactTestBitMask = BitMaskCategory.rainDrop
    
    // disable shadow for planes
    self.castsShadow = false
    
    self.hide()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(_ anchor: ARPlaneAnchor) {
    self.anchor = anchor
    
    // update geometry
    if let geometry = self.geometry as? SCNBox {
      geometry.width  = CGFloat(anchor.extent.x)
      geometry.length = CGFloat(anchor.extent.z)
      geometry.height = height
    }
    
    // update position
    self.position = SCNVector3(
      anchor.center.x,
      anchor.center.y,
      anchor.center.z
    )
    
    // physics
    self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: geometry!, options: nil))
  }
  
  func hide() {
    let transparentMaterial = SCNMaterial()
    transparentMaterial.lightingModel = .constant
    transparentMaterial.diffuse.contents = UIColor.white
    transparentMaterial.colorBufferWriteMask = SCNColorMask.init(rawValue: 0)
    transparentMaterial.transparencyMode = .aOne
    transparentMaterial.transparency = 0
    self.geometry?.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
  }
  
  func unhide() {
    self.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
  }
  
  
}
