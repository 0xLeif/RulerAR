//
//  ViewController.swift
//  RulerAR
//
//  Created by Zach Eriksen on 2/13/18.
//  Copyright © 2018 oneleif. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
	var dotNodes: [SCNNode] = []
	var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
	
	//MARK: Private Helpers
	private func add(dotAt result: ARHitTestResult) {
		let sphere = SCNSphere(radius: 0.005)
		
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.red
		sphere.materials = [material]
		
		let dot = SCNNode(geometry: sphere)
		
		dot.position = SCNVector3(x: result.worldTransform.columns.3.x,
								  y: result.worldTransform.columns.3.y,
								  z: result.worldTransform.columns.3.z)
		
		dotNodes.append(dot)
		sceneView.scene.rootNode.addChildNode(dot)
		
		if dotNodes.count > 1 {
			calculate()
		}
	}
	
	private func calculate() {
		let start = dotNodes[0]
		let end = dotNodes[1]
		
		let a = end.position.x - start.position.x
		let b = end.position.y - start.position.y
		let c = end.position.z - start.position.z
		let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
		
		updateText(distance: distance, atPosition: end.position)
	}
	
	private func updateText(distance: Float, atPosition position: SCNVector3) {
		
		textNode.removeFromParentNode()
		
		let textGeometry = SCNText(string: "\(abs(distance))", extrusionDepth: 1.0)
		
		textGeometry.firstMaterial?.diffuse.contents = UIColor.green
		
		textNode = SCNNode(geometry: textGeometry)
		
		textNode.position = SCNVector3(x: position.x,
									   y: position.y + 0.01,
									   z: position.z)
		
		textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
		
		sceneView.scene.rootNode.addChildNode(textNode)
	}
	
	//MARK: Touch Events
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if dotNodes.count >= 2 {
			dotNodes.forEach{ $0.removeFromParentNode() }
			dotNodes = []
		}
		if let touch = touches.first {
			let touchLocation = touch.location(in: sceneView)
			let results = sceneView.hitTest(touchLocation, types: .featurePoint)
			if let hitResult = results.first {
				add(dotAt: hitResult)
			}
		}
	}
}
