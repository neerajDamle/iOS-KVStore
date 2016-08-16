//
//  NDSQLiteKVStore.swift
//  KVStore
//
//  Created by Neeraj Damle on 6/6/16.
//  Copyright © 2016 NDamle. All rights reserved.
//
//
//  This class manages the storage, retrieval and deletion of all the key-value tuples with different
//  types of keys and values
//  Application layer talks with this translation layer which translates the key-value tuples to be
//  compliant with underlying SQLite database
//  
//  Multiple KVStores can be created. All those stores share the underlying SQLite database
//

import Foundation

/**
 Enumeration to capture NDSQLiteKVStore key types
 */
enum NDSQLiteKVStoreKeyType
{
    case IntegerKey
    case RealKey
    case TextKey
    case BlobKey
    case UnknownKey
}

class NDSQLiteKVStore : NDKVStore
{
    //To keep track of the NDSQLiteKVStore owner
    weak var delegate: NDKVStoreOperationStatusProtocol?;
    //Store identifier
    var storeName : String;
    
    init(name: String)
    {
        storeName = name;
    }
    
    //NDSQLiteKVStoreCoordinator to communicate with underlying SQLite
    let kvStoreCoordinator : NDSQLiteKVStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
    
    /**
     Convenience method to insert key-value tuples with keys and values belonging to any of the
     following data types
        - Number (int or floating point numbers)
        - String
        - Array
        - Dictionary
        - Any object that is compliant with NDKVStorable protocol
     
     - parameter: key Key to be stored in NDSQLiteKVStore
     - parameter: value Value to be stored in NDSQLiteKVStore
     
     - returns: Throws exception if insert tuple operation fails
                Success/Failure status of insert operation
     */
    func put(key: AnyObject, value: AnyObject) throws -> Int
    {
        var dictionary : [String:AnyObject]?;
        
        var returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
        
        print("Put Key: \(key)");
        print("Put Value: \(value)");
        
        if value is NSNumber
        {
            print("The value is Number. Now check wheather it is integer or float")
            if CFNumberIsFloatType(value as! CFNumber)
            {
                print("The number is float");
                let castedValue = value as! Double;
                dictionary = castedValue.dictionaryRepresentation();
            }
            else
            {
                print("The number is integer");
                let castedValue = value as! Int;
                dictionary = castedValue.dictionaryRepresentation();
            }
        }
        else if value is String
        {
            print("The value is String");
            let castedValue = value as! String;
            dictionary = castedValue.dictionaryRepresentation();
        }
        else if value is Array<AnyObject>
        {
            print("The value is an Array");
            let castedValue = value as! Array<AnyObject>;
            dictionary = castedValue.dictionaryRepresentation();
        }
        else
        {
            if value is NDKVStorable
            {
                print("The value is NDKVStorable");
                let castedValue = value as! NDKVStorable;
                dictionary = castedValue.dictionaryRepresentation();
            }
        }
        
        guard dictionary != nil else
        {
            throw NDKVStoreError.DictionaryConversionFailed(message: "No dictionary representation available");
        }
        
        do
        {
            //Serialize NSDictionary to JSON
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary!, options: .PrettyPrinted);
            var json = String(data: jsonData, encoding: NSUTF8StringEncoding);
            if json == nil
            {
                json = "{}";
            }
            
            var keyType = NDSQLiteKVStoreKeyType.UnknownKey;
            
            if key is NSNumber
            {
                print("The key is Number. Now check wheather it is integer or float")
                if CFNumberIsFloatType(key as! CFNumber)
                {
                    print("The number is float");
                    keyType = .RealKey;
                }
                else
                {
                    print("The number is integer");
                    keyType = .IntegerKey;
                }
            }
            else if key is String
            {
                print("The key is String");
                keyType = .TextKey;
            }
            else if key is Array<AnyObject>
            {
                print("The key is an Array of AnyObject");
                keyType = .BlobKey;
            }
            else if key is Dictionary<String, AnyObject>
            {
                print("The key is Dictionary of String-AnyObject type");
                keyType = .BlobKey;
            }
            else if key is Dictionary<Int, AnyObject>
            {
                print("The key is Dictionary of Int-AnyObject type");
                keyType = .BlobKey;
            }
            else if key is Dictionary<Double, AnyObject>
            {
                print("The key is Dictionary of Double-AnyObject type");
                keyType = .BlobKey;
            }
            else if ((key as? NSCoder) != nil)
            {
                print("The key is an Object compliant with NSCoding");
                keyType = .BlobKey
            }
            else
            {
                keyType = .UnknownKey;
            }
            
            switch keyType
            {
            case .IntegerKey:
                let castedKey = key as! NSNumber;
                let kvPair : KVStore_Integer = KVStore_Integer(key: castedKey.intValue, value: json!, storeName: self.storeName);
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.insertTuple_Integer(kvPair);
                objc_sync_exit(self);
                
                //Update return status as Success
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            case .RealKey:
                let castedKey = key as! NSNumber;
                let kvPair : KVStore_Real = KVStore_Real(key: castedKey.doubleValue, value: json!, storeName: self.storeName);
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.insertTuple_Real(kvPair);
                objc_sync_exit(self);
                
                //Update return status as Success
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            case .TextKey:
                let castedKey = key as! String;
                let kvPair : KVStore_Text = KVStore_Text(key: castedKey, value: json!, storeName: self.storeName);
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.insertTuple_Text(kvPair);
                objc_sync_exit(self);
                
                //Update return status as Success
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            case .BlobKey:
                let keyData : NSData = NSKeyedArchiver.archivedDataWithRootObject(key)
                let kvPair : KVStore_Blob = KVStore_Blob(key: keyData, value: json!, storeName: self.storeName);
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.insertTuple_Blob(kvPair);
                objc_sync_exit(self);
                
                //Update return status as Success
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            default:
                print("Unknown key type");
                //Update return status as Failure
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
            }
        }
        catch NDSQLiteError.Bind(let message)
        {
            print(message);
        }
        catch NDSQLiteError.Step(let message)
        {
            print(message);
        }
        catch let error as NSError
        {
            print("JSON error: \(error.localizedDescription)");
            print(NDKVStoreConstants.JSONErrorMessages.JSON_SERIALIZATION_ERROR);
        }
        
