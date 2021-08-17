//
//  ViewController.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 23/09/20.
//

import UIKit
import SceneKit
import ARKit

// MARK: - SetUp
class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [ARPlaneAnchor: Plane]()
    
    var character: Character?
    var emitter: ShapeEmitter?
    var panningCharacter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpScene()
        setUpOverlayCoachingView()
        setUpGestureRecognizers()
        
    }
    
    func setUpScene() {
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Configurations
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        self.sceneView.rendersMotionBlur = true
        
        #if DEBUG
        sceneView.showsStatistics = true // Show statistics such as fps and timing information
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showPhysicsShapes]
        #endif
        
    }
    
    func setUpOverlayCoachingView() {
        let coachingView = ARCoachingOverlayView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        coachingView.session = sceneView.session
        coachingView.activatesAutomatically = true
        coachingView.goal = .horizontalPlane
        
        sceneView.addSubview(coachingView)
    }
    
    func setUpGestureRecognizers(){
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
    
//    var floatArray: [Float] = [0, 30, 60, 90]
//    var index = 0
//    var initialTouchRotation = SCNVector4()
    
}

// MARK: - Gesture Handlers
extension ViewController {
    @objc func handleTap(tapGesture: UITapGestureRecognizer){
        let point = tapGesture.location(in: sceneView)
        
        if let query = sceneView.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) {
            let result = sceneView.session.raycast(query)
        
            guard let raycast: ARRaycastResult = result.first else {return}
            
            insertSkull(for: raycast)
        }
    }
    
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
            case .began:
                let location = panGesture.location(in: self.sceneView)
                let results = sceneView.hitTest(location)
                if let result = results.first {
                    self.character?.enumerateHierarchy { (node, _) in
                        if result.node == node {
                            panningCharacter = true
//                            initialTouchRotation = self.character!.rotation
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
                    
//                    self.character!.rotation.x = initialTouchRotation.x + rotationVector.x
//                    self.character!.rotation.y = initialTouchRotation.y + rotationVector.y
//                    self.character!.rotation.z = initialTouchRotation.z + rotationVector.z
//                    self.character!.rotation.w = initialTouchRotation.w + rotationVector.w
//                    print(self.character!.rotation)
                    self.character!.rotation = rotationVector
                    self.character!.anglesEuler = self.character!.eulerAngles
                    self.character!.anglesRotation = self.character!.rotation
                    
                }
            case .ended:
                panningCharacter = false
                
                if self.character != nil {
                
                    let currentPivot = self.character!.pivot
                    let currentPosition = self.character!.position
                    let changePivot = SCNMatrix4Invert(SCNMatrix4MakeRotation(self.character!.rotation.w, self.character!.rotation.x, self.character!.rotation.y, self.character!.rotation.z))

                    self.character!.pivot = SCNMatrix4Mult(changePivot, currentPivot)

                    self.character!.transform = SCNMatrix4Identity
                    self.character!.position = currentPosition
                }
                
            default:
                break
        }
    }
    
    func insertSkull(for result: ARRaycastResult) {
        
        if self.character == nil {
            self.character = Character("Skull")
            sceneView.scene.rootNode.addChildNode(self.character!)
        }
        
        if self.emitter == nil {
            self.emitter = ShapeEmitter(emissionView: self.sceneView)
            sceneView.scene.rootNode.addChildNode(self.emitter!)
        }
        
        self.emitter!.position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y + 1.2,
            result.worldTransform.columns.3.z
            )
        
        self.emitter!.emit()
        
        self.character!.position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y + 0.2,
            result.worldTransform.columns.3.z
            )
        
        if let cameraPosition = sceneView.pointOfView {
            self.character!.look(at: cameraPosition.position)
        }
        
        self.character!.anglesEuler = self.character!.eulerAngles
        self.character!.anglesRotation = self.character!.rotation
    }
}

// MARK: - SCNPhysicsContactDelegate
extension ViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        guard let rainDrop = (contact.nodeA as? RainDrop) ?? (contact.nodeB as? RainDrop) else { return }    
        rainDrop.hide()
        
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
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
