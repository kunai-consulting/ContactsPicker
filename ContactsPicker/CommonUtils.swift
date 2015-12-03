//
//  CommonUtils.swift
//  ContactsPicker
//
//  Created by Piotr on 02/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation

internal class ContactAdapter {
    
    internal class func convertLabel(mappings: [String:String], label: String?) -> String? {
        guard let label = label else {
            return nil
        }
        
        if mappings.keys.contains(label) {
            return mappings[label]
        } else {
            return label
        }
    }
}
