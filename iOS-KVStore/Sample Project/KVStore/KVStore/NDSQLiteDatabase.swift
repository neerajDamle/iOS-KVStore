//
//  NDSQLiteDatabase.swift
//  KVStore
//
//  Created by Neeraj Damle on 5/30/16.
//  Copyright © 2016 NDamle. All rights reserved.
//
//
//
//  This class manages the actual SQLite database with following operations
//      - Database creation
//      - Open database
//      - Create tables to support keys of following types
//          - Integer
//          - Real (Floating point keys)
//          - Text
//          - Blob
//      - Insert tuples
//      - Retrieve tuples based on key or all tuples
//      - Delete tuples based on key or all tuples
//

import Foundation

//Constants for SQLite table name, columns
struct SQLiteTable
{
    static let TABLE_NAME_WITH_INTEGER_KEY = "KVStore_Integer";
    static let TABLE_NAME_WITH_REAL_KEY = "KVStore_Real";
    static let TABLE_NAME_WITH_TEXT_KEY = "KVStore_Text";
    static let TABLE_NAME_WITH_BLOB_KEY = "KVStore_Blob";
    static let TABLE_COLUMN_KEY = "Key";
    static let TABLE_COLUMN_VALUE = "Value";
    static let TABLE_COLUMN_STORE_NAME = "Store_Name";
};

//Constants for custom sqlite error codes
struct SQLiteErrorMessages
{
    static let CREATE_DATABASE_ERROR = "Failed to create database.";
    static let OPEN_DATABASE_ERROR = "Failed to open database.";
    static let PREPARE_STATEMENT_ERROR = "Failed to prepare statement.";
    static let STEP_STATEMENT_ERROR = "Failed to execute prepared statement.";
    static let BIND_VALUE_ERROR = "Failed to bind values to prepared statement.";
    static let CREATE_TABLE_ERROR = "Failed to create table.";
    static let INSERT_INTO_TABLE_ERROR = "Failed to insert record.";
    static let FETCH_FROM_TABLE_ERROR = "Failed to fetch record.";
    static let DEFAULT_ERROR = "No error message provided from sqlite.";
}

//Struct to store key-value pair with associated store identifier in generic format
public struct KVStore_Generic
{
    //Key will always be string
    public let key: AnyObject
    //Value will always be JSON string
    public let value: String
    //Store name
    public let storeName: String;
}

//Struct to store key-value pair having Integer keys with associated store identifier
public struct KVStore_Integer : NDSQLTable_Integer
{
    //Key will always be string
    public let key: Int32
    //Value will always be JSON string
    public let value: String
    //Store name
    public let storeName: String;
    
    //Create table statement for KVStore_Integer table
    static var createStatement_integer: String
    {
        return "CREATE TABLE if not exists \(SQLiteTable.TABLE_NAME_WITH_INTEGER_KEY)(" +
            "\(SQLiteTable.TABLE_COLUMN_KEY) INTEGER PRIMARY KEY NOT NULL," +
            "\(SQLiteTable.TABLE_COLUMN_VALUE) BLOB," +
            "\(SQLiteTable.TABLE_COLUMN_STORE_NAME) TEXT NOT NULL" +
        ");"
    }
}

//Struct to store key-value pair having Real keys with associated store identifier
public struct KVStore_Real : NDSQLTable_Real
{
    //Key will always be string
    public let key: Double
    //Value will always be JSON string
    public let value: String
    //Store name
    public let storeName: String;
    
    //Create table statement for KVStore_Real table
    static var createStatement_real: String
    {
        return "CREATE TABLE if not exists \(SQLiteTable.TABLE_NAME_WITH_REAL_KEY)(" +
            "\(SQLiteTable.TABLE_COLUMN_KEY) TEXT PRIMARY KEY NOT NULL," +
            "\(SQLiteTable.TABLE_COLUMN_VALUE) BLOB," +
            "\(SQLiteTable.TABLE_COLUMN_STORE_NAME) TEXT NOT NULL" +
        ");"
    }
}

