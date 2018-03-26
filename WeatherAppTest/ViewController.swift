//
//  ViewController.swift
//  WeatherAppTest
//
//  Created by Stepan Chegrenev on 24.03.2018.
//  Copyright © 2018 Stepan Chegrenev. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var currentCoordinates: String?
    var apiHelper: ApiHelper!
    var coreDataHelper: CoreDataHelper!
    var arrayOfPlaces: [Place]?
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func addPlaceAction(_ sender: UIButton) {
        
        if !(textField.text?.isEmpty)! {
            let string = changeString(string: textField.text!)
            apiHelper.updateData(array: [string])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiHelper = ApiHelper()
        let params = ["lattlong":currentCoordinates!]

        apiHelper.getOrPostRequest(method: .get, urlString: apiHelper.url, apiMethod: .locationSearch, params: params)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.cityNotFound), name: Notification.Name(rawValue: "CityNotFound"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.cityFound), name: Notification.Name(rawValue: "CityFound"), object: nil)
        
        infoLabel.text = "Text"
    }

    @objc func cityNotFound() {
        DispatchQueue.main.async {
            self.infoLabel.text = "City Not Found"
        }
    }
    
    @objc func cityFound() {
        DispatchQueue.main.async {
            self.infoLabel.text = self.apiHelper.cityName! + "  :  " + self.apiHelper.temp! + "°"
        }
    }
    
    func changeString(string: String) -> String {
        var returnString = ""
        var arr1 = [String]()
        var replaceArr = [Int]()
        var deleteArr = [Int]()
        
        var counter = 0
        var spcCounter = 0
        var smblCounter = 0
        
        for chr in string {
            if chr == " " {
                
                spcCounter += 1
                
                if !((spcCounter > 1) || (counter == string.count - 1) || (smblCounter == 0)) {
                    replaceArr.append(counter)
                    
                } else {
                    deleteArr.append(counter)
                }
                
            } else {
                smblCounter += 1
                spcCounter = 0
            }
            counter += 1
            arr1.append(String(chr))
        }
        
        for elem in replaceArr {
            arr1[elem] = "%20"
        }
        
        for elem in deleteArr.reversed() {
            arr1.remove(at: elem)
        }

        for elem in arr1 {
            returnString += elem
        }
        return returnString
    }
}
