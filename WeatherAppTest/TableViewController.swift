//
//  TableViewController.swift
//  WeatherAppTest
//
//  Created by Stepan Chegrenev on 22.03.2018.
//  Copyright © 2018 Stepan Chegrenev. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var latitude: String?
    var longitude: String?
    var apiHelper: ApiHelper!
    var coreDataHelper = CoreDataHelper()
    var locationHelper: LocationHelper!
    var arrayOfPlaces: [Place]?
    var arrayForUpdateData: [String]!
  
    @IBAction func addPlaceAction(_ sender: UIBarButtonItem) {
        
        let currentCoordinates = locationHelper.latitude! + "," + locationHelper.longitude!
        
        self.performSegue(withIdentifier: "ViewControllerSegue", sender: currentCoordinates)
        
    }
    @IBAction func refreshDataAction(_ sender: UIBarButtonItem) {
        arrayForUpdateData = []
        
        for item in arrayOfPlaces! {
            arrayForUpdateData?.append(item.cityName!)
        }
        
        apiHelper.updateData(array: arrayForUpdateData)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TableViewController.reloadTable), name: Notification.Name(rawValue: "DataUpdated"), object: nil)
        
    }
    
    @objc func reloadTable() {
        arrayOfPlaces = coreDataHelper.getData()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiHelper = ApiHelper()
        locationHelper = LocationHelper()
        locationHelper.getCurrentLocation()
        arrayOfPlaces = []
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        arrayOfPlaces = coreDataHelper.getData()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (arrayOfPlaces?.count)!
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ViewControllerSegue"
        {
            let destViewController = segue.destination as! ViewController
            
            destViewController.currentCoordinates = sender as? String
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = arrayOfPlaces![indexPath.row].cityName!
        cell.detailTextLabel?.text = arrayOfPlaces![indexPath.row].weatherStateName! + " | " + arrayOfPlaces![indexPath.row].temp! + "°"
        
        let urlString = "https://www.metaweather.com/static/img/weather/png/64/" + arrayOfPlaces![indexPath.row].weatherStateAbbr! + ".png"
        
        if let url = NSURL(string: urlString) {
            if let data = NSData(contentsOf: url as URL) {
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.image = UIImage(data: data as Data)
            }
        }
        return cell
    }
}
