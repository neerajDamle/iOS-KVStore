//
//  NDUserDefaultsKVStore.swift
//  KVStore
//
//  Created by Neeraj Damle on 6/10/16.
//  Copyright © 2016 NDamle. All rights reserved.
//

import Foundation

class NDUserDefaultsKVStore : NDKVStore
{
    //To keep track of the NDUserDefaultsKVStore owner
    weak var delegate: NDKVStoreOperationStatusProtocol?;
    //Store identifier
    var storeName : String;
    
    init(name: String)
    {
        storeName = name;
    }
    
    /**
     Convenience method to insert key-value tuples with keys and values belonging to any of the
     following data types
     - Number (int or floating point numbers)
     - String
     - Array
     - Dictionary
     - Any object that is compliant with NDKVStorable protocol
     
     - parameter: key Key to be stored in NDUserDefaultsKVStore
     - parameter: value Value to be stored in NDUserDefaultsKVStore
     
     - returns: Throws exception if insert tuple operation fails
     Success/Failure status of insert operation
     */
    func put(key: AnyObject, value: AnyObject) throws -> Int
    {
        let returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
        return returnValue;
    }
    
    /**
     Convenience method to retrieve key-value tuples with keys and values belonging to any of the
     following data types
     - Number (int or floating point numbers)
     - String
     - Array
     - Dictionary
     - Any object that is compliant with NDKVStorable protocol
     
     - parameter: key Key to be used for retrieved tuple from NDUserDefaultsKVStore
     
     - returns: Returns the tuple or nil
     */
    func get(key: AnyObject) -> KVStore_Generic?
    {
        var tuple : KVStore_Generic?;
        return tuple;
    }
    
    /**
     Convenience method to delete key-value tuple associated with the provided key from NDUserDefaultsKVStore
     
     - parameter: key Key to be used to delete associated tuple from NDUserDefaultsKVStore
     
     - returns: Success/Failure status of delete operation
     */
    func deleteTuple(key key:AnyObject) -> Int
    {
        let returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
        return returnValue;
    }
    
    /**
     Convenience method to delete all key-value tuples from the NDUserDefaultsKVStore
     
     - returns: Success/Failure status of delete operation
     */
    func deleteAllTuples() -> Int
    {
        let returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
        return returnValue;
    }
    
    /**
     Convenience method to print key and value associated with the provided key
     
     - parameter: key Key to be used to retrieve and print tuple from NDUserDefaultsKVStore
     
     */
    func printTuple(key key:AnyObject)
    {
    }
    
    /**
     Convenience method to print all key-value tuples from the NDUserDefaultsKVStore
     */
    func printAllTuples()
    {
    }
}