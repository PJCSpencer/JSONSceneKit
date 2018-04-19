//
//  sdmLight-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 15/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - Protocol Support
extension SCNLight: JSONConfigurable
{
    public func configure(jsonObject: JSONObject)
    {
        // TODO:
    }
}

extension SCNLight: JSONCompilable
{
    public typealias ReturnType = SCNLight
    
    public static func compile(jsonObject: JSONObject) -> ReturnType?
    {
        return nil // TODO:
    }
}

