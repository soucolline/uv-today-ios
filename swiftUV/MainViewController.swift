//
//  MainViewController.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var indexLabel: UILabel!
  @IBOutlet weak var descriptionTextView: UITextView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Add default backgroundColor
    self.view.backgroundColor = UIColor.colorFromInteger(color: UIColor.colorFromIndex(index: 2))
    // Put all texts in white
    self.cityLabel.textColor = UIColor.white
    self.indexLabel.textColor = UIColor.white
    self.descriptionTextView.textColor = UIColor.white
  }
  
}
