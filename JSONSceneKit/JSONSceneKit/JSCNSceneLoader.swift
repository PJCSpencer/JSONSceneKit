//
//  JSCNSceneLoader.swift
//  SceneKitSample
//
//  Created by Peter Spencer on 18/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


public class JSCNSceneLoader
{
    func scene(withContentsAt path: String) -> SCNScene? /* TODO:Support update block/protocol ... */
    {
        guard let jsonObject = try? JSONSerialization.collect(JSCNScene.Keys.all,
                                                              contentsOf: path) else
        { return nil }
        
        let materials = jsonObject.JSONObjects(JSCNScene.Keys.material.rawValue)
        let geometries = jsonObject.JSONObjects(JSCNScene.Keys.geometry.rawValue)
        let nodes = jsonObject.JSONObjects(JSCNScene.Keys.node.rawValue)
        
        let scene: JSCNScene = JSCNScene()
        scene.materialLib = SCNMaterial.library(jsonObjects: materials)
        scene.geometryLib = SCNGeometry.library(jsonObjects: geometries)
        scene.geometryLib.pass(scene.materialLib, jsonCollection: geometries)
        
        if let data = jsonObject.JSONObject(SCNScene.Keys.background.rawValue)
        { scene.background.configure(jsonObject: data) }
        
        for jsonObject in nodes
        { scene.addChildNode(jsonObject: jsonObject, to: scene.rootNode) }
        
        return scene
    }
}

