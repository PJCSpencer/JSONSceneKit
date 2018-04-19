//
//  sdmUIImage-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 14/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import UIKit


// MARK: - Extension(s)
extension UIImage
{
    static let numberOfImagesInCubmap: Int = 6
    
    enum Keys: String
    {
        case type, image
        case named, cubemap
        case data
    }
}

// MARK: - Protocol Support
extension UIImage: JSONContentsSource
{
    static func named(_ source: inout Any?, jsonObject: JSONObject)
    {
        guard let name = jsonObject[UIImage.Keys.named.rawValue] as? String,
            let image = UIImage(named: name) else
        {
            print("*** FAILED *** \(self)::\(#function), \(jsonObject)")
            return
        }
        source = image
    }
    
    /* NB:Could also be strings specifying location of images */
    static func cubemap(_ source: inout Any?, jsonObject: JSONObject)
    { 
        guard let args = jsonObject[UIImage.Keys.cubemap.rawValue] as? [String],
            args.count >= UIImage.numberOfImagesInCubmap else
        { return }
        
        var buffer: [UIImage] = []
        for name in args
        {
            guard let image = UIImage(named: name) else
            {
                print("*** FAILED *** \(self)::\(#function), \(name)")
                return
            }
            buffer.append(image)
        }
        source = buffer
    }
    
    static let contentsSourceCallbacks: [String:JSONContentsSourceCallback] =
    [
        UIImage.Keys.named.rawValue     : UIImage.named,
        UIImage.Keys.cubemap.rawValue   : UIImage.cubemap
    ]
    
    static func contents(for source: inout Any?, jsonObject: JSONObject)
    { 
        guard let key = jsonObject.keys.first,
            let callback = UIImage.contentsSourceCallbacks[key] else
        { return }
        
        callback(&source, jsonObject)
    }
}

