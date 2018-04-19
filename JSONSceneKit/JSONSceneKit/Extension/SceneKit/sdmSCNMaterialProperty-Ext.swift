//
//  sdmSCNMaterialProperty-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 12/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - Extension(s)
extension SCNMaterialProperty
{
    enum Keys: String
    {
        case contents
        case type, data, color, image
        case contentsTransform
        case intensity
        case wrapS, wrapT
        case mappingChannel
        
        static let wrapping = [wrapS.rawValue, wrapT.rawValue]
    }
}

// MARK: - Protocol Support
extension SCNMaterialProperty: JSONConfigurable
{
    static let configurableCallbacks: [String:SCNMaterialPropertyCallback] =
    [
        SCNMaterialProperty.Keys.color.rawValue : UIColor.contents,
        SCNMaterialProperty.Keys.image.rawValue : UIImage.contents
    ]
    
    typealias SCNMaterialPropertyCallback = (inout Any?, JSONObject) -> Void
    
    public func configure(jsonObject: JSONObject)
    {
        jsonObject.set(&self.intensity, for: SCNMaterialProperty.Keys.intensity.rawValue)
        jsonObject.set(&self.mappingChannel, for: SCNMaterialProperty.Keys.mappingChannel.rawValue)
        
        for (key, value) in jsonObject
        {
            if key == SCNMaterialProperty.Keys.contents.rawValue,
                let contents = value as? JSONObject,
                let key = contents[SCNMaterialProperty.Keys.type.rawValue] as? String,
                let data = contents.JSONObject(SCNMaterialProperty.Keys.data.rawValue),
                let callback = SCNMaterialProperty.configurableCallbacks[key]
            {
                callback(&self.contents, data)
                continue
            }
            
            if key == SCNMaterialProperty.Keys.contentsTransform.rawValue,
                let data = value as? JSONObject,
                let transform = SCNMatrix4.compile(jsonObject: data)
            {
                self.contentsTransform = transform
                continue
            }
            
            if SCNMaterialProperty.Keys.wrapping.contains(key),
                let keyPath = SCNWrapMode.KeyPaths[key],
                let args = value as? String
            { self[keyPath: keyPath] = SCNWrapMode.resolve(args) }
        }
    }
}

// MARK: - SCNWrapMode Extension(s)
extension SCNWrapMode
{
    enum Keys: String
    {
        case clampToBorder, mirror, `repeat`
    }
    
    static let KeyPaths =
    [
        SCNMaterialProperty.Keys.wrapS.rawValue : \SCNMaterialProperty.wrapS,
        SCNMaterialProperty.Keys.wrapT.rawValue : \SCNMaterialProperty.wrapT
    ]
}

// MARK: - SCNWrapMode Protocol Support
extension SCNWrapMode: ResolvingOptions
{
    typealias ReturnType = SCNWrapMode
    
    typealias ArgType = String
    
    static var options = [SCNWrapMode.Keys.clampToBorder.rawValue   : SCNWrapMode.clampToBorder,
                          SCNWrapMode.Keys.mirror.rawValue          : SCNWrapMode.mirror,
                          SCNWrapMode.Keys.repeat.rawValue          : SCNWrapMode.repeat]
    
    static func resolve(_ args: ArgType) -> ReturnType
    {
        guard let mode = SCNWrapMode.options[args] else
        { return SCNWrapMode.clamp }
        
        return mode
    }
}

