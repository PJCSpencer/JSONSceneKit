//
//  sdmGameController.swift
//  SceneKitSample
//
//  Created by Peter Spencer on 17/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit


// MARK: - Override(s)
class GameController: UIViewController
{
    // MARK: -
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let resource: String = "SampleScene"
        let loader: JSCNSceneLoader = JSCNSceneLoader()
        
        guard let path = Bundle.main.path(forResource: resource,
                                          ofType: JSONSerialization.fileExtension.json.rawValue),
            let scene = loader.scene(withContentsAt: path),
            let sceneView = self.view as? SCNView else
        { return }
        
        let cameraNode: SCNNode = SCNNode()
        cameraNode.position = SCNVector3(0, 0, 6)
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100.0
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = scene
        sceneView.pointOfView = cameraNode
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling2X
    }
    
    
    // MARK: -
    
    override var shouldAutorotate: Bool
    { return true }
    
    override var prefersStatusBarHidden: Bool
    { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    { return .landscape }
}

