//
//  JSCNScene.swift
//  SceneKitSample
//
//  Created by Peter Spencer on 18/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


public class JSCNScene: SCNScene
{
    // MARK: - Constant(s)
    
    enum Keys: String
    {
        case node, material, geometry
        case background
        
        static let all = [node.rawValue, material.rawValue, geometry.rawValue, background.rawValue]
    }
    
    
    // MARK: - Property(s)
    
    var materialLib: SCNMaterialLibrary!
    
    var geometryLib: SCNGeometryLibrary!
    
    
    // MARK: - Adding Node(s)
    
    func addChildNode(jsonObject: JSONObject, to parentNode: SCNNode?)
    {
        guard let jsonObject = JSONSerialization.compile(jsonObject: jsonObject) else
        { return }
        
        let childNode: SCNNode = SCNNode()
        
        if let key = jsonObject[SCNNode.Keys.geometry.rawValue] as? String,
            let geometry = self.geometryLib.cache[key]
        {
            childNode.geometry = geometry
            
            if let keys = jsonObject[SCNGeometry.Keys.materials.rawValue] as? [String],
                let geometry = geometry.copy() as? SCNGeometry
            {
                geometry.materials = self.materialLib.entries(keys)
                childNode.geometry = geometry
            }
        }
        
        // PhysicsBody requires geometry.
        childNode.configure(jsonObject: jsonObject)
        
        for data in jsonObject.JSONObjects(SCNNode.Keys.childNodes.rawValue)
        { self.addChildNode(jsonObject: data, to: childNode) }
        
        parentNode?.addChildNode(childNode)
    }
}

