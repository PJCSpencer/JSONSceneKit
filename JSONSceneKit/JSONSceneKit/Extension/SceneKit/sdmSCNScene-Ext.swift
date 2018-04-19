//
//  sdmSCNScene-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 13/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import SceneKit


// MARK: - Constant(s)
extension SCNScene
{
    enum Keys: String
    {
        case background, lightingEnvironment
    }
}

// MARK: - LibraryCompiling, LibraryPassing & Library Protocol(s)
protocol LibraryCompiling
{
    associatedtype CompileType
    
    static func library(jsonObjects: [JSONObject]) -> CompileType
}

protocol LibraryPassing
{
    func pass<T:Library>(_ library: T, jsonCollection: [JSONObject])
}

protocol Library
{
    associatedtype LibraryType
    
    var cache: [String:LibraryType] { get }
    
    func add(_ key: String, for object: LibraryType)
    
    func entries(_ keys: [String]) -> [LibraryType] /* TODO:Support block ... */
}

