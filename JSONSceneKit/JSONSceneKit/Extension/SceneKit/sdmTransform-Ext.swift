//
//  sdmTransform-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 11/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - Constant(s)
enum TransformKeys: String
{
    case position, eulerAngles, scale
    case pivot
    
    static let transformOrder = [scale.rawValue, eulerAngles.rawValue, position.rawValue]
}

// MARK: - SCNVector3 Protocol Support
extension SCNVector3: Decodable
{
    enum Keys: String, CodingKey
    {
        case x, y, z
    }
    
    public init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: Keys.self)
        
        let x = try values.decode(Float.self, forKey: .x)
        let y = try values.decode(Float.self, forKey: .y)
        let z = try values.decode(Float.self, forKey: .z)
        
        self.init(x, y, z)
    }
}

extension SCNVector3: JSONCompilable
{
    public typealias ReturnType = SCNVector3
    
    public static func compile(jsonObject: JSONObject) -> ReturnType?
    {
        guard let data = jsonObject.data(),
            let vector = try? JSONDecoder().decode(self, from: data) else
        { return nil }
        
        return vector
    }
}

// MARK: - SCNMatrix4 Protocol Support
extension SCNMatrix4: JSONCompilable
{
    static func translate(_ matrix: inout SCNMatrix4, jsonObject: JSONObject)
    {
        if let vec = SCNVector3.compile(jsonObject: jsonObject)
        { matrix = SCNMatrix4Translate(matrix, vec.x, vec.y, vec.z) }
    }
    
    static func scale(_ matrix: inout SCNMatrix4, jsonObject: JSONObject)
    {
        if let vec = SCNVector3.compile(jsonObject: jsonObject)
        { matrix = SCNMatrix4Scale(matrix, vec.x, vec.y, vec.z) }
    }
    
    static func eulerAngles(_ matrix: inout SCNMatrix4, jsonObject: JSONObject)
    {
        if let vec = SCNVector3.compile(jsonObject: jsonObject)
        {
            matrix = SCNMatrix4Rotate(matrix, GLKMathDegreesToRadians(vec.x), 1, 0, 0)
            matrix = SCNMatrix4Rotate(matrix, GLKMathDegreesToRadians(vec.y), 0, 1, 0)
            matrix = SCNMatrix4Rotate(matrix, GLKMathDegreesToRadians(vec.z), 0, 0, 1)
        }
    }
    
    static let compilableCallbacks: [String:SCNMatrix4Callback] =
    [
        TransformKeys.position.rawValue     : SCNMatrix4.translate,
        TransformKeys.scale.rawValue        : SCNMatrix4.scale,
        TransformKeys.eulerAngles.rawValue  : SCNMatrix4.eulerAngles
    ]
    
    public typealias ReturnType = SCNMatrix4
    
    typealias SCNMatrix4Callback = (inout SCNMatrix4, JSONObject) -> Void
    
    public static func compile(jsonObject: JSONObject) -> ReturnType?
    {
        var matrix = SCNMatrix4Identity
        for key in TransformKeys.transformOrder
        {
            guard let callback = SCNMatrix4.compilableCallbacks[key],
                let args = jsonObject.JSONObject(key) else
            { continue }
            callback(&matrix, args)
        }
        return matrix
    }
}

