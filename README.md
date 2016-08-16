# README #

* Quick summary:
  This is a library that can be used as a KVStore for iOS platform
  Underlying it can use SQLite, NSUserDefaults or any other persistent store.
  The application need not interact with the underlying storage mechanism directly.

* Version: 1.0

* Requirements:
   iOS 8.0+
   Swift 2.2.1
   Xcode 7.3+
   
* Installation
	Manual
	- Add "iOS-KVStore" directory inside the "Library" directory into your project hierarchy
	
* Usage
	1. Create SQLite based KVStore
		let kvStore = KVStoreCreator.createStore(KVStoreImplementation.SQLite, storeName: "SQLite KVStore");
		
	2. Set delegate for NDKVStoreOperationStatusProtocol to self to receive success/failure callbacks
		kvStore.delegate = self;
		
	3. Insert Key-Value pairs
	   - Insert Key-Value pair int key and double value
	     do
	     {
	    	try kvStore.put(14352, value: 376.3897);
	     }
	     catch NDKVStoreError.DictionaryConversionFailed(let message)
             {
                print(message);
             }
             catch let error as NSError
             {
                print("Error: \(error.localizedDescription)");
             }
	  Similarly you can insert a combination of any key-value including your own classes provided those classes confirm to NDKVStorable protocol
		
* Writing tests: Unit test cases have been added to test following cases
  - Database existence
  - Open database
  - Table creation
  - JSON serialization
  - Insert object using KVStore interface
  - Insert object using SQLite interface
  - Insert array using KVStore interface
  - Insert array using SQLite interface
  - Insert single string using KVStore interface
  - Insert single string using SQLite interface
  - Insert single number using KVStore interface
  - Insert single number using SQLite interface
  - Fetch all the tuples using KVStore interface
  - Fetch all the tuples using SQLite interface
  - Delete all the tuples using KVStore interface
  - Delete all the tuples using SQLite interface

* Limitations:
  The library can be used with NSUserDefault instead of SQLite as underlying storage. This functionality is yet to be implemented. Just the framework has been created.

* Notes:
   - Transaction support is not added yet.
   - No UI is provided.
   - To check different scenarios, utility methods are provided in ViewController class. Feel free to use those or add new methods of your choice.