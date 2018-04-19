//
//  sdmSCNGeometry-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 12/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


protocol GeometryPrimitive
{
    static func primitive(jsonObject: JSONObject) -> SCNGeometry?
}

// MARK: - Extension(s)
extension SCNGeometry
{
    enum Keys: String
    {
        case name
        case type, data
        case preset, primitive, args
        case file, custom
        case materials
    }
}

// MARK: - Protocol Support
extension SCNGeometry: JSONCompilable
{
    static func file(jsonObject: JSONObject) -> ReturnType?
    { return nil }
    
    static func preset(jsonObject: JSONObject) -> ReturnType?
    {
        guard let primitive = jsonObject[SCNGeometry.Keys.primitive.rawValue] as? String,
            let callback = SCNGeometry.compilableCallbacks[primitive],
            let args = jsonObject[SCNGeometry.Keys.args.rawValue] as? [String:CGFloat] else
        { return nil }
        
        return callback(args)
    }
    
    static let compilableCallbacks: [String:SCNGeometryCallback] =
    [
        SCNGeometry.Keys.file.rawValue      : SCNGeometry.file,
        SCNGeometry.Keys.preset.rawValue    : SCNGeometry.preset,
        "SCNPlane"                          : SCNPlane.primitive,
        "SCNBox"                            : SCNBox.primitive,
        "SCNSphere"                         : SCNSphere.primitive,
        "SCNCylinder"                       : SCNCylinder.primitive
    ]
    
    public typealias ReturnType = SCNGeometry
    
    typealias SCNGeometryCallback = (JSONObject) -> ReturnType?
    
    public static func compile(jsonObject: JSONObject) -> ReturnType?
    {
        guard let key = jsonObject[SCNGeometry.Keys.type.rawValue] as? String,
            let callback = SCNGeometry.compilableCallbacks[key],
            let data = jsonObject.JSONObject(SCNGeometry.Keys.data.rawValue) else
        { return nil }
        
        return callback(data)
    }
}

extension SCNGeometry: LibraryCompiling
{
    typealias CompileType = SCNGeometryLibrary
    
    static func library(jsonObjects: [JSONObject]) -> CompileType
    {
        let buffer: SCNGeometryLibrary = SCNGeometryLibrary()
        for jsonObject in jsonObjects
        {
            guard let jsonObject = JSONSerialization.compile(jsonObject: jsonObject),
                let geometry = SCNGeometry.compile(jsonObject: jsonObject),
                let key = jsonObject[SCNGeometry.Keys.name.rawValue] as? String else
            { continue }
            
            buffer.add(key, for: geometry)
        }
        return buffer
    }
}

// MARK: - SCNGeometryLibrary Class
class SCNGeometryLibrary: Library, LibraryPassing
{
    typealias LibraryType = SCNGeometry
    
    private(set) var cache: [String:LibraryType] = [:]
    
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
    
    func pass<T:Library>(_ library: T, jsonCollection: [JSONObject])
    {
        guard let library = library as? SCNMaterialLibrary else
        { return }
        
        for jsonObject in jsonCollection
        {
            guard let keys = jsonObject[SCNGeometry.Keys.materials.rawValue] as? [String],
                let name = jsonObject[SCNGeometry.Keys.name.rawValue] as? String,
                let geometry = self.cache[name] else
            { continue }
            
            geometry.materials = library.entries(keys)
        }
    }
}

// MARK: - GeometryPreset Protocol Extension(s)
extension SCNPlane
{
    enum Keys: String
    {
        case width, height, cornerRadius
        static let all = [width.rawValue, height.rawValue, cornerRadius.rawValue]
    }
}

extension SCNPlane: GeometryPrimitive
{
    static func primitive(jsonObject: JSONObject) -> SCNGeometry?
    {
        guard let radius = jsonObject[SCNPlane.Keys.width.rawValue] as? CGFloat,
            let height = jsonObject[SCNPlane.Keys.height.rawValue] as? CGFloat else
        { return SCNPlane(width: 1, height: 1) }
        
        let geometry = SCNPlane(width: radius, height: height)
        
        if let cornerRadius = jsonObject[SCNPlane.Keys.cornerRadius.rawValue] as? CGFloat
        { geometry.cornerRadius = cornerRadius }
        
        return geometry
    }
}

extension SCNBox
{
    enum Keys: String
    {
        case width, height, length
        case chamferRadius
        static let all = [width.rawValue, height.rawValue, length.rawValue, chamferRadius.rawValue]
    }
}

extension SCNBox: GeometryPrimitive
{
    static func primitive(jsonObject: JSONObject) -> SCNGeometry?
    {
        guard let width = jsonObject[SCNBox.Keys.width.rawValue] as? CGFloat,
            let height = jsonObject[SCNBox.Keys.height.rawValue] as? CGFloat,
            let length = jsonObject[SCNBox.Keys.length.rawValue] as? CGFloat,
            let chamferRadius = jsonObject[SCNBox.Keys.chamferRadius.rawValue] as? CGFloat else
        { return SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0) }
        
        return SCNBox(width: width,
                      height: height,
                      length: length,
                      chamferRadius: chamferRadius)
    }
}

extension SCNSphere
{
    enum Keys: String
    {
        case radius, segmentCount
    }
}

extension SCNSphere: GeometryPrimitive
{
    static func primitive(jsonObject: JSONObject) -> SCNGeometry?
    {
        guard let radius = jsonObject[SCNSphere.Keys.radius.rawValue] as? CGFloat else
        { return SCNSphere(radius: 1.0) }
        
        let geometry = SCNSphere(radius: radius)
        
        if let segmentCount = jsonObject[SCNSphere.Keys.segmentCount.rawValue] as? CGFloat
        { geometry.segmentCount = Int(segmentCount) }
        
        return geometry
    }
}

extension SCNCylinder
{
    enum Keys: String
    {
        case radius, height
        static let all = [radius.rawValue, height.rawValue]
    }
}

extension SCNCylinder: GeometryPrimitive
{
    static func primitive(jsonObject: JSONObject) -> SCNGeometry?
    {
        guard let radius = jsonObject[SCNCylinder.Keys.radius.rawValue] as? CGFloat,
            let height = jsonObject[SCNCylinder.Keys.height.rawValue] as? CGFloat else
        { return SCNCylinder(radius: 0.5, height: 1) }
        
        return SCNCylinder(radius: radius, height: height)
    }
}

