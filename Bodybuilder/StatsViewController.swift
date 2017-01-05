//
//  ViewController.swift
//  Bodybuilder
//
//  Created by Mateusz Oracz on 15.12.2016.
//  Copyright © 2016 BatoregoTeam. All rights reserved.
//

import UIKit
import CoreLocation

class StatsViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    @IBOutlet var gpsX: UILabel!
    @IBOutlet var gpsY: UILabel!
    
    func getNerbyGyms(latitude: Double, longitude: Double) {
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=500&type=gym&keyword=silownia&key=AIzaSyDJo8nIHl3JbPGLmpyZbMA7PkQMZj_AeUw")
        
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let posts = json["results"] as? [[String: Any]] ?? []
                var gymsArray: [Gym] = []
                for gym in posts {
                    gymsArray.append(
                        Gym(
                            nam: gym["name"] as! String,
                            add: gym["vicinity"] as! String,
                            lat: ((gym["geometry"] as! Dictionary<String, Any>)["location"] as! Dictionary<String, Double>)["lat"] as! Double!,
                            long: ((gym["geometry"] as! Dictionary<String, Any>)["location"] as! Dictionary<String, Double>)["lng"] as! Double!
                        )
                    )
                    
                }
                gymList.setGyms(lGym: gymsArray)
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getGymsButton(_ sender: AnyObject) {
        getNerbyGyms(latitude: 52.4388894, longitude: 16.9184323)
        print("gymList", gymList.getGyms())
    }
    
    var location: CLLocation! {
        didSet {
            gpsX.text = String(location.coordinate.latitude)
            gpsY.text = String(location.coordinate.longitude)
        }
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("UNAUTHORIZED GPS LOCALIZATION")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
        
    }
    
    @IBAction func gpsUpdate(_ sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
    
    
}
