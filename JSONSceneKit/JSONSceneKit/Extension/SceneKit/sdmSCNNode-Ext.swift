//
//  sdmSCNNode-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 11/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - Constant(s)
extension SCNNode
{
    enum Keys: String
    {
        case name
        case light, camera, geometry
        case childNodes
        case transform, position, eulerAngles, scale, pivot
        case categoryBitMask
        case isHidden
        case castsShadow
        case physicsBody
    }
}

// MARK: - Protocol Support
extension SCNNode: JSONConfigurable
{
    public func configure(jsonObject: JSONObject)
    {
        jsonObject.set(&self.name, for: SCNNode.Keys.name.rawValue)
        jsonObject.set(&self.categoryBitMask, for: SCNNode.Keys.categoryBitMask.rawValue)
        jsonObject.set(&self.isHidden, for: SCNNode.Keys.isHidden.rawValue)
        jsonObject.set(&self.castsShadow, for: SCNNode.Keys.castsShadow.rawValue)
        
        if let data = jsonObject.JSONObject(SCNNode.Keys.transform.rawValue),
            let transform = SCNMatrix4.compile(jsonObject: data)
        { self.transform = transform }
        
        if let data = jsonObject.JSONObject(SCNNode.Keys.pivot.rawValue),
            let v3 = SCNVector3.compile(jsonObject: data)
        { self.pivot = SCNMatrix4.translation(v3) }
        
        if let data = jsonObject.JSONObject(SCNNode.Keys.physicsBody.rawValue),
            let geometry = self.geometry
        {
            self.physicsBody = SCNPhysicsBody.compile(jsonObject: data)
            self.physicsBody?.physicsShape = SCNPhysicsShape(geometry: geometry,
                                                             options: [:]) // TODO:Support options ...
        }
        
        if let data = jsonObject.JSONObject(SCNNode.Keys.light.rawValue)
        { self.light = SCNLight.compile(jsonObject: data) }
        
        if let data = jsonObject.JSONObject(SCNNode.Keys.camera.rawValue)
        { self.camera = SCNCamera.compile(jsonObject: data) }
    }
}

// MARK: - Utility Extension(s)
extension SCNNode
{
    func child(_ name: String) -> SCNNode?
    {
        guard let node = self.childNode(withName: name, recursively: true) else
        { return nil }
        return node
    }
}

