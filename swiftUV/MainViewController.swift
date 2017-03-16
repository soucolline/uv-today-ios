//
//  MainViewController.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
  
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var indexLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Update location when app return from background
    NotificationCenter.default.addObserver(self, selector:#selector(appReturnedFromBackground), name:
      NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    
    // Add default backgroundColor
    self.view.backgroundColor = UIColor.colorFromInteger(color: UIColor.colorFromIndex(index: 2))
    // Put all texts in white
    self.cityLabel.textColor = UIColor.white
    self.indexLabel.textColor = UIColor.white
    self.descriptionTextView.textColor = UIColor.white
    
    // Search for location
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.requestAlwaysAuthorization()
      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
      self.locationManager.requestLocation()
    }
  }
  
  func appReturnedFromBackground() {
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.requestLocation()
    }
  }
  
}

extension MainViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let latitude = manager.location?.coordinate.latitude,
      let longitude = manager.location?.coordinate.longitude else {
        return
    }
    
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
      if let placemarkArray = placemarks, let placemark = placemarkArray.first {
        self.cityLabel.text = "Ville : \(placemark.locality ?? "Inconnue")"
      } else {
        self.cityLabel.text = "Inconnue"
      }
    })
    print("location = \(location)")
    print(Api.UVFromLocation(latitude, longitude).url)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error ==> \(error.localizedDescription)")
  }
}
