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
    let location = manager.location?.coordinate
    print("location = \(location)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error ==> \(error.localizedDescription)")
  }
}
