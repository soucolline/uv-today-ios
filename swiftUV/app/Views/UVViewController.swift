//
//  MainViewController.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import ZLogger
import Resolver

class UVViewController: UIViewController {
  
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var indexLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var refreshBtn: UIImageView!
  
  private let presenter = Resolver.resolve(UVPresenter.self)
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.registerNotifications()
    self.setupUI()
    
    // Enable refesh on btn
    let tap = UITapGestureRecognizer(target: self, action: #selector(refresh))
    self.refreshBtn.addGestureRecognizer(tap)
    
    self.presenter.setView(view: self)
    self.presenter.searchLocation()
  }
  
  private func registerNotifications() {
    // Update location when app return from background
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appReturnedFromBackground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  
  func setupUI() {
    // Add default backgroundColor
    self.view.backgroundColor = Index(0).associatedColor
    // Show default values
    self.cityLabel.text = "app.label.city".localized + " : -"
    self.indexLabel.text = "-"
    self.descriptionTextView.text = ""
  }
  
  @objc func appReturnedFromBackground() {
    self.presenter.searchLocation()
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

extension  UVViewController: UVViewDelegate {
  
  func onShowLoader() {
    DispatchQueue.main.async {
      SVProgressHUD.show(withStatus: "app.message.downloading".localized)
    }
  }
  
  func onDismissLoader() {
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  func onUpdateLocationWithSuccess(with cityName: String) {
    self.cityLabel.text = "\("app.label.city".localized) : \(cityName)"
    ZLogger.info(message: "Did receive location")
  }
  
  func onUpdateLocationWithError() {
    DispatchQueue.main.async {
      self.present(PopupManager.errorPopup(message: "app.error.couldNotLocalise".localized), animated: true)
      self.descriptionTextView.text = Index(-1).associatedDescription
    }
  }
  
  func onReceiveSuccess(index: Int) {
    DispatchQueue.main.async {
      self.indexLabel.text = String(index)
      self.descriptionTextView.text = index.associatedDescription
      UIView.animate(withDuration: 1.0, animations: {
        self.view.backgroundColor = index.associatedColor
      })
    }
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
      self.present(PopupManager.errorPopup(message: "app.error.localisationDisabled".localized), animated: true)
    }
  }
  
}
