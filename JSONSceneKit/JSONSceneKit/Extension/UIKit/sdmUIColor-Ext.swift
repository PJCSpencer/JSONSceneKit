//
//  sdmUIColor-Ext.swift
//  CarPark
//
//  Created by Peter Spencer on 14/04/2018.
//  Copyright © 2018 Peter Spencer. All rights reserved.
//

import UIKit


// MARK: - Extension(s)
extension UIColor
{
    enum Keys: String
    {
        case type, data
        case preset, whiteAlpha, rgba, hsb
    }
}

// MARK: - Protocol Support
extension UIColor: JSONContentsSource
{
    static func contents(for source: inout Any?, jsonObject: JSONObject)
    {
        guard let args = jsonObject[UIColor.Keys.rgba.rawValue] as? [CGFloat] ,
            args.count >= 4 else
        { return }
         
        source = UIColor(red: args[0],
                         green: args[1],
                         blue: args[2],
                         alpha: args[3])
    }
}

