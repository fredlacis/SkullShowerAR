//
//  ViewController.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 23/09/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/Skull.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showPhysicsShapes]
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    var planes = [ARPlaneAnchor: SCNNode]()
    
    func addPlane(for node: SCNNode, at anchor: ARPlaneAnchor) {
        let planeNode = SCNNode()
        
        let w = CGFloat(anchor.extent.x)
        let h = 0.01
        let l = CGFloat(anchor.extent.z)
        
        let geometry = SCNBox(width: w, height: CGFloat(h), length: l, chamferRadius: 0.0)
        
        geometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        geometry.firstMaterial?.isDoubleSided = true
        
        planeNode.geometry = geometry
        
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        
        self.planes[anchor] = planeNode
        
        node.addChildNode(planeNode)
    }
    
    func updatePlane(for anchor: ARPlaneAnchor) {
        let planeNode = self.planes[anchor]
        
        let w = CGFloat(anchor.extent.x)
        let h = 0.01
        let l = CGFloat(anchor.extent.z)
        
        let geometry = SCNBox(width: w, height: CGFloat(h), length: l, chamferRadius: 0.0)
        
        geometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        geometry.firstMaterial?.isDoubleSided = true
        
        planeNode!.geometry = geometry
        
        planeNode!.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {return}
        print("Adding plane")
        addPlane(for: node, at: anchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {return}
        print("Updating plane")
        updatePlane(for: anchor)
    }
    
    // Inserting 3D Geometry for ARHitTestResult
    func insertBox(for result: ARRaycastResult) {
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        //Material
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIImage(named: "cracking_painted_asphalt_albedo")
        material.roughness.contents = UIImage(named: "cracking_painted_asphalt_Metallic")
        material.metalness.contents = UIImage(named: "cracking_painted_asphalt_Roughness")
        
        boxGeometry.materials = [material]
        
        let cube = SCNNode(geometry: boxGeometry)

        // Method 1: Add Anchor to the scene
        sceneView.session.add(anchor: result.anchor!)

        // OR

        // Method 2: Add SCNNode at position
        let position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
            )
        cube.position = position
        
        sceneView.scene.rootNode.addChildNode(cube)
    }
        
    func insertSkull(for result: ARRaycastResult) {
        
        let skullScene = SCNScene(named: "art.scnassets/Skull.scn")
        if let skullNode = skullScene?.rootNode.childNodes.first {
            
            let position = SCNVector3(
                result.worldTransform.columns.3.x,
                result.worldTransform.columns.3.y,
                result.worldTransform.columns.3.z
                )
            
            skullNode.position = position
            
            sceneView.scene.rootNode.addChildNode(skullNode)
        }
        
    }
    
    // Intercept a touch on screen and hit-test against a plane surface
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: sceneView)
        
//        let result = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        if let query = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) {
            let result = sceneView.session.raycast(query)
        
            guard let raycast: ARRaycastResult = result.first else {return}
            
//            insertBox(for: raycast)
            insertSkull(for: raycast)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }
        sceneView.scene.lightingEnvironment.intensity = lightEstimate.ambientIntensity/1000
    }
}
