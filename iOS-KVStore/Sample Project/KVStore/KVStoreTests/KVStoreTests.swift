//
//  KVStoreTests.swift
//  KVStoreTests
//
//  Created by Neeraj Damle on 5/30/16.
//  Copyright © 2016 NDamle. All rights reserved.
//

import XCTest
@testable import KVStore

class KVStoreTests: XCTestCase {
    
    var kvStoreCoordinator : NDSQLiteKVStoreCoordinator? = nil;
    let libraryDir : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.AllDomainsMask, true)[0];
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func XCTempAssertNoThrowError(message: String = "", file: String = #file, line: UInt = #line, _ block: () throws -> ())
    {
        do {try block()}
        catch
        {
            let msg = (message == "") ? "Tested block threw unexpected error." : message
            XCTFail(msg, file: #file, line: line)
        }
    }
    
    //Test case to check whether DB is created at given path
    func testDBExistence()
    {
        let path = (libraryDir as NSString).stringByAppendingPathComponent("KeyValueStore.sqlite");
        let fileManager = NSFileManager.defaultManager();
        let status: Bool = fileManager.fileExistsAtPath(path);
        XCTAssertTrue(status);
    }
    
    //Test case to check whether DB is opened
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that some exception is thrown
    func testDBOpen()
    {
        let path = (libraryDir as NSString).stringByAppendingPathComponent("KeyValueStore.sqlite");
        XCTempAssertNoThrowError { 
            try NDSQLiteDatabase.open(path);
        }
    }
    
    //Test case to check whether KVStore_Integer table is created
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the table creation operation threw some exception
    func testTableCreation_Integer()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        XCTempAssertNoThrowError {
            try self.kvStoreCoordinator?.db?.createTable_Integer(KVStore_Integer)
        }
    }
    
    //Test case to check whether KVStore_Real table is created
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the table creation operation threw some exception
    func testTableCreation_Real()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        XCTempAssertNoThrowError {
            try self.kvStoreCoordinator?.db?.createTable_Real(KVStore_Real)
        }
    }
    //Test case to check whether KVStore_Text table is created
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the table creation operation threw some exception
    func testTableCreation_Text()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        XCTempAssertNoThrowError {
            try self.kvStoreCoordinator?.db?.createTable_Text(KVStore_Text)
        }
    }
    //Test case to check whether KVStore_Blob table is created
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the table creation operation threw some exception
    func testTableCreation_Blob()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        XCTempAssertNoThrowError {
            try self.kvStoreCoordinator?.db?.createTable_Blob(KVStore_Blob)
        }
    }
    
    //Test case to check JSON serialization
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //JSON serialization threw some exception
    func testJSONSerializationForSingleString()
    {
        let value : String = "Test string";
        let dictionary : [String:AnyObject] = ["Key":value];
        XCTempAssertNoThrowError
        {
            try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
        }
    }
    
    //Test case to check whether object can be inserted
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the tuple insertion operation threw some exception
    func testInsertObjectSQLite()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        
        //Insert Person object
        let calender = NSCalendar.currentCalendar();
        let components = NSDateComponents();
        components.day = 1;
        components.month = 11;
        components.year = 1989;
        let birthDate = calender.dateFromComponents(components);
        
        let hobbies: [String] = ["Hiking","Photography"];
        
        let workExperience : [String:Float] = ["XYZ":3];
        let person: Person = Person(firstName: "Neeraj", middleName: "Suresh", lastName: "Damle", gender: "Male", birthDate: birthDate!, email: "neeraj.damle@email.com", SSN: 1234567, hobbies: hobbies, workExperience: workExperience);
        let personDictionaryRepresentation = person.dictionaryRepresentation();
        
        var jsonData : NSData = NSData();
        XCTempAssertNoThrowError
        {
            jsonData = try NSJSONSerialization.dataWithJSONObject(personDictionaryRepresentation!, options: .PrettyPrinted);
        }
        var json = String(data: jsonData, encoding: NSUTF8StringEncoding);
        if json == nil
        {
            json = "{}";
        }
        
        let kvPair: KVStore_Text = KVStore_Text(key: "Person - SQLite", value: json!, storeName: "Sample store");
        XCTempAssertNoThrowError
        {
            try self.kvStoreCoordinator?.db?.insertTuple_Text(kvPair);
        }
    }
    
    //Test case to check whether object can be inserted
    //This test case uses XCTAssertEqual. So the test case failure indicate that
    //the object insertion operation returned failure status
    func testInsertObjectKVStore()
    {
        let kvStore = KVStoreCreator.createStore(storeName: "Sample Store");
        
        //Insert Person object
        let calender = NSCalendar.currentCalendar();
        let components = NSDateComponents();
        components.day = 1;
        components.month = 11;
        components.year = 1989;
        let birthDate = calender.dateFromComponents(components);
        
        let hobbies: [String] = ["Hiking","Photography"];
        
        let workExperience : [String:Float] = ["XYZ":3];
        let person: Person = Person(firstName: "Neeraj", middleName: "Suresh", lastName: "Damle", gender: "Male", birthDate: birthDate!, email: "neeraj.damle@email.com", SSN: 1234567, hobbies: hobbies, workExperience: workExperience);
        
        XCTempAssertNoThrowError
        {
            try kvStore.put("Person-KVStore", value: person);
        }
    }
    
    //Test case to check whether array key and array value can be inserted
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the array insertion operation threw some exception
    func testInsertArraySQLite()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        let key = ["Test array key - SQLite"];
        let value : [AnyObject] = ["One", 2.6, 54, ["Key":"Value"]];
        
        var jsonData : NSData = NSData();
        XCTempAssertNoThrowError
        {
            jsonData = try NSJSONSerialization.dataWithJSONObject(value, options: .PrettyPrinted);
        }
        var json = String(data: jsonData, encoding: NSUTF8StringEncoding);
        if json == nil
        {
            json = "{}";
        }
        
        let keyData : NSData = NSKeyedArchiver.archivedDataWithRootObject(key)
        let kvPair : KVStore_Blob = KVStore_Blob(key: keyData, value: json!, storeName: "Sample store 1");
        
        XCTempAssertNoThrowError
        {
            try self.kvStoreCoordinator?.db?.insertTuple_Blob(kvPair);
        }
    }
    
    //Test case to check whether array key and array value can be inserted
    //This test case uses XCTAssertEqual. So the test case failure indicate that
    //the array insertion operation returned failure status
    func testInsertArrayKVStore()
    {
        let kvStore = KVStoreCreator.createStore(storeName: "Sampe store 1");
        let key = ["Test array key - KVStore"];
        let value : [AnyObject] = [189,"Two", 54.2387, ["Number":189]];
        
        XCTempAssertNoThrowError
        {
            try kvStore.put(key, value: value);
        }
    }

    //Test case to check whether string key and string value can be inserted
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the string insertion operation threw some exception
    func testInsertSingleStringSQLite()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        let key : String = "Test string key - SQLite";
        let value : String = "Test string value";
        
        let dictionary = value.dictionaryRepresentation();
        var jsonData : NSData = NSData();
        XCTempAssertNoThrowError
        {
            jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary!, options: .PrettyPrinted);
        }
        var json = String(data: jsonData, encoding: NSUTF8StringEncoding);
        if json == nil
        {
            json = "{}";
        }
        
        let kvPair: KVStore_Text = KVStore_Text(key: key, value: json!, storeName: "Sample store 2");
        XCTempAssertNoThrowError
        {
            try self.kvStoreCoordinator?.db?.insertTuple_Text(kvPair);
        }
    }
    
    //Test case to check whether string key and string value can be inserted
    //This test case uses XCTAssertEqual. So the test case failure indicate that
    //the string insertion operation returned failure status
    func testInsertSingleStringKVStore()
    {
        let kvStore = KVStoreCreator.createStore(storeName: "Sample store 2");
        
        let key : String = "Test string key - KVStore";
        let value : String = "Test string value";
        
        XCTempAssertNoThrowError
        {
            try kvStore.put(key, value: value);
        }
    }
    
    //Test case to check whether int key and double value can be inserted
    //This test case uses XCTempAssertNoThrowError. So the test case failure indicate that
    //the number insertion operation threw some exception
    func testInsertSingleNumberSQLite()
    {
        kvStoreCoordinator = NDSQLiteKVStoreCoordinator.sharedInstance;
        let key : Int32 = 765897;
        let value : Double = 786.8654;
        
        let dictionary = value.dictionaryRepresentation();
        var jsonData : NSData = NSData();
        XCTempAssertNoThrowError
        {
            jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary!, options: .PrettyPrinted);
        }
        var json = String(data: jsonData, encoding: NSUTF8StringEncoding);
        if json == nil
        {
            json = "{}";
        }
        
        let kvPair: KVStore_Integer = KVStore_Integer(key: key, value: json!, storeName: "Sample store 3");
        XCTempAssertNoThrowError
        {
            try self.kvStoreCoordinator?.db?.insertTuple_Integer(kvPair);
        }
    }
    
    //Test case to check whether double key and int value can be inserted
    //This test case uses XCTAssertEqual. So the test case failure indicate that
    //the number insertion operation returned failure status
    func testInsertSingleNumberKVStore()
    {
        let kvStore = KVStoreCreator.createStore(storeName: "Sample store 3");
        
        let key : Double = 12.4536;
        let value : Int32 = 342;
        
        XCTempAssertNoThrowError
        {
            try kvStore.put(key, value: NSNumber(int:value));
        }
    }
    
    //Test case to check whether all tuples can be fetched
    //This test case uses XCTAssertNotNil. So the test case failure indicate that
    //the tuple fetch operation returned nil
    func testFetchAllTuplesKVStore()
    {
        let kvStore = KVStoreCreator.createStore(storeName: "Sample store");
        
        //Print all the tuple from DB
        kvStore.printAllTuples();
        
        XCTAssert(true);
    }
    
    //Test case to check deletion of all the tuples
    //This test case uses XCTAssertEqual. So the test case failure indicate that
    //the tuple deletion operation returned failure status
    func testDeleteAllTuplesKVStore()
    {
        let kvStore = KVStoreCreator.createStore(storeName: "Sample store");
        
        //Delete all the tuple from DB
        let status = kvStore.deleteAllTuples();
        XCTAssertEqual(status, NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS);
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