//Struct to store key-value pair having Text keys with associated store identifier
public struct KVStore_Text : NDSQLTable_Text
{
    //Key will always be string
    public let key: String
    //Value will always be JSON string
    public let value: String
    //Store name
    public let storeName: String;
    
    //Create table statement for KVStore_Text table
    static var createStatement_text: String
    {
        return "CREATE TABLE if not exists \(SQLiteTable.TABLE_NAME_WITH_TEXT_KEY)(" +
            "\(SQLiteTable.TABLE_COLUMN_KEY) TEXT PRIMARY KEY NOT NULL," +
            "\(SQLiteTable.TABLE_COLUMN_VALUE) BLOB," +
            "\(SQLiteTable.TABLE_COLUMN_STORE_NAME) TEXT NOT NULL" +
        ");"
    }
}

//Struct to store key-value pair having Blob keys with associated store identifier
public struct KVStore_Blob : NDSQLTable_Blob
{
    //Key will always be string
    public let key: NSData
    //Value will always be JSON string
    public let value: String
    //Store name
    public let storeName: String;
    
    //Create table statement for KVStore_Blob table
    static var createStatement_blob: String
    {
        return "CREATE TABLE if not exists \(SQLiteTable.TABLE_NAME_WITH_BLOB_KEY)(" +
            "\(SQLiteTable.TABLE_COLUMN_KEY) TEXT PRIMARY KEY NOT NULL," +
            "\(SQLiteTable.TABLE_COLUMN_VALUE) BLOB," +
            "\(SQLiteTable.TABLE_COLUMN_STORE_NAME) TEXT NOT NULL" +
        ");"
    }
}

/**
 Enumeration to capture SQLite errors. Suitable message can be passed to describe the error
 */
enum NDSQLiteError : ErrorType
{
    case CreateDatabase(message: String)
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

/**
 Protocol to be implemented by all the classes for creating a relational table having an Ineteger key
 For KVStore implementation using SQLite, there is only table created which stores all the Key-Value tuples having key as Integer
 */
protocol NDSQLTable_Integer
{
    static var createStatement_integer: String { get }
}

/**
 Protocol to be implemented by all the classes for creating a relational table having a Real key
 For KVStore implementation using SQLite, there is only table created which stores all the Key-Value tuples having key as Real
 */
protocol NDSQLTable_Real
{
    static var createStatement_real: String { get }
}

/**
 Protocol to be implemented by all the classes for creating a relational table having a Text key
 For KVStore implementation using SQLite, there is only table created which stores all the Key-Value tuples having key as Text
 */
protocol NDSQLTable_Text
{
    static var createStatement_text: String { get }
}

/**
 Protocol to be implemented by all the classes for creating a relational table having a Blob key
 For KVStore implementation using SQLite, there is only table created which stores all the Key-Value tuples having key as Blob
 */
protocol NDSQLTable_Blob
{
    static var createStatement_blob: String { get }
}

/**
 This class manages all the operations associated with a SQLite database like Create DB, Open DB, Create table, Insert records etc
 This is singleton class which holds a reference to the database
 
 The class implements a class method to which database path can be passed
 If the database is already present at the given path, it will be opened for further operations
 If the database doesn't exist, it will created and then opened for further operations
 */
class NDSQLiteDatabase
{
    private let dbPointer: COpaquePointer;
    
    /**
     This is a private initializer since the class is a singleton class
     The initializer will be called on creating the instance of this class with a pointer to opened database
     */
    private init(dbPointer: COpaquePointer)
    {
        self.dbPointer = dbPointer;
    }
    
    /**
     Close the database before the memory for the class instance is deallocated
     */
    deinit
    {
        sqlite3_close(self.dbPointer)
    }
    