        if returnValue == NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS
        {
            delegate?.didStoreTuple(self);
        }
        else if returnValue == NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE
        {
            delegate?.failToStoreTuple(self);
        }
        
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
     
     - parameter: key Key to be used for retrieved tuple from NDSQLiteKVStore
     
     - returns: Returns the tuple or nil
     */
    func get(key: AnyObject) -> KVStore_Generic?
    {
        var tuple : KVStore_Generic?;

        var keyType = NDSQLiteKVStoreKeyType.UnknownKey;
        
        if key is NSNumber
        {
            print("The key is Number. Now check wheather it is integer or float")
            if CFNumberIsFloatType(key as! CFNumber)
            {
                print("The number is float");
                keyType = .RealKey;
            }
            else
            {
                print("The number is integer");
                keyType = .IntegerKey;
            }
        }
        else if key is String
        {
            print("The key is String");
            keyType = .TextKey;
        }
        else if key is Array<AnyObject>
        {
            print("The key is an Array of AnyObject");
            keyType = .BlobKey;
        }
        else if key is Dictionary<String, AnyObject>
        {
            print("The key is Dictionary of String-AnyObject type");
            keyType = .BlobKey;
        }
        else if key is Dictionary<Int, AnyObject>
        {
            print("The key is Dictionary of Int-AnyObject type");
            keyType = .BlobKey;
        }
        else if key is Dictionary<Double, AnyObject>
        {
            print("The key is Dictionary of Double-AnyObject type");
            keyType = .BlobKey;
        }
        else if ((key as? NSCoder) != nil)
        {
            print("The key is an Object comliant with NSCoding");
            keyType = .BlobKey
        }
        else
        {
            keyType = .UnknownKey;
        }
        
        switch keyType
        {
        case .IntegerKey:
            let castedKey = key as! NSNumber;
            //Synchronize access to DB
            objc_sync_enter(self);
            let kvPair : KVStore_Integer? = kvStoreCoordinator.db?.kvPair_integer(castedKey.intValue, storeName: self.storeName);
            objc_sync_exit(self);
            
            //Convert to KVStore_Generic
            if(kvPair != nil)
            {
                tuple = KVStore_Generic(key: NSNumber(int:(kvPair?.key)!), value: (kvPair?.value)!, storeName: (kvPair?.storeName)!);
            }
            
        case .RealKey:
            let castedKey = key as! NSNumber;
            //Synchronize access to DB
            objc_sync_enter(self);
            let kvPair : KVStore_Real? = kvStoreCoordinator.db?.kvPair_real(castedKey.doubleValue, storeName: self.storeName);
            objc_sync_exit(self);
            
            //Convert to KVStore_Generic
            if(kvPair != nil)
            {
                tuple = KVStore_Generic(key: NSNumber(double:(kvPair?.key)!), value: (kvPair?.value)!, storeName: (kvPair?.storeName)!);
            }
            
        case .TextKey:
            let castedKey = key as! String;
            //Synchronize access to DB
            objc_sync_enter(self);
            let kvPair : KVStore_Text? = kvStoreCoordinator.db?.kvPair_text(castedKey, storeName: self.storeName);
            objc_sync_exit(self);
            
            //Convert to KVStore_Generic
            if(kvPair != nil)
            {
                tuple = KVStore_Generic(key: (kvPair?.key)!, value: (kvPair?.value)!, storeName: (kvPair?.storeName)!);
            }
            
        case .BlobKey:
            let keyData : NSData = NSKeyedArchiver.archivedDataWithRootObject(key)
            //Synchronize access to DB
            objc_sync_enter(self);
            let kvPair : KVStore_Blob? = kvStoreCoordinator.db?.kvPair_blob(keyData, storeName: self.storeName);
            objc_sync_exit(self);
            
            //Convert to KVStore_Generic
            if(kvPair != nil)
            {
                if let castedKey = NSKeyedUnarchiver.unarchiveObjectWithData((kvPair?.key)!)! as? NSDictionary
                {
                    print("Key is dictionary");
                    tuple = KVStore_Generic(key: castedKey, value: (kvPair?.value)!, storeName: (kvPair?.storeName)!);
                }
                else if let castedKey = NSKeyedUnarchiver.unarchiveObjectWithData((kvPair?.key)!)! as? NSArray
                {
                    print("Key is array");
                    tuple = KVStore_Generic(key: castedKey, value: (kvPair?.value)!, storeName: (kvPair?.storeName)!);
                }
            }
            
        default:
            print("Unknown key type");
        }
        
        return tuple;
    }
    
