//
//  MainViewController.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import UIKit
import CoreLocation
import Just
import SwiftyJSON

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
  
  func getDescription(index: Int) -> String {
    switch index {
    case 1, 2:
      return "Port de lunettes de soleil en cas de journées ensoleillées."
    case 3, 4, 5:
      return "Se couvrir et porter un chapeau et des lunettes de soleil. Appliquer un écran solaire de protection moyenne (indice de protection de 15 à 29), surtout pour une exposition à l’extérieur pendant plus de trente minutes. Rechercher l’ombre aux alentours de midi, quand le soleil est au zénith."
    case 6, 7:
      return "Réduire l’exposition entre 11 h et 16 h. Appliquer un écran solaire de haute protection (indice de 30 à 50), porter un chapeau et des lunettes de soleil, et se placer à l’ombre.Réduire l’exposition entre 11 h et 16 h. Appliquer un écran solaire de haute protection (indice de 30 à 50), porter un chapeau et des lunettes de soleil, et se placer à l’ombre."
    case 8, 9, 10:
      return "Sans protection, la peau sera endommagée et peut brûler. L’exposition au soleil peut être dangereuse entre 11 h et 16 h ; la recherche de l’ombre est donc importante. Sont recommandables le port de vêtements longs, d'un chapeau et de lunettes de soleil, ainsi que l'application d'un écran solaire de très haute protection (indice + 50)."
    case 11:
      return "La peau non protégée sera endommagée et peut brûler en quelques minutes. Toute exposition au soleil est dangereuse, et en cas de sortie il faut se couvrir absolument (chapeau, lunettes de soleil, application d'un écran solaire de très haute protection d'indice + 50)."
    default:
      return "Un problème est survenue, veuillez relancer l'application"
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
    
    let apiResponse = Just.get(Api.UVFromLocation(latitude, longitude).url)
    if apiResponse.ok { 
      let jsonResponse = JSON(apiResponse.json as Any)
      let uvIndex = jsonResponse["response"].first?.1["periods"].first?.1["uvi"].intValue ?? 0
      self.indexLabel.text = "\(uvIndex)"
      UIView.animate(withDuration: 1.0, animations: {
        self.view.backgroundColor = UIColor.colorFromInteger(color: UIColor.colorFromIndex(index: uvIndex))
      })
      self.descriptionTextView.text = self.getDescription(index: uvIndex)
      MBProgressHUD.hide(for: self.view, animated: true)
    } else {
      print("not ok")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error ==> \(error.localizedDescription)")
  }
}
