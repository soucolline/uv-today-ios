//
//  PopupManager.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 16/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation
import PopupDialog

class PopupManager {
  static func errorPopup(message: String) -> PopupDialog {
    let title = "Erreur".localized
    let popup = PopupDialog(title: title, message: message, image: nil, transitionStyle: .zoomIn, gestureDismissal: true)
    let okButton = DefaultButton(title: "Ok", dismissOnTap: true, action: nil)
    popup.addButton(okButton)
    
    return popup
  }
}
