//
//  sdmJSONExt.swift
//  CarPark
//
//  Created by Peter Spencer on 07/02/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import Foundation


// MARK: - Protocol(s)
public protocol JSONConfigurable
{
    func configure(jsonObject: JSONObject)
}

public protocol JSONCompilable
{
    associatedtype ReturnType
    
    static func compile(jsonObject: JSONObject) -> ReturnType?
}

protocol JSONContentsSource
{
    static func contents(for source: inout Any?, jsonObject: JSONObject)
}
typealias JSONContentsSourceCallback = (inout Any?, JSONObject) -> Void

// MARK: - Constant(s)
enum JSONSerializationError: Error
{
    case file
    case data
    case json
    case key
    case failed
}

public typealias JSONObject = [String:Any]

// MARK: - Extension(s)
extension JSONSerialization
{
    static func object(with data: Data) throws -> JSONObject
    {
        if data.isEmpty
        { throw JSONSerializationError.data }
        
        do
        {
            let result = try JSONSerialization.jsonObject(with: data,
                                                          options: .allowFragments) as? JSONObject ?? [:]
            return result
        }
        catch _ { throw JSONSerializationError.failed }
    }
    
    static func object(contentsOf path: String) throws -> JSONObject
    {
        do
        {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path),
                                       options: [.uncached, .alwaysMapped]) else
            { throw JSONSerializationError.data }
            
            guard let result = try? JSONSerialization.object(with: data) else
            { throw JSONSerializationError.json }
            
            return result
        }
        catch _ { throw JSONSerializationError.failed }
    }
    
    static func collection(with data: Data) throws -> [JSONObject]
    {
        if data.isEmpty
        { throw JSONSerializationError.data }
        
        do
        {
            let result = try JSONSerialization.jsonObject(with: data,
                                                          options: .allowFragments) as? [JSONObject] ?? []
            return result
        }
        catch _ { throw JSONSerializationError.failed }
    }
    
    static func collection(contentsOf path: String) throws -> [JSONObject]
    {
        do
        {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path),
                                       options: [.uncached, .alwaysMapped]) else
            { throw JSONSerializationError.data }
            
            guard let result = try? JSONSerialization.collection(with: data) else
            { throw JSONSerializationError.json }
            
            return result
        }
        catch _ { throw JSONSerializationError.failed }
    }
    
    static func collect(_ keys: [String],
                        with data: Data) throws -> JSONObject
    {
        if data.isEmpty
        { throw JSONSerializationError.data }
        
        do
        {
            let jsonObject = try JSONSerialization.object(with: data)
            var buffer: JSONObject = [:]
            
            for key in keys
            {
                guard let result = jsonObject[key] else
                { throw JSONSerializationError.key }
                
                buffer[key] = result
            }
            return buffer
        }
        catch _ { throw JSONSerializationError.json }
    }
    
    static func collect(_ keys: [String],
                        contentsOf path: String) throws -> JSONObject
    {
        do
        {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path),
                                       options: [.uncached, .alwaysMapped]) else
            { throw JSONSerializationError.data }
            
            guard let result = try? JSONSerialization.collect(keys, with: data) else
            { throw JSONSerializationError.json }
            
            return result
        }
        catch { throw JSONSerializationError.failed }
    }
}

// MARK: - Protocol Support
extension JSONSerialization: JSONCompilable
{
    enum fileExtension: String
    {
        case json
    }
    
    enum compilableKeys: String
    {
        case named, file
    }
    
    static func named(jsonObject: JSONObject) -> ReturnType?
    {
        guard let name = jsonObject[JSONSerialization.compilableKeys.named.rawValue] as? String,
            let path = Bundle.main.path(forResource: name, ofType: JSONSerialization.fileExtension.json.rawValue),
            let data = try? JSONSerialization.object(contentsOf: path) else
        { return nil }
        return data
    }
    
    static let compilableCallbacks: [String:compilableCallback] =
    [
        JSONSerialization.compilableKeys.named.rawValue : JSONSerialization.named,
    ]
    
    public typealias ReturnType = JSONObject
    
    typealias compilableCallback = (JSONObject) -> ReturnType?
    
    public static func compile(jsonObject: JSONObject) -> ReturnType?
    {
        guard let key = jsonObject.keys.first,
            let callback = JSONSerialization.compilableCallbacks[key] else
        { return jsonObject }
        return callback(jsonObject)
    }
}

