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
        
        // Add Coaching View
        overlayCoachingView()
        
        // Gestures
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGesture:)))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGesture:)))
        sceneView.addGestureRecognizer(panRecognizer)
        sceneView.addGestureRecognizer(tapRecognizer)
        
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
        sceneView.autoenablesDefaultLighting = true
        
        // Debug Options
        sceneView.showsStatistics = true // Show statistics such as fps and timing information
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showPhysicsShapes]
        
        
    }
    
    // ARCoachingOverlayView configuration
    func overlayCoachingView() {
        let coachingView = ARCoachingOverlayView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        coachingView.session = sceneView.session
        coachingView.activatesAutomatically = true
        coachingView.goal = .horizontalPlane
        
        sceneView.addSubview(coachingView)
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer){
//        guard let touch = touches.first else { return }
        let point = tapGesture.location(in: sceneView)
        
        if let query = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) {
            let result = sceneView.session.raycast(query)
        
            guard let raycast: ARRaycastResult = result.first else {return}
            
            insertSkull(for: raycast)
        }
    }

    func deg2rad(_ number: CGFloat) -> Double {
        return Double(number * .pi / 180)
    }
    
    var lastPanLocation: CGPoint?
    var panningCharacter = false
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
            case .began:
                let location = panGesture.location(in: self.sceneView)
                let results = sceneView.hitTest(location)
                if let result = results.first {
                    self.character?.enumerateHierarchy { (node, _) in
                        if result.node == node {
                            panningCharacter = true
                        }
                    }
                }
            case .changed:
                if panningCharacter {
                    
                    let translation = panGesture.translation(in: panGesture.view!)
                    let x = Float(translation.x)
                    let y = Float(-translation.y)
                    
                    let anglePan = sqrt(pow(x,2) + pow(y,2)) * .pi / 180.0
                        
                    var rotationVector = SCNVector4()
                        rotationVector.x = -y
                        rotationVector.y = x
                        rotationVector.z = 0
                        rotationVector.w = anglePan
                    
                    self.character!.rotation = rotationVector
                    
                }
            case .ended:
                panningCharacter = false
                
                let currentPivot = self.character!.pivot
                let currentPosition = self.character!.position
                let changePivot = SCNMatrix4Invert(SCNMatrix4MakeRotation(self.character!.rotation.w, self.character!.rotation.x, self.character!.rotation.y, self.character!.rotation.z))
                
                self.character!.pivot = SCNMatrix4Mult(changePivot, currentPivot)
                self.character!.transform = SCNMatrix4Identity
                self.character!.position = currentPosition
                
            default:
                break
        }
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
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
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let point = touch.location(in: sceneView)
//
//        if let query = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) {
//            let result = sceneView.session.raycast(query)
//
//            guard let raycast: ARRaycastResult = result.first else {return}
//
//            insertSkull(for: raycast)
//        }
//    }
    
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
