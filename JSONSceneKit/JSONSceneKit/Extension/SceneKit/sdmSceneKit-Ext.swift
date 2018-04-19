//
//  sdmSceneKitExtensions.swift
//  CarPark
//
//  Created by Peter Spencer on 13/01/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import Foundation


protocol ResolvingOptions
{
    associatedtype ReturnType
    
    associatedtype ArgType
    
    static var options: [String:ReturnType] { get }
    
    static func resolve(_ args: ArgType) -> ReturnType
}

