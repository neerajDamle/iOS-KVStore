//
//  NDKVStoreProtocols.swift
//  KVStore
//
//  Created by Neeraj Damle on 6/6/16.
//  Copyright © 2016 NDamle. All rights reserved.
//
//
//  NDKVStorable Protocol
//      Classes that need to store key-value tuple in NDKVStore need to be compliant with
//      this protocol
//      The protocol declares a method to create Dictionary representation of the object that
//      is to be stored in NDKVStore
//
//  NDKVStore Protocol
//      Classes storing Key-Value tuples in different storage mediums like SQLite, NSUserDefaults
//      need to be compliant with this protocol
//      The protocol declares three methods for three basic operations
//      - Insert tuple
//      - Fetch tuple.
//      - Delet tuple
//
//  NDKVStoreOperationStatusProtocol Protocol
//      Classes that need to track status for key-value tuples insertion in NDKVStore
//      need to be compliant with this protocol
//      The protocol declares two methods. One tells the delegate class about the success
//      status of insertion operation and the other method tells the failure staus of
//      the insertion operation
//

import Foundation

/**
 Enumeration to capture NDKVStore errors. Suitable message can be passed to describe the error
 */
enum NDKVStoreError : ErrorType
{
    case DictionaryConversionFailed(message: String)
}

//Extensions for Int, Double, String, Array to be compliant with NDKVStorable protocol
extension Int : NDKVStorable
{
    func dictionaryRepresentation() -> [String : AnyObject]?
    {
        let numberRepresenation = NSNumber(integer: self);
        let dictionaryRepresenation: [String : AnyObject]?  = ["Key":numberRepresenation];
        return dictionaryRepresenation;
    }
}

extension Double : NDKVStorable
{
    func dictionaryRepresentation() -> [String : AnyObject]?
    {
        let numberRepresenation = NSNumber(double: self);
        let  dictionaryRepresenation: [String : AnyObject]?  = ["Key":numberRepresenation];
        return dictionaryRepresenation;
    }
}

extension String : NDKVStorable
{
    func dictionaryRepresentation() -> [String : AnyObject]?
    {
        let  dictionaryRepresenation: [String : AnyObject]?  = ["Key":self];
        return dictionaryRepresenation;
    }
}

extension Array : NDKVStorable
{
    func dictionaryRepresentation() -> [String : AnyObject]?
    {
        var dictionaryRepresenation : [String : AnyObject]?;
        
        let castedArray = self as? AnyObject;
        if (castedArray != nil) && (self.count > 0)
        {
            dictionaryRepresenation  = ["Key":castedArray!];
        }
        return dictionaryRepresenation;
    }
}

protocol NDKVStorable
{
    //Create dictionary representation of the object
    func dictionaryRepresentation() -> [String : AnyObject]?;
}

protocol NDKVStore : class
{
    var storeName : String {get set};

    //To keep track of the NDKVStore owner
    weak var delegate: NDKVStoreOperationStatusProtocol? {get set};
    
    //Implemented by concrete classes to manage tuple insertion
    func put(key: AnyObject, value: AnyObject) throws -> Int
    
    //Implemented by concrete classes to fetch stored tuples
    func get(key: AnyObject) -> KVStore_Generic?
    
    //Implemented by concrete classes to delete stored tuple based on Key
    func deleteTuple(key key:AnyObject) -> Int
    
    //Implemented by concrete classes to delete all stored tuples
    func deleteAllTuples() -> Int;
    
    //Implemented by concrete classes to print stored tuple based on Key
    func printTuple(key key:AnyObject);
    
    //Implemented by concrete classes to print all stored tuples
    func printAllTuples();
}

protocol NDKVStoreOperationStatusProtocol : class
{
    //Tell the delegate class about success status of insertion operation
    func didStoreTuple(kvStore: NDKVStore);
    
    //Tell the delegate class about failure status of insertion operation
    func failToStoreTuple(kvStore: NDKVStore);
}

/**
 Enumeration to capture NDKVStore storage mediums. Currently SQLite and User Defaults are 
 available
 */
enum KVStoreImplementation
{
    case SQLite, UserDefaults
}

/**
 Enumeration to create NDKVStore instance with required storage medium. It has a factory method
 to create appropriate KVStore with supplied storage medium
 
 A convenience static method is also provided to create SQLite based KVStore
 */
enum KVStoreCreator
{
    static func createStore(kvStoreImplementation:KVStoreImplementation, storeName: String) -> NDKVStore
    {
        switch kvStoreImplementation
        {
        case .SQLite :
            return NDSQLiteKVStore(name: storeName);
        case .UserDefaults :
            return NDUserDefaultsKVStore(name: storeName);
        }
    }
    
    static func createStore(storeName storeName: String) -> NDKVStore
    {
        return NDSQLiteKVStore(name: storeName);
    }
}