    /**
     Convenience method to delete key-value tuple associated with the provided key from NDSQLiteKVStore
     
     - parameter: key Key to be used to delete associated tuple from NDSQLiteKVStore
     
     - returns: Success/Failure status of delete operation
     */
    func deleteTuple(key key:AnyObject) -> Int
    {
        var returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
        
        var keyType = NDSQLiteKVStoreKeyType.UnknownKey;
        
        if key is NSNumber
        {
            print("The key is Number. Now check wheather it is integer or float")
            if CFNumberIsFloatType(key as! CFNumber)
            {
                print("The number is float");
                keyType = .RealKey;
            }
            else
            {
                print("The number is integer");
                keyType = .IntegerKey;
            }
        }
        else if key is String
        {
            print("The key is String");
            keyType = .TextKey;
        }
        else if key is Array<AnyObject>
        {
            print("The key is an Array of AnyObject");
            keyType = .BlobKey;
        }
        else if key is Dictionary<String, AnyObject>
        {
            print("The key is Dictionary of String-AnyObject type");
            keyType = .BlobKey;
        }
        else if key is Dictionary<Int, AnyObject>
        {
            print("The key is Dictionary of Int-AnyObject type");
            keyType = .BlobKey;
        }
        else if key is Dictionary<Double, AnyObject>
        {
            print("The key is Dictionary of Double-AnyObject type");
            keyType = .BlobKey;
        }
        else if ((key as? NSCoder) != nil)
        {
            print("The key is an Object comliant with NSCoding");
            keyType = .BlobKey
        }
        else
        {
            keyType = .UnknownKey;
        }
        
        do
        {
            switch keyType
            {
            case .IntegerKey:
                let castedKey = key as! NSNumber;
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.deleteTupleForIntegerKey(castedKey.intValue, storeName: self.storeName);
                objc_sync_exit(self);
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            case .RealKey:
                let castedKey = key as! NSNumber;
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.deleteTupleForRealKey(castedKey.doubleValue, storeName: self.storeName);
                objc_sync_exit(self);
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            case .TextKey:
                let castedKey = key as! String;
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.deleteTupleForTextKey(castedKey, storeName: self.storeName);
                objc_sync_exit(self);
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            case .BlobKey:
                let keyData : NSData = NSKeyedArchiver.archivedDataWithRootObject(key)
                //Synchronize access to DB
                objc_sync_enter(self);
                try kvStoreCoordinator.db?.deleteTupleForBlobKey(keyData, storeName: self.storeName);
                objc_sync_exit(self);
                returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
                
            default:
                print("Unknown key type");
            }
        }
        catch NDSQLiteError.Bind(let message)
        {
            print(message);
        }
        catch NDSQLiteError.Step(let message)
        {
            print(message);
        }
        catch let error as NSError
        {
            print("Delete operation error: \(error.localizedDescription)");
        }
        
        return returnValue;
    }
    
