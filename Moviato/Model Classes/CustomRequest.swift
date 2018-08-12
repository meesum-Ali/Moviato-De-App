//
//  CustomRequest.swift
//  HblMobile_newDesign
//
//  Created by Adil Abbas on 3/12/18.
//  Copyright © 2018 Nargis Hameed. All rights reserved.
//

import Foundation
import UIKit

class CustomRequest: NSObject, Codable {
    
     var api_key:String? = kApiKey
     var query:String?
     var page:String?
    
     override init() {
        query = ""
        page = ""
    }
}