    //MARK: Open or Create Database
    /**
     Opens a database at specified path if already exists
     If the database doesn't exist, it will created and then opened
     The number is converted into a dictionary having single default key and JSON string and then
     passed to DB for storing
     
     - parameter dbPath File system path where database resides or need to be created
     
     - returns: Throws exception if any of the operation fails
     */
    static func open(dbPath: String) throws -> NDSQLiteDatabase
    {
        var db: COpaquePointer = nil;
        
        let fileManager = NSFileManager.defaultManager();
        if !fileManager.fileExistsAtPath(dbPath)
        {
            guard fileManager.createFileAtPath(dbPath, contents: nil, attributes: nil) else
            {
                print(SQLiteErrorMessages.CREATE_DATABASE_ERROR);
                throw NDSQLiteError.CreateDatabase(message: SQLiteErrorMessages.CREATE_DATABASE_ERROR);
            }
        }
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK
        {
            return NDSQLiteDatabase(dbPointer: db);
        }
        else
        {
            defer
            {
                if db != nil
                {
                    sqlite3_close(db);
                }
            }
        }
        
        if let message = String.fromCString(sqlite3_errmsg(db))
        {
            print(SQLiteErrorMessages.OPEN_DATABASE_ERROR);
            throw NDSQLiteError.OpenDatabase(message: message);
        }
        else
        {
            print(SQLiteErrorMessages.DEFAULT_ERROR);
            throw NDSQLiteError.OpenDatabase(message: SQLiteErrorMessages.DEFAULT_ERROR);
        }
    }
    
    //MARK: Error message property
    /**
     Computed property to return error description of the last SQLite error
     If SQLite doesn't provide any error, default error message will be returned
     */
    private var errorMessage: String
    {
        if let errorMessage = String.fromCString(sqlite3_errmsg(dbPointer))
        {
            return errorMessage;
        }
        else
        {
            return SQLiteErrorMessages.DEFAULT_ERROR;
        }
    }
}

extension NDSQLiteDatabase
{
    /**
     Convenience method to create prepared statement for any of the SQLite operations
     
     - parameter sql SQLite operation query in string format
     
     - returns: Throws exception if prepared statement can no be created for the provided query
     */
    func prepareStatement(sql: String) throws -> COpaquePointer
    {
        var statement: COpaquePointer = nil
        guard sqlite3_prepare_v2(self.dbPointer, sql, -1, &statement, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            throw NDSQLiteError.Prepare(message: errorMessage);
        }
        
        return statement
    }
    
