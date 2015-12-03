//
//  DictionaryUtils.swift
//  ContactsPicker
//
//  Created by Piotr on 03/12/15.
//  Copyright © 2015 kunai. All rights reserved.
//

import Foundation
internal class DictionaryUtils {
    static func dictionaryWithSwappedKeysAndValues<T>(dict:Dictionary<T,T>) -> Dictionary<T,T>{
        var reversedDictionary = [T:T]()
        for (key, value) in dict {
            reversedDictionary[value] = key
        }
        return reversedDictionary
    }
}