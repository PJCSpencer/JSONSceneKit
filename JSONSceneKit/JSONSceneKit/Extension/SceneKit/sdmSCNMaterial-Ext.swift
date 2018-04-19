//
//  sdmSCNMaterial-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 11/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - Constant(s)
enum LightingModelKeys: String
{
    case diffuse, ambient, specular
    static let all = [diffuse.rawValue, ambient.rawValue, specular.rawValue]
}

// MARK: - Extension(s)
extension SCNMaterial
{
    enum Keys: String
    {
        case name
        case locksAmbientWithDiffuse, isDoubleSided, lightingModel, transparency
    }
    
    static let KeyPaths =
    [
        LightingModelKeys.diffuse.rawValue : \SCNMaterial.diffuse
    ]
    
    convenience init?(jsonObject: JSONObject)
    {
        self.init()
        self.configure(jsonObject: jsonObject)
    }
}

// MARK: - Protocol Support
extension SCNMaterial: JSONConfigurable
{
    public func configure(jsonObject: JSONObject)
    {
        jsonObject.set(&self.name, for: Keys.name.rawValue)
        jsonObject.set(&self.locksAmbientWithDiffuse, for: Keys.locksAmbientWithDiffuse.rawValue)
        jsonObject.set(&self.isDoubleSided, for: Keys.isDoubleSided.rawValue)
        
        for key in LightingModelKeys.all
        {
            guard let data = jsonObject.JSONObject(key),
                let keyPath = SCNMaterial.KeyPaths[key],
                let property = self[keyPath: keyPath] as SCNMaterialProperty? else
            { continue }
            
            property.configure(jsonObject: data)
        }
    }
}

extension SCNMaterial: LibraryCompiling
{
    typealias CompileType = SCNMaterialLibrary
    
    static func library(jsonObjects: [JSONObject]) -> CompileType
    {
        let buffer: SCNMaterialLibrary = SCNMaterialLibrary()
        for jsonObject in jsonObjects
        {
            guard let jsonObject = JSONSerialization.compile(jsonObject: jsonObject),
                let material = SCNMaterial(jsonObject: jsonObject),
                let key = material.name else
            { continue }
            
            buffer.add(key, for: material)
        }
        return buffer
    }
}

// MARK: - SCNMaterialLibrary
class SCNMaterialLibrary: Library
{
    typealias LibraryType = SCNMaterial
    
    private(set) var cache: [String : LibraryType] = [:]
    
    func add(_ key: String, for object: LibraryType)
    { self.cache[key] = object }
    
    func entries(_ keys: [String]) -> [LibraryType]
    {
        var buffer: [LibraryType] = []
        for key in keys
        {
            buffer.append(contentsOf: self.cache.filter { $0.key == key}.values)
        }
        return buffer
    }
}

