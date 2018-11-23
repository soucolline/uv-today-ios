//
//  PopupManager.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 16/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import PopupDialog

class PopupManager {
  
  static func errorPopup(message: String) -> PopupDialog {
    let title = "app.label.error".localized
    let popup = PopupDialog(title: title, message: message, image: nil, buttonAlignment: .vertical, transitionStyle: .zoomIn)
    let okButton = DefaultButton(title: "Ok", dismissOnTap: true, action: nil)
    popup.addButton(okButton)
    
    return popup
  }
  
}