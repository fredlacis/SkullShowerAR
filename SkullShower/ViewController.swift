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
    
    var planes = [ARPlaneAnchor: Plane]()
    
    var character: Character?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScene()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Scene configuration and Debug options
    func configureScene() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Configurations
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
        // Debug Options
        sceneView.showsStatistics = true // Show statistics such as fps and timing information
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showPhysicsShapes]
        sceneView.autoenablesDefaultLighting = true
        
    }
        
    func insertSkull(for result: ARRaycastResult) {
        
        if self.character == nil {
            self.character = Character("Skull")
            sceneView.scene.rootNode.addChildNode(self.character!)
        }
        
        self.character!.position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y + 0.2,
            result.worldTransform.columns.3.z
            )
        
        if let cameraPosition = sceneView.pointOfView {
            self.character!.look(at: cameraPosition.position)
        }
        
    }
    
    // Intercept a touch on screen and hit-test against a plane surface
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: sceneView)
        
        if let query = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) {
            let result = sceneView.session.raycast(query)
        
            guard let raycast: ARRaycastResult = result.first else {return}
            
            insertSkull(for: raycast)
        }
    }
    
    // MARK: - Renderer functions
    
    // Update lighting intensity
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }
        sceneView.scene.lightingEnvironment.intensity = lightEstimate.ambientIntensity/1000
    }
    
    // Adding new plane when detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {return}
        let newPlane = Plane(anchor)
        self.planes[anchor] = newPlane
        node.addChildNode(newPlane)
    }
    
    // Called when a plane is updated
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {return}
        if let updatedPlane = self.planes[anchor] {
            updatedPlane.update(anchor)
        }
    }
}