    /**
     Convenience method to delete all key-value tuples from the NDSQLiteKVStore
     
     - returns: Success/Failure status of delete operation
     */
    func deleteAllTuples() -> Int
    {
        var returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_FAILURE;
        
        do
        {
            //Delete all Integer key tuples from DB
            try kvStoreCoordinator.db?.deleteAllIntegerKeyTuples(storeName: self.storeName);
            
            //Delete all Real key tuples from DB
            try kvStoreCoordinator.db?.deleteAllRealKeyTuples(storeName: self.storeName);
            
            //Delete all Text key tuples from DB
            try kvStoreCoordinator.db?.deleteAllTextKeyTuples(storeName: self.storeName);
            
            //Delete all Blob key tuples from DB
            try kvStoreCoordinator.db?.deleteAllBlobKeyTuples(storeName: self.storeName);
            
            returnValue = NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS;
        }
        catch NDSQLiteError.Bind(let message)
        {
            print(message);
        }
        catch NDSQLiteError.Step(let message)
        {
            print(message);
        }
        catch let error as NSError
        {
            print("Delete operation error: \(error.localizedDescription)");
        }
        
        return returnValue;
    }
    
    /**
     Convenience method to print key and value associated with the provided key
     
     - parameter: key Key to be used to retrieve and print tuple from NDSQLiteKVStore
     
     */
    func printTuple(key key:AnyObject)
    {
        let tuple = self.get(key);
        if(tuple != nil)
        {
            print("Key: \(tuple!.key)");
            print("Value: \(tuple!.value)");
            print("Store name: \(tuple!.storeName)");
        }
        else
        {
            print("Tuple is nil");
        }
    }
    
    /**
     Convenience method to print all key-value tuples from the NDSQLiteKVStore
     */
    func printAllTuples()
    {
        print("/*************************** Tuples for \(self.storeName) ***************************/");
        //Print all Integer key tuples from DB
        if let tuples : [KVStore_Integer] = kvStoreCoordinator.db?.allKVPairs_integer(storeName: self.storeName)
        {
            for kvPair in tuples
            {
                let key = NSNumber(int:kvPair.key);
                let value = kvPair.value;
                print("\(key) : \(value)\n");
            }
        }
        
        //Print all Real key tuples from DB
        if let tuples : [KVStore_Real] = kvStoreCoordinator.db?.allKVPairs_real(storeName: self.storeName)
        {
            for kvPair in tuples
            {
                let key = NSNumber(double:kvPair.key);
                let value = kvPair.value;
                print("\(key) : \(value)\n");
            }
        }
        
        //Print all Text key tuples from DB
        if let tuples : [KVStore_Text] = kvStoreCoordinator.db?.allKVPairs_text(storeName: self.storeName)
        {
            for kvPair in tuples
            {
                let key = kvPair.key;
                let value = kvPair.value;
                print("\(key) : \(value)\n");
            }
        }
        
        //Print all Blob key tuples from DB
        if let tuples : [KVStore_Blob] = kvStoreCoordinator.db?.allKVPairs_blob(storeName: self.storeName)
        {
            for kvPair in tuples
            {
                let key = NSKeyedUnarchiver.unarchiveObjectWithData(kvPair.key);
                let value = kvPair.value;
                print("\(key) : \(value)\n");
            }
        }
    }
}


