//
//  sdmSCNPhysicsBody-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 16/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - SCNPhysicsBody Protocol Support
extension SCNPhysicsBody: JSONConfigurable
{
    enum configurableKeys: String
    {
        case type
    }
    
    public func configure(jsonObject: JSONObject)
    {
        // TODO:Expand ...
        
        if let key = jsonObject[configurableKeys.type.rawValue] as? String
        { self.type = SCNPhysicsBodyType.resolve(key) }
    }
}

extension SCNPhysicsBody: JSONCompilable
{
    public typealias ReturnType = SCNPhysicsBody
    
    public static func compile(jsonObject: JSONObject) -> ReturnType?
    {
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        physicsBody.configure(jsonObject: jsonObject)
        return physicsBody
    }
}

// MARK: - SCNPhysicsBodyType Extension(s)
extension SCNPhysicsBodyType
{
    enum Keys: String
    {
        case `static`, dynamic, kinematic
    }
}

// MARK: - SCNPhysicsBodyType Protocol Support
extension SCNPhysicsBodyType: ResolvingOptions
{
    typealias ReturnType = SCNPhysicsBodyType
    
    typealias ArgType = String
    
    static var options = [SCNPhysicsBodyType.Keys.static.rawValue       : SCNPhysicsBodyType.static,
                          SCNPhysicsBodyType.Keys.dynamic.rawValue      : SCNPhysicsBodyType.dynamic,
                          SCNPhysicsBodyType.Keys.kinematic.rawValue    : SCNPhysicsBodyType.kinematic]
    
    static func resolve(_ args: ArgType) -> ReturnType
    {
        guard let mode = SCNPhysicsBodyType.options[args] else
        { return SCNPhysicsBodyType.static }
        
        return mode
    }
}

