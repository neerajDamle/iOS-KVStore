//
//  Person.swift
//  KVStore
//
//  Created by Neeraj Damle on 5/31/16.
//  Copyright © 2016 NDamle. All rights reserved.
//

//This is a sample class for checking object insertion in KVStore

import Foundation

class Person : NDKVStorable
{
    let firstName: String;
    let middleName: String?;
    let lastName: String;
    
    let gender: String;
    let birthDate: NSDate;
    
    let email: String;
    let SSN: Int32;
    
    let hobbies: [String]?;
    
    let workExperience : [String:Float]?;
    
    init(firstName: String, middleName: String?, lastName: String, gender: String, birthDate: NSDate, email:String, SSN: Int32, hobbies: [String]?, workExperience: [String:Float]?)
    {
        self.firstName = firstName;
        self.middleName = middleName;
        self.lastName = lastName;
        
        self.gender = gender;
        self.birthDate = birthDate;
        
        self.email = email;
        self.SSN = SSN;
        
        self.hobbies = hobbies;
        
        self.workExperience = workExperience;
    }
    
    func dictionaryRepresentation() -> [String : AnyObject]?
    {
        var dictionary = [String:AnyObject]();
        
        dictionary["First Name"] = self.firstName;
        if self.middleName != nil
        {
            dictionary["Middle Name"] = self.middleName;
        }
        dictionary["Last Name"] = self.lastName;
        
        dictionary["Gender"] = self.gender;
        
        //Format birthdate using Short style
        let formatter: NSDateFormatter = NSDateFormatter();
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle;
        let dateString = formatter.stringFromDate(self.birthDate);
        dictionary["Birth Date"] = dateString;
        
        dictionary["Email"] = self.email;
        dictionary["SSN"] = NSNumber(int:self.SSN);
        
        dictionary["Hobbies"] = self.hobbies;
        
        dictionary["Work Experience"] = self.workExperience;
        
        return dictionary;
    }
}