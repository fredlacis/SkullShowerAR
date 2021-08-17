//
//  Character.swift
//  SkullShower
//
//  Created by Frederico Lacis de Carvalho on 23/09/20.
//

import Foundation
import ARKit
import AVFoundation

class Character: SCNNode, AVAudioPlayerDelegate {
    
    private var stateTimer: Timer?
    public var anglesEuler: SCNVector3!
    public var anglesRotation: SCNVector4!
    
    private var speakTimer: Timer?
    private var audioPlayer: AVAudioPlayer!
    private var isSpeaking: Bool = false
    
    private var jawNode: SCNNode?
    
    init(_ scnName: String) {
        super.init()
        
        self.anglesEuler = self.eulerAngles
        self.anglesRotation = self.rotation
        
        setupARSCNProperties(scnName)
        
        let fadeIn = SCNAction.fadeIn(duration: 3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.runAction(fadeIn)
            self.runIntroduction()
        }
        
        
    }
    
    func setupARSCNProperties(_ scnName: String) {
        let characterScene = SCNScene(named: "art.scnassets/\(scnName).scn")
        if let characterNode = characterScene?.rootNode.childNodes.first {

            characterNode.enumerateHierarchy { (node, _) in
                node.geometry?.materials.first?.lightingModel = .physicallyBased
                node.geometry?.materials.first?.roughness.contents = UIImage(named: "BrokenConcrete_Roughness")
                node.geometry?.materials.first?.metalness.contents = UIImage(named: "BrokenConcrete_Metallic")
                node.geometry?.materials.first?.ambientOcclusion.contents = UIImage(named: "BrokenConcrete_AmbientOclusion")
                node.geometry?.materials.first?.normal.contents = UIImage(named: "BrokenConcrete_Normal")
                
                
                if let nodeGeometry = node.geometry {
                    let nodeShape = SCNPhysicsShape(geometry: nodeGeometry, options: [SCNPhysicsShape.Option.scale : SCNVector3(0.1,0.1,0.1)])
                    node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nodeShape)
                    node.physicsBody?.categoryBitMask = BitMaskCategory.character
                    node.physicsBody?.collisionBitMask = BitMaskCategory.rainDrop
                    node.physicsBody?.contactTestBitMask = BitMaskCategory.rainDrop
                }
                
                if node.name == "BottomHalf" {
                    jawNode = node
                }
                
            }
            
            characterNode.movabilityHint = .fixed
            self.opacity = 0.0
            self.addChildNode(characterNode)
        }
        
        self.castsShadow = true
    }
    
    // MARK: - State Checking
    
    private let stateUpdateInverval = 5.3
    
    func runIntroduction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            self.startSpeaking("Introduction")
        }
    }
    
    func startStateTimer() {
        stateTimer = Timer.scheduledTimer(timeInterval: stateUpdateInverval,
                                          target: self,
                                          selector: #selector(self.updateState),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    @objc func updateState() {
        
        startSpeaking("Speak\(Int.random(in: 1...17))")
        
    }
    
//    func normalizeAngle(_ angle: Float) -> Float {
//        let normal = Float(Int(angle) % 360)
//        return normal >= 0 ? normal : normal + 360
//    }
//
//    func inAngleRange(value: Float, angle: Float) -> Bool{
//        let range1 = angle-30...angle+30
//        let range2 = abs(angle-180)-30...abs(angle-180)+30
////        let result1 = (value >= angle - 30 && value <= angle + 30)
////        let result2 = (abs(value-180) >= angle - 30 && abs(value-180) <= angle + 30)
//        let result1 = range1.contains(value)
//        let result2 = range2.contains(value)
////        print("Value: \(value) | Oposite: \(abs(value-180)) | 1: \(result1) | 2: \(result2)")
//        return result1 || result2
//    }
    
    // MARK: - Speaking Functions
    
    // Speak Setup
    private let speakUpdateInterval = 0.05
    private let animationDuration = 0.05
    private let maxPowerDelta: CGFloat = 30
    
    func startSpeaking(_ fileName: String){
        speakTimer = Timer.scheduledTimer(timeInterval: speakUpdateInterval,
                                     target: self,
                                     selector: #selector(self.updateMeters),
                                     userInfo: nil,
                                     repeats: true)
        
        guard let audioData = NSDataAsset(name: fileName)?.data else {
            fatalError("Asset not found")
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            self.audioPlayer = try AVAudioPlayer(data: audioData, fileTypeHint: "m4a")
            self.audioPlayer?.isMeteringEnabled = true
            self.audioPlayer?.play()
            self.audioPlayer?.numberOfLoops = 0
            self.audioPlayer.delegate = self
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isSpeaking = false
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
        }
        if self.stateTimer != nil {
            self.stateTimer!.invalidate()
            self.stateTimer = nil
        }
        startStateTimer()
    }
    
    func stopSpeaking() {
        guard speakTimer != nil, speakTimer!.isValid, audioPlayer != nil else {
            return
        }
        audioPlayer.stop()
        speakTimer?.invalidate()
        speakTimer = nil
    }
    
    func animateSpeak(power: CGFloat) {
        if let jawNode = jawNode {
            
            let powerDelta = (maxPowerDelta + power) * 2 / 100
            var mappedDistance = -powerDelta.map(minRange: -0.1, maxRange: 0.5, minDomain: 0, maxDomain: 30)

            if mappedDistance > -8 {
                mappedDistance = 0
            } else if mappedDistance < -22 {
                mappedDistance = -30
            }
            
            let rotate = SCNAction.rotateTo(x: mappedDistance.deg2rad, y: 0, z: 0, duration: animationDuration, usesShortestUnitArc: true)
            jawNode.runAction(rotate)
        }
    }
    
    // MARK: - Aux Functions
    
    @objc private func updateMeters() {
        audioPlayer.updateMeters()
        let power = averagePowerFromAllChannels()
        animateSpeak(power: power)
    }
    
    private func averagePowerFromAllChannels() -> CGFloat {
        var power: CGFloat = 0.0
        (0..<audioPlayer.numberOfChannels).forEach { (index) in
            power = power + CGFloat(audioPlayer.averagePower(forChannel: index))
        }
        return power / CGFloat(audioPlayer.numberOfChannels)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/*
 
 For goodness' sake My head is getting full of water!
 Why the hell there is water falling from the ceiling?!
 Why are you doing this to me Stop touching me!
 There is water coming into my ears Watch out!
 Aff I can't see anything Be careful with my eyes!
 Even with my nose full of water I can smell your stink!
 
 */
