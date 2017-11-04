//
//  swiftUVTests.swift
//  swiftUVTests
//
//  Created by Zlatan on 04/11/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Quick
import Nimble

@testable import swiftUV

class MainViewControllerTests: QuickSpec {
  
  let vc = MainViewController()
  
  override func spec() {
    describe("Swift UV main") {
      
      it("should return good description with UV") {
        var description: String
        
        description = self.vc.getDescription(index: 0)
        expect(description).to(be(K.i18n.lowUV.localized as String))
        
        description = self.vc.getDescription(index: 3)
        expect(description).to(be(K.i18n.middleUV.localized as String))
        
        description = self.vc.getDescription(index: 6)
        expect(description).to(be(K.i18n.highUV.localized as String))
        
        description = self.vc.getDescription(index: 9)
        expect(description).to(be(K.i18n.veryHighUV.localized as String))
        
        description = self.vc.getDescription(index: 11)
        expect(description).to(be(K.i18n.extremeUV.localized as String))
      }
    }
  }
    
}
