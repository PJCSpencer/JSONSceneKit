//
//  sdmDictionary-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 22/01/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import Foundation


extension Dictionary where Key == String
{
    func set<T>(_ value: inout T,
                for key: String,
                stopExecution: Bool = false) /* TODO:Throws ..? */
    {
        guard let newValue = self[key] as? T else
        {
            let message = "WARNING:Type mismatch for key: \(key)"
            if stopExecution { fatalError(message) }
            return
        }
        value = newValue
    }
}

extension Dictionary where Key == String /* TODO:Support protocol(s) ... */
{
    func JSONObjects(_ key: String) -> [JSONObject]
    {
        guard let jsonObjects = self[key] as? [JSONObject] else
        { return [] }
        return jsonObjects
    }
    
    func JSONObject(_ key: String) -> JSONObject?
    {
        guard let jsonObject = self[key] as? JSONObject else
        { return nil }
        return jsonObject
    }
    
    func data(for key: String) -> Data?
    {
        guard let jsonObject = self.JSONObject(key),
            let data = jsonObject.data() else
        { return nil }
        return data
    }
    
    func data() -> Data?
    {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else
        { return nil }
        return data
    }
}

