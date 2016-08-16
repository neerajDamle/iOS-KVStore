//
//  ViewController.swift
//  KVStore
//
//  Created by Neeraj Damle on 5/30/16.
//  Copyright © 2016 NDamle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NDKVStoreOperationStatusProtocol
{
    let kvStore1 = KVStoreCreator.createStore(storeName: "Store 1");
    let kvStore2 = KVStoreCreator.createStore(storeName: "Store 2");
    let kvStore3 = KVStoreCreator.createStore(storeName: "Store 3");
    let kvStore4 = KVStoreCreator.createStore(storeName: "Store 4");
    
    let kvStore = KVStoreCreator.createStore(KVStoreImplementation.SQLite, storeName: "Store 1");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kvStore1.delegate = self;
        kvStore2.delegate = self;
        kvStore3.delegate = self;
        kvStore4.delegate = self;
        
        //Use this method to check thread safety of the KVStore
        self.checkThreadSafetyOfKvStore();
        
        /*
         Use this method to insert tuples for
         - Person object
         - Dictionary with random key-value pairs
         - Array having any object
         - Single string
         - Single number
         */
//        self.insertRecordsForAllSupportedTypes();
        
        //Use this method to print all the tuples from KVStore
//        self.printAllTuples();
        
        //Use this methods to delete tuple from NDKVStore based on key
//        let retVal = kvStore3.deleteTuple(key: NSNumber(double: 5678.2365));
//        if retVal == NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS
//        {
//            print("Deleted tuple successfully");
//        }
//        else
//        {
//            print("Failed to delete tuple");
//        }
        
        //Use this method to delete all tuple from NDKVStore
//        let retVal = kvStore1.deleteAllTuple();
//        if retVal == NDKVStoreConstants.MethodReturnValues.STATUS_SUCCESS
//        {
//            print("Deleted all tuples successfully");
//        }
//        else
//        {
//            print("Failed to delete all tuples");
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Thread safety
    /**
     This methods inserts records in KVStore on two separate threads concurrently
     */
    func checkThreadSafetyOfKvStore()
    {
        let range1 = 1...20;
        let range2 = 31...50;
        
        let delay1 = 1.0 * Double(NSEC_PER_SEC)
        let time1 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay1))
        dispatch_after(time1, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.insertMultipleRecords(range1);
        })
        
        let delay2 = 1.0 * Double(NSEC_PER_SEC)
        let time2 = dispatch_time(DISPATCH_TIME_NOW, Int64(delay2))
        dispatch_after(time2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.insertMultipleRecords(range2);
        })
    }
    
    //MARK: Insert tuples for supported types
    func insertRecordsForAllSupportedTypes()
    {
        do
        {
            let keyInt = 6567;
            let keyDouble = 5678.2365;
            let keyString = "String Key";
            let keyArray = ["Key1","Key2",267.8];
            let keyDictionary = ["Red":234, "Green":168, "Blue":45];
            
            let valueInt = 14356;
            let valueDouble = 376.3897;
            let valueString = "This is string";
            let valueArray: [Int] = [23, 876];
            
            try kvStore1.put(keyString, value: valueString);
            try kvStore1.put(keyDictionary, value: valueArray);
            
            try kvStore2.put(keyArray, value: valueArray);
            
            //Insert Person object
            let calender = NSCalendar.currentCalendar();
            let components = NSDateComponents();
            components.day = 1;
            components.month = 11;
            components.year = 1989;
            let birthDate = calender.dateFromComponents(components);
            
            let hobbies: [String] = ["Hiking","Photography","Bird watching", "Reading"];
            
            let workExperience : [String:Float] = ["Symantec":1.5, "Spring CT":3];
            
            let person: Person = Person(firstName: "Neeraj", middleName: "Suresh", lastName: "Damle", gender: "Male", birthDate: birthDate!, email: "neeraj.damle@springcomputing.in", SSN: 1234567, hobbies: hobbies, workExperience: workExperience);
            let personKey = ["Person":"Neeraj"];
            
            try kvStore2.put(personKey, value: person);
            
            try kvStore3.put(keyDouble, value: valueInt);
            try kvStore3.put(keyInt, value: valueDouble);
            
            var returnTuple = kvStore1.get(keyString);
            kvStore1.printTuple(key: keyString);
            
            returnTuple = kvStore1.get(keyDictionary);
            kvStore1.printTuple(key: keyDictionary);
            
            returnTuple = kvStore2.get(keyArray);
            kvStore2.printTuple(key: keyArray);
            
            returnTuple = kvStore2.get(personKey);
            kvStore2.printTuple(key: personKey);
            
            returnTuple = kvStore3.get(keyInt);
            kvStore3.printTuple(key: keyInt);
            
            returnTuple = kvStore3.get(keyDouble);
            kvStore3.printTuple(key: keyDouble);
        }
        catch NDKVStoreError.DictionaryConversionFailed(let message)
        {
            print(message);
        }
        catch let error as NSError
        {
            print("Error: \(error.localizedDescription)");
        }
    }
    
    func insertMultipleRecords(range: Range<Int>)
    {
        do
        {
            for index in range
            {
                let key : String = String(index);
                try kvStore4.put(key, value: NSNumber(long: index));
            }
        }
        catch NDKVStoreError.DictionaryConversionFailed(let message)
        {
            print(message);
        }
        catch let error as NSError
        {
            print("Error: \(error.localizedDescription)");
        }
    }
    
    //MARK: Print one or all the tuples
    func printAllTuples()
    {
        kvStore1.printAllTuples();
        kvStore2.printAllTuples();
        kvStore3.printAllTuples();
    }
    
    //MARK: NDKVSToreProtocol methods
    func didStoreTuple(kvStore: NDKVStore)
    {
        print("Tuple stored successfully in Store \"\(kvStore.storeName)\"");
    }
    
    func failToStoreTuple(kvStore: NDKVStore)
    {
        print("Failed to store tuple in Store \"\(kvStore.storeName)\"");
    }
}

