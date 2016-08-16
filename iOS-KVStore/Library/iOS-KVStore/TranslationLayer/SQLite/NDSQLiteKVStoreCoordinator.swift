//
//  NDSQLiteKVStoreCoordinator.swift
//  KVStore
//
//  Created by Neeraj Damle on 5/30/16.
//  Copyright © 2016 NDamle. All rights reserved.
//
//
//  This is a singleton class to to create if not already created and then open SQLite database which is
//  used for storing all the key-value tuples
//  It creates tables to store tuples with keys that belong to any of the following types
//      - Integer
//      - Real (floating point keys)
//      - Text
//      - Blob
//


import Foundation

class NDSQLiteKVStoreCoordinator
{
    /**
     Instantiate static class variable
     Apple lazily instantiates global variables in dispatch_once block, this is guaranteed to be
     thread safe and private init method ensures that the object is unique and prevents outside objects
     creating their own instances of this class
      
     - returns: Initialized single unique object
    */
    static let sharedInstance = NDSQLiteKVStoreCoordinator();
    var db: NDSQLiteDatabase?;
    private init()
    {
        do
        {
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
            let dir = dirs[0] //library directory
            let path = (dir as NSString).stringByAppendingPathComponent("KeyValueStore.sqlite");
            
            //Open DB once while instantiating this store co-ordinator
            db = try NDSQLiteDatabase.open(path);
            
            /**
             Create following table. If the table is already present, it will not be created again
              - KVStore_Integer table
              - KVStore_Real table
              - KVStore_Text table
              - KVStore_Blob table
            */
            
            try db?.createTable_Integer(KVStore_Integer);
            try db?.createTable_Real(KVStore_Real);
            try db?.createTable_Text(KVStore_Text);
            try db?.createTable_Blob(KVStore_Blob);
        }
        catch NDSQLiteError.CreateDatabase(let message)
        {
            print("Unable to create database. Verify that you have provided correct path.");
            print(message);
        }
        catch NDSQLiteError.OpenDatabase(let message)
        {
            print("Unable to open database. Verify that you created the databse.");
            print(message);
        }
        catch NDSQLiteError.Step(let message)
        {
            print(message);
        }
        catch
        {
            print("Unknown error");
        }
    }
}