    //MARK: Create table with Integer key
    /**
     Convenience method to create table having Integer key
     
     - parameter table Table to be created which conforms NDSQLTable_Integer protocol
     
     - returns: Throws exception if create table operation fails
     */
    func createTable_Integer(table: NDSQLTable_Integer.Type) throws
    {
        let createTableStatement = try prepareStatement(table.createStatement_integer);
        defer
        {
            sqlite3_finalize(createTableStatement);
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("\(table) Table created successfully - Integer.")
    }
    
    //MARK: Create table with Real key
    /**
     Convenience method to create table having Real key
     
     - parameter table Table to be created which conforms NDSQLTable_Real protocol
     
     - returns: Throws exception if create table operation fails
     */
    func createTable_Real(table: NDSQLTable_Real.Type) throws
    {
        let createTableStatement = try prepareStatement(table.createStatement_real);
        defer
        {
            sqlite3_finalize(createTableStatement);
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("\(table) Table created successfully - Real.")
    }
    
    //MARK: Create table with Text key
    /**
     Convenience method to create table having Text key
     
     - parameter table Table to be created which conforms NDSQLTable_Text protocol
     
     - returns: Throws exception if create table operation fails
     */
    func createTable_Text(table: NDSQLTable_Text.Type) throws
    {
        let createTableStatement = try prepareStatement(table.createStatement_text);
        defer
        {
            sqlite3_finalize(createTableStatement);
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("\(table) Table created successfully - Text.")
    }
    
    //MARK: Create table with Blob key
    /**
     Convenience method to create table having Blob key
     
     - parameter table Table to be created which conforms NDSQLTable_Blob protocol
     
     - returns: Throws exception if create table operation fails
     */
    func createTable_Blob(table: NDSQLTable_Blob.Type) throws
    {
        let createTableStatement = try prepareStatement(table.createStatement_blob);
        defer
        {
            sqlite3_finalize(createTableStatement);
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("\(table) Table created successfully - Blob.")
    }
    
    //MARK: Insert tuple in Ineteger key table
    /**
     Convenience method to insert key-value tuple having Integer key into the KVStore
     
     - parameter kvPair A tuple containing key and value to be inserted with Integer key
     
     - returns: Throws exception if insert tuple operation fails
     */
    func insertTuple_Integer(kvPair: KVStore_Integer) throws
    {
        let insertSql = "INSERT INTO \(SQLiteTable.TABLE_NAME_WITH_INTEGER_KEY) (\(SQLiteTable.TABLE_COLUMN_KEY), \(SQLiteTable.TABLE_COLUMN_VALUE), \(SQLiteTable.TABLE_COLUMN_STORE_NAME)) VALUES (?, ?, ?);"
        print("Insert statement: \(insertSql)");
        print("Key: \(kvPair.key)");
        let insertStatement = try prepareStatement(insertSql)
        defer
        {
            sqlite3_finalize(insertStatement);
        }
        
        let key: Int32 = kvPair.key;
        let strValue: String? = kvPair.value;
        let value: NSData? = strValue?.dataUsingEncoding(NSUTF8StringEncoding);
        let storeName: String = kvPair.storeName;
        
        if let data = value
        {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self);
            guard sqlite3_bind_int(insertStatement, 1, key) == SQLITE_OK  &&
                sqlite3_bind_blob(insertStatement, 2, data.bytes, Int32(data.length), SQLITE_TRANSIENT) == SQLITE_OK &&
                sqlite3_bind_text(insertStatement, 3, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
            {
                print(SQLiteErrorMessages.BIND_VALUE_ERROR);
                throw NDSQLiteError.Bind(message: errorMessage);
            }
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else
            {
                print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
                throw NDSQLiteError.Step(message: errorMessage);
            }
            
            print("Inserted tuple successfully - Integer.")
        }
    }
    
    //MARK: Insert tuple in Real key table
    /**
     Convenience method to insert key-value tuple having Real key into the KVStore
     
     - parameter kvPair A tuple containing key and value to be inserted with Real key
     
     - returns: Throws exception if insert tuple operation fails
     */
    func insertTuple_Real(kvPair: KVStore_Real) throws
    {
        let insertSql = "INSERT INTO \(SQLiteTable.TABLE_NAME_WITH_REAL_KEY) (\(SQLiteTable.TABLE_COLUMN_KEY), \(SQLiteTable.TABLE_COLUMN_VALUE), \(SQLiteTable.TABLE_COLUMN_STORE_NAME)) VALUES (?, ?, ?);"
        print("Insert statement: \(insertSql)");
        print("Key: \(kvPair.key)");
        let insertStatement = try prepareStatement(insertSql)
        defer
        {
            sqlite3_finalize(insertStatement);
        }
        
        let key: Double = kvPair.key;
        let strValue: String? = kvPair.value;
        let value: NSData? = strValue?.dataUsingEncoding(NSUTF8StringEncoding);
        let storeName: String = kvPair.storeName;
        
        if let data = value
        {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self);
            guard sqlite3_bind_double(insertStatement, 1, key) == SQLITE_OK  &&
                sqlite3_bind_blob(insertStatement, 2, data.bytes, Int32(data.length), SQLITE_TRANSIENT) == SQLITE_OK &&
                sqlite3_bind_text(insertStatement, 3, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
            {
                print(SQLiteErrorMessages.BIND_VALUE_ERROR);
                throw NDSQLiteError.Bind(message: errorMessage);
            }
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else
            {
                print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
                throw NDSQLiteError.Step(message: errorMessage);
            }
            
            print("Inserted tuple successfully - Real.")
        }
    }
    
    //MARK: Insert tuple in Text key table
    /**
     Convenience method to insert key-value tuple having Text key into the KVStore
     
     - parameter kvPair A tuple containing key and value to be inserted with Text key
     
     - returns: Throws exception if insert tuple operation fails
     */
    func insertTuple_Text(kvPair: KVStore_Text) throws
    {
        let insertSql = "INSERT INTO \(SQLiteTable.TABLE_NAME_WITH_TEXT_KEY) (\(SQLiteTable.TABLE_COLUMN_KEY), \(SQLiteTable.TABLE_COLUMN_VALUE), \(SQLiteTable.TABLE_COLUMN_STORE_NAME)) VALUES (?, ?, ?);"
        print("Insert statement: \(insertSql)");
        print("Key: \(kvPair.key)");
        let insertStatement = try prepareStatement(insertSql)
        defer
        {
            sqlite3_finalize(insertStatement);
        }
        
        let key: String = kvPair.key;
        let strValue: String? = kvPair.value;
        let value: NSData? = strValue?.dataUsingEncoding(NSUTF8StringEncoding);
        let storeName: String = kvPair.storeName;
        
        if let data = value
        {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self);
            guard sqlite3_bind_text(insertStatement, 1, (key as NSString).UTF8String, -1, nil) == SQLITE_OK  &&
                sqlite3_bind_blob(insertStatement, 2, data.bytes, Int32(data.length), SQLITE_TRANSIENT) == SQLITE_OK &&
                sqlite3_bind_text(insertStatement, 3, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
            {
                print(SQLiteErrorMessages.BIND_VALUE_ERROR);
                throw NDSQLiteError.Bind(message: errorMessage);
            }
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else
            {
                print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
                throw NDSQLiteError.Step(message: errorMessage);
            }
            
            print("Inserted tuple successfully - Text.")
        }
    }
    
    //MARK: Insert tuple in Blob key table
    /**
     Convenience method to insert key-value tuple having Blob key into the KVStore
     
     - parameter kvPair A tuple containing key and value to be inserted with Blob key
     
     - returns: Throws exception if insert tuple operation fails
     */
    func insertTuple_Blob(kvPair: KVStore_Blob) throws
    {
        let insertSql = "INSERT INTO \(SQLiteTable.TABLE_NAME_WITH_BLOB_KEY) (\(SQLiteTable.TABLE_COLUMN_KEY), \(SQLiteTable.TABLE_COLUMN_VALUE), \(SQLiteTable.TABLE_COLUMN_STORE_NAME)) VALUES (?, ?, ?);"
        print("Insert statement: \(insertSql)");
        print("Key: \(kvPair.key)");
        let insertStatement = try prepareStatement(insertSql)
        defer
        {
            sqlite3_finalize(insertStatement);
        }
        
        let key: NSData = kvPair.key;
        let strValue: String? = kvPair.value;
        let value: NSData? = strValue?.dataUsingEncoding(NSUTF8StringEncoding);
        let storeName: String = kvPair.storeName;
        
        if let data = value
        {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self);
            guard sqlite3_bind_blob(insertStatement, 1, key.bytes, Int32(key.length), SQLITE_TRANSIENT) == SQLITE_OK  &&
                sqlite3_bind_blob(insertStatement, 2, data.bytes, Int32(data.length), SQLITE_TRANSIENT) == SQLITE_OK  &&
                sqlite3_bind_text(insertStatement, 3, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
            {
                print(SQLiteErrorMessages.BIND_VALUE_ERROR);
                throw NDSQLiteError.Bind(message: errorMessage);
            }
            
            guard sqlite3_step(insertStatement) == SQLITE_DONE else
            {
                print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
                throw NDSQLiteError.Step(message: errorMessage);
            }
            
            print("Inserted tuple successfully - Blob.")
        }
    }
    
    //MARK: Fetch tuple(s) from Integer key table
    /**
     Convenience method to fetch value for the provided integer key from the KVStore
     
     - parameter key A integer key for which value to be fetched from KVStore
     
     - returns: Throws exception if select tuple operation fails
     */
    func kvPair_integer(key: Int32, storeName: String) -> KVStore_Integer?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_INTEGER_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_int(queryStatement, 1, key) == SQLITE_OK &&
            sqlite3_bind_text(queryStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        let key = sqlite3_column_int(queryStatement, 0);
        
        var value : String = "{}";
        let len = sqlite3_column_bytes(queryStatement, 1);
        let bytes = sqlite3_column_blob(queryStatement, 1);
        
        if bytes != nil
        {
            let rawData = NSData(bytes: bytes, length: Int(len));
            value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
        }
        
        let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
        let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
        
        return KVStore_Integer(key: key, value: value, storeName: storeName);
    }
    
    /**
     Convenience method to fetch all key-value tuples from the KVStore with Integer key
     
     - returns: Throws exception if select tuple operation fails
     Returns all the key-value tuples in an array on success
     */
    func allKVPairs_integer(storeName storeName: String) -> [KVStore_Integer]?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_INTEGER_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select all statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_text(queryStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        var record: CInt = 0;
        var tuples : [KVStore_Integer] = [];
        
        repeat
        {
            let key = sqlite3_column_int(queryStatement, 0);
            
            var value : String = "{}";
            let len = sqlite3_column_bytes(queryStatement, 1);
            let bytes = sqlite3_column_blob(queryStatement, 1);
            
            if bytes != nil
            {
                let rawData = NSData(bytes: bytes, length: Int(len));
                value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
            }
            
            let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
            let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
            
            let kvStore : KVStore_Integer = KVStore_Integer(key: key, value: value, storeName: storeName);
            tuples.append(kvStore);
            
            record = sqlite3_step(queryStatement);
        } while record == SQLITE_ROW
        return tuples;
    }
    
    //MARK: Fetch tuple(s) from Real key table
    /**
     Convenience method to fetch value for the provided real key from the KVStore
     
     - parameter key A real key for which value to be fetched from KVStore
     
     - returns: Throws exception if select tuple operation fails
     */
    func kvPair_real(key: Double, storeName: String) -> KVStore_Real?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_REAL_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_double(queryStatement, 1, key) == SQLITE_OK &&
            sqlite3_bind_text(queryStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        let key = sqlite3_column_double(queryStatement, 0);
        
        var value : String = "{}";
        let len = sqlite3_column_bytes(queryStatement, 1);
        let bytes = sqlite3_column_blob(queryStatement, 1);
        
        if bytes != nil
        {
            let rawData = NSData(bytes: bytes, length: Int(len));
            value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
        }
        
        let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
        let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
        
        return KVStore_Real(key: key, value: value, storeName: storeName);
    }
    
    /**
     Convenience method to fetch all key-value tuples from the KVStore with Real key
     
     - returns: Throws exception if select tuple operation fails
     Returns all the key-value tuples in an array on success
     */
    func allKVPairs_real(storeName storeName: String) -> [KVStore_Real]?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_REAL_KEY)  WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select all statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_text(queryStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        var record: CInt = 0;
        var tuples : [KVStore_Real] = [];
        
        repeat
        {
            let key = sqlite3_column_double(queryStatement, 0);
            
            var value : String = "{}";
            let len = sqlite3_column_bytes(queryStatement, 1);
            let bytes = sqlite3_column_blob(queryStatement, 1);
            
            if bytes != nil
            {
                let rawData = NSData(bytes: bytes, length: Int(len));
                value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
            }
            
            let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
            let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
            
            let kvStore : KVStore_Real = KVStore_Real(key: key, value: value, storeName: storeName);
            tuples.append(kvStore);
            
            record = sqlite3_step(queryStatement);
        } while record == SQLITE_ROW
        return tuples;
    }
    
    //MARK: Fetch tuple(s) from Text key table
    /**
     Convenience method to fetch value for the provided text key from the KVStore
     
     - parameter key A text key for which value to be fetched from KVStore
     
     - returns: Throws exception if select tuple operation fails
     */
    func kvPair_text(key: String, storeName: String) -> KVStore_Text?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_TEXT_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_text(queryStatement, 1, (key as NSString).UTF8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(queryStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        let column1Value = sqlite3_column_text(queryStatement, 0);
        let key = String.fromCString(UnsafePointer<CChar>(column1Value))!;
        
        var value : String = "{}";
        let len = sqlite3_column_bytes(queryStatement, 1);
        let bytes = sqlite3_column_blob(queryStatement, 1);
        
        if bytes != nil
        {
            let rawData = NSData(bytes: bytes, length: Int(len));
            value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
        }
        
        let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
        let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
        
        return KVStore_Text(key: key, value: value, storeName: storeName);
    }
    
    /**
     Convenience method to fetch all key-value tuples from the KVStore with Text key
     
     - returns: Throws exception if select tuple operation fails
     Returns all the key-value tuples in an array on success
     */
    func allKVPairs_text(storeName storeName: String) -> [KVStore_Text]?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_TEXT_KEY)  WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select all statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_text(queryStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        var record: CInt = 0;
        var tuples : [KVStore_Text] = [];
        
        repeat
        {
            let column1Value = sqlite3_column_text(queryStatement, 0);
            let key = String.fromCString(UnsafePointer<CChar>(column1Value))!;
            
            var value : String = "{}";
            let len = sqlite3_column_bytes(queryStatement, 1);
            let bytes = sqlite3_column_blob(queryStatement, 1);
            
            if bytes != nil
            {
                let rawData = NSData(bytes: bytes, length: Int(len));
                value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
            }
            
            let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
            let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
            
            let kvStore : KVStore_Text = KVStore_Text(key: key, value: value, storeName: storeName);
            tuples.append(kvStore);
            
            record = sqlite3_step(queryStatement);
        } while record == SQLITE_ROW
        return tuples;
    }
    
    //MARK: Fetch tuple(s) from Blob key table
    /**
     Convenience method to fetch value for the provided blob key from the KVStore
     
     - parameter key A blob key for which value to be fetched from KVStore
     
     - returns: Throws exception if select tuple operation fails
     */
    func kvPair_blob(key: NSData, storeName: String) -> KVStore_Blob?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_BLOB_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self);
        guard sqlite3_bind_blob(queryStatement, 1, key.bytes, Int32(key.length), SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(queryStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        var key : NSData = NSData();
        let keyLen = sqlite3_column_bytes(queryStatement, 0);
        let keyBytes = sqlite3_column_blob(queryStatement, 0);
        
        if keyBytes != nil
        {
            key = NSData(bytes: keyBytes, length: Int(keyLen));
        }
        
        var value : String = "{}";
        let valueLen = sqlite3_column_bytes(queryStatement, 1);
        let valueBytes = sqlite3_column_blob(queryStatement, 1);
        
        if valueBytes != nil
        {
            let rawData = NSData(bytes: valueBytes, length: Int(valueLen));
            value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
        }
        
        let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
        let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
        
        return KVStore_Blob(key: key, value: value, storeName: storeName);
    }
    
    /**
     Convenience method to fetch all key-value tuples from the KVStore with Blob key
     
     - returns: Throws exception if select tuple operation fails
     Returns all the key-value tuples in an array on success
     */
    func allKVPairs_blob(storeName storeName: String) -> [KVStore_Blob]?
    {
        let querySql = "SELECT * FROM \(SQLiteTable.TABLE_NAME_WITH_BLOB_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;";
        print("Select all statement: \(querySql)");
        guard let queryStatement = try? prepareStatement(querySql) else
        {
            print(SQLiteErrorMessages.PREPARE_STATEMENT_ERROR);
            return nil;
        }
        
        defer
        {
            sqlite3_finalize(queryStatement);
        }
        
        guard sqlite3_bind_text(queryStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            return nil;
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            return nil;
        }
        
        var record: CInt = 0;
        var tuples : [KVStore_Blob] = [];
        
        repeat
        {
            var key : NSData = NSData();
            let keyLen = sqlite3_column_bytes(queryStatement, 0);
            let keyBytes = sqlite3_column_blob(queryStatement, 0);
            
            if keyBytes != nil
            {
                key = NSData(bytes: keyBytes, length: Int(keyLen));
            }
            
            var value : String = "{}";
            let valueLen = sqlite3_column_bytes(queryStatement, 1);
            let valueBytes = sqlite3_column_blob(queryStatement, 1);
            
            if valueBytes != nil
            {
                let rawData = NSData(bytes: valueBytes, length: Int(valueLen));
                value = NSString(data: rawData, encoding: NSUTF8StringEncoding) as! String;
            }
            
            let storeNameColumnValue = sqlite3_column_text(queryStatement, 2);
            let storeName = String.fromCString(UnsafePointer<CChar>(storeNameColumnValue))!;
            
            let kvStore : KVStore_Blob = KVStore_Blob(key: key, value: value, storeName: storeName);
            tuples.append(kvStore);
            
            record = sqlite3_step(queryStatement);
        } while record == SQLITE_ROW
        return tuples;
    }
    
    //MARK: Delete tuple(s) from Integer key table
    /**
     Convenience method to delete key-value tuple from the KVStore with Integer key
     
     - parameter key Integer key to be used for deleting associated tuple
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteTupleForIntegerKey(key: Int32, storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_INTEGER_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_int(deleteStatement, 1, key) == SQLITE_OK  &&
            sqlite3_bind_text(deleteStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted tuple \"\(key)\" from \"\(storeName)\" successfully - Integer.")
    }
    
    /**
     Convenience method to delete all key-value tuples from the KVStore with Integer keys
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteAllIntegerKeyTuples(storeName storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_INTEGER_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_text(deleteStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted all tuples from \"\(storeName)\" successfully - Integer.")
    }
    
    //MARK: Delete tuple(s) from Real key table
    /**
     Convenience method to delete key-value tuple from the KVStore with Real key
     
     - parameter key Real key to be used for deleting associated tuple
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteTupleForRealKey(key: Double, storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_REAL_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_double(deleteStatement, 1, key) == SQLITE_OK &&
            sqlite3_bind_text(deleteStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted tuple \"\(key)\" from \"\(storeName)\" successfully - Real.")
    }
    
    /**
     Convenience method to delete all key-value tuples from the KVStore with Real keys
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteAllRealKeyTuples(storeName storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_REAL_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_text(deleteStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted all tuples from \"\(storeName)\" successfully - Real.")
    }
    
    //MARK: Delete tuple(s) from Text key table
    /**
     Convenience method to delete key-value tuple from the KVStore with Text key
     
     - parameter key Text key to be used for deleting associated tuple
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteTupleForTextKey(key: String, storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_TEXT_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_text(deleteStatement, 1, (key as NSString).UTF8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(deleteStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted tuple \"\(key)\" from \"\(storeName)\" successfully - Text.")
    }
    
    /**
     Convenience method to delete all key-value tuples from the KVStore with Text keys
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteAllTextKeyTuples(storeName storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_TEXT_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_text(deleteStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted all tuples from \"\(storeName)\" successfully - Text.")
    }
    
    //MARK: Delete tuple(s) from Blob key table
    /**
     Convenience method to delete key-value tuple from the KVStore with Blob key
     
     - parameter key Blob key to be used for deleting associated tuple
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteTupleForBlobKey(key: NSData, storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_BLOB_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_KEY) = ? AND \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self);
        guard sqlite3_bind_blob(deleteStatement, 1, key.bytes, Int32(key.length), SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(deleteStatement, 2, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted tuple \"\(key)\" from \"\(storeName)\" successfully - Blob.")
    }
    
    /**
     Convenience method to delete all key-value tuples from the KVStore with Blob keys
     
     - returns: Throws exception if delete tuple operation fails
     */
    func deleteAllBlobKeyTuples(storeName storeName: String) throws
    {
        let deleteSql = "DELETE FROM \(SQLiteTable.TABLE_NAME_WITH_BLOB_KEY) WHERE \(SQLiteTable.TABLE_COLUMN_STORE_NAME) = ?;"
        print("Delete statement: \(deleteSql)");
        let deleteStatement = try prepareStatement(deleteSql)
        defer
        {
            sqlite3_finalize(deleteStatement);
        }
        
        guard sqlite3_bind_text(deleteStatement, 1, (storeName as NSString).UTF8String, -1, nil) == SQLITE_OK else
        {
            print(SQLiteErrorMessages.BIND_VALUE_ERROR);
            throw NDSQLiteError.Bind(message: errorMessage);
        }
        
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else
        {
            print(SQLiteErrorMessages.STEP_STATEMENT_ERROR);
            throw NDSQLiteError.Step(message: errorMessage);
        }
        
        print("Deleted all tuples from \"\(storeName)\" successfully - Blob.")
    }
}