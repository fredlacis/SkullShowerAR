//
//  Character.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 23/09/20.
//

import Foundation
import ARKit

class Character: SCNNode {
    
    init(_ scnName: String) {
        super.init()
        
        let characterScene = SCNScene(named: "art.scnassets/\(scnName).scn")
        if let characterNode = characterScene?.rootNode.childNodes.first {

            characterNode.enumerateHierarchy { (node, _) in
                node.geometry?.materials.first?.lightingModel = .physicallyBased
                node.geometry?.materials.first?.roughness.contents = UIImage(named: "broken_down_concrete2_Roughness")
                node.geometry?.materials.first?.metalness.contents = UIImage(named: "broken_down_concrete2_Metallic")
                node.geometry?.materials.first?.ambientOcclusion.contents = UIImage(named: "broken_down_concrete2_ao")
                node.geometry?.materials.first?.normal.contents = UIImage(named: "broken_down_concrete2_Normal")
            }
            
            self.addChildNode(characterNode)
        }
        
        self.castsShadow = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
