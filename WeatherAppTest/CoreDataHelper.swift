//
//  CoreDataHelper.swift
//  WeatherAppTest
//
//  Created by Stepan Chegrenev on 25.03.2018.
//  Copyright © 2018 Stepan Chegrenev. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper {
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext!
    var postRequest: NSFetchRequest<NSFetchRequestResult>!
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        postRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
    }
    
    func saveData(cityName: String, woeid: String, temp: String, weatherStateName: String, weatherStateAbbr: String) {
        
        let newPlace = Place(context: context)
        newPlace.cityName = cityName
        newPlace.woeid = woeid
        newPlace.temp = temp
        newPlace.weatherStateAbbr = weatherStateAbbr
        newPlace.weatherStateName = weatherStateName
        
        do
        {
            try context.save()
            print("Data saving")
        }
        catch
        {
            //PROCESS ERROR
            print("Failed saving")
        }
    }
    
    func getData() -> [Place] {
        postRequest.returnsObjectsAsFaults = false
        var arrayOfPlaces = [Place]()
        do
        {
            let results = try context.fetch(postRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    let place = result as! Place
                    
                    arrayOfPlaces.append(place)
                }
            }
        }
        catch
        {
            // PROCESS ERROR
        }
        return arrayOfPlaces
    }
    
    func deleteData(cityName: String) {
        postRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(postRequest)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    
                    let place = result as! Place
                    
                    if place.cityName! == cityName {
                        context.delete(result)
                    }
                }
            }
        }
        catch
        {
            // PROCESS ERROR
        }
        
    }
}
