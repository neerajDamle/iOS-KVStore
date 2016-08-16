//
//  Constants.swift
//  KVStore
//
//  Created by Neeraj Damle on 5/30/16.
//  Copyright © 2016 NDamle. All rights reserved.
//
//
//  This structure defines constants for JSON parsing error messages, JSON default keys and method return
//  values (success or failure)
//

import Foundation

struct NDKVStoreConstants
{
    //Constants for JSON keys
    struct JSONKeys
    {
        static let JSON_DEFAULT_KEY = "Key";
    };
    
    //Constants for JSON error codes
    struct JSONErrorMessages
    {
        static let JSON_SERIALIZATION_ERROR = "Failed to create JSON.";
        static let JSON_DESERIALIZATION_ERROR = "Failed to convert JSON back to object.";
    }
    
    //Constants for func return values
    struct MethodReturnValues
    {
        static let STATUS_SUCCESS = 0;
        static let STATUS_FAILURE = 1;
    };
}