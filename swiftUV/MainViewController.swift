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
import MBProgressHUD

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
    self.view.backgroundColor = UIColor.colorFromInteger(color: UIColor.colorFromIndex(index: 0))
    // Put all texts in white + reset value
    self.cityLabel.textColor = UIColor.white
    self.cityLabel.text = "Ville".localized + " : -"
    self.indexLabel.textColor = UIColor.white
    self.indexLabel.text = "-"
    self.descriptionTextView.textColor = UIColor.white
    self.descriptionTextView.text = ""
    
    // Search for location
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.requestAlwaysAuthorization()
      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
      let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
      loader.label.text = "Téléchargement des données en cours".localized
      self.locationManager.requestLocation()
    } else {
      self.present(PopupManager.errorPopup(message: "Vous avez désactivé la location".localized), animated: true)
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
      return "Port de lunettes de soleil en cas de journées ensoleillées.".localized
    case 3, 4, 5:
      return "Se couvrir et porter un chapeau et des lunettes de soleil. Appliquer un écran solaire de protection moyenne (indice de protection de 15 à 29), surtout pour une exposition à l’extérieur pendant plus de trente minutes. Rechercher l’ombre aux alentours de midi, quand le soleil est au zénith.".localized
    case 6, 7:
      return "Réduire l’exposition entre 11 h et 16 h. Appliquer un écran solaire de haute protection (indice de 30 à 50), porter un chapeau et des lunettes de soleil, et se placer à l’ombre.Réduire l’exposition entre 11 h et 16 h. Appliquer un écran solaire de haute protection (indice de 30 à 50), porter un chapeau et des lunettes de soleil, et se placer à l’ombre.".localized
    case 8, 9, 10:
      return "Sans protection, la peau sera endommagée et peut brûler. L’exposition au soleil peut être dangereuse entre 11 h et 16 h ; la recherche de l’ombre est donc importante. Sont recommandables le port de vêtements longs, d'un chapeau et de lunettes de soleil, ainsi que l'application d'un écran solaire de très haute protection (indice + 50).".localized
    case 11:
      return "La peau non protégée sera endommagée et peut brûler en quelques minutes. Toute exposition au soleil est dangereuse, et en cas de sortie il faut se couvrir absolument (chapeau, lunettes de soleil, application d'un écran solaire de très haute protection d'indice + 50).".localized
    default:
      return "Une erreur est survenue, veuillez relancer l'application".localized
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
        self.cityLabel.text = "Ville".localized + " : \(placemark.locality ?? "Inconnue".localized)"
      } else {
        self.cityLabel.text = "Inconnue".localized
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
      MBProgressHUD.hide(for: self.view, animated: true)
      self.present(PopupManager.errorPopup(message: "Une erreur est survenue, veuillez relancer l'application".localized), animated: true)
      self.descriptionTextView.text = self.getDescription(index: -1)
      print("ERROR ==> \(apiResponse.error?.localizedDescription)")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.present(PopupManager.errorPopup(message: "Impossible de vous localiser".localized), animated: true)
    self.descriptionTextView.text = self.getDescription(index: -1)
    MBProgressHUD.hide(for: self.view, animated: true)
    print("Error ==> \(error.localizedDescription)")
  }
}
