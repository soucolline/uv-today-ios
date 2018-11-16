//
//  MainViewController.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD
import ZLogger

class UVViewController: UIViewController {
  
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var indexLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var refreshBtn: UIImageView!
  
  lazy var presenter: UVPresenter = {
    return UVPresenterImpl(
      with: self,
      locationService: LocationService(with: CLLocationManager()),
      uvService: UVService()
    )
  }()
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  //let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Update location when app return from background
    NotificationCenter.default.addObserver(self, selector: #selector(appReturnedFromBackground), name:
      UIApplication.willEnterForegroundNotification, object: nil)
    
    // Add default backgroundColor
    self.view.backgroundColor = UIColor.colorFromInteger(color: UIColor.colorFromIndex(index: 0))
    // Show default values
    self.cityLabel.text = "Ville".localized + " : -"
    self.indexLabel.text = "-"
    self.descriptionTextView.text = ""
    
    // Enable refesh on btn
    let tap = UITapGestureRecognizer(target: self, action: #selector(refresh))
    self.refreshBtn.addGestureRecognizer(tap)
    
    //self.searchLocation()
    
    self.presenter.searchLocation()
  }
  
  @objc func appReturnedFromBackground() {
    self.presenter.searchLocation()
  }
  
  func getDescription(index: Int) -> String {
    switch index {
    case 0, 1, 2:
      return K.i18n.lowUV.localized
    case 3, 4, 5:
      return K.i18n.middleUV.localized
    case 6, 7:
      return K.i18n.highUV.localized
    case 8, 9, 10:
      return K.i18n.veryHighUV.localized
    case 11, 12, 13, 14:
      return K.i18n.extremeUV.localized
    default:
      return K.i18n.error.localized
    }
  }
  
  @objc func refresh() {
    self.presenter.searchLocation()
    UIView.animate(withDuration: 0.5, animations: { () -> Void in
      self.refreshBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    })
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { () -> Void in
      self.refreshBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
    }, completion: nil)
  }
  
}

/*extension UVViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let latitude = manager.location?.coordinate.latitude,
      let longitude = manager.location?.coordinate.longitude else {
        return
    }
    
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, _ in
      if let placemarkArray = placemarks, let placemark = placemarkArray.first {
        self.cityLabel.text = "Ville".localized + " : \(placemark.locality ?? "Inconnue".localized)"
      } else {
        self.cityLabel.text = "Inconnue".localized
      }
    })
    ZLogger.log(message: "location = \(location)", event: .info)
    ZLogger.log(message: Api.UVFromLocation(latitude, longitude).url, event: .info)
    
    Alamofire.request(Api.UVFromLocation(latitude, longitude).url).validate().responseJSON { apiResponse in
      switch apiResponse.result {
        case .success:
          let jsonResponse = JSON(apiResponse.value as Any)
          let uvIndex = jsonResponse["currently"]["uvIndex"].intValue
          self.indexLabel.text = "\(uvIndex)"
          UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = UIColor.colorFromInteger(color: UIColor.colorFromIndex(index: uvIndex))
          })
          self.descriptionTextView.text = self.getDescription(index: uvIndex)
          SVProgressHUD.dismiss()
        case .failure:
          SVProgressHUD.dismiss()
          self.present(PopupManager.errorPopup(message: "Une erreur est survenue, veuillez relancer l'application".localized), animated: true)
          self.descriptionTextView.text = self.getDescription(index: -1)
          ZLogger.log(message: apiResponse.error?.localizedDescription ?? "", event: .error)
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.present(PopupManager.errorPopup(message: "Impossible de vous localiser".localized), animated: true)
    self.descriptionTextView.text = self.getDescription(index: -1)
    SVProgressHUD.dismiss()
    ZLogger.log(message: error.localizedDescription, event: .error)
  }
}*/

extension  UVViewController: UVViewDelegate {
  
  func onShowLoader() {
    
  }
  
  func onShowLoaderForLocationSearch() {
    DispatchQueue.main.async {
      SVProgressHUD.show(withStatus: "Téléchargement des données en cours".localized)
    }
  }
  
  func onDismissLoader() {
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  func onUpdateLocationWithSuccess(with cityName: String) {
    self.cityLabel.text = "\("Ville".localized) : \(cityName.localized)"
    self.presenter.getUVIndex()
    ZLogger.log(message: "Did receive location", event: .info)
  }
  
  func onUpdateLocationWithError() {
    DispatchQueue.main.async {
      self.present(PopupManager.errorPopup(message: "Impossible de vous localiser".localized), animated: true)
      self.descriptionTextView.text = self.getDescription(index: -1)
    }
  }
  
  func onReceiveSuccess(index: Int) {
    self.indexLabel.text = String(index)
  }
  
  func onShowError(message: String) {
    DispatchQueue.main.async {
      self.present(PopupManager.errorPopup(message: message), animated: true)
    }
  }
  
  func onAcceptLocation() {
    self.presenter.searchLocation()
  }
  
  func onShowRefusedLocation() {
    DispatchQueue.main.async {
      self.present(PopupManager.errorPopup(message: "Vous avez désactivé la location".localized), animated: true)
    }
  }
  
}
