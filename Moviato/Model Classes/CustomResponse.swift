//
//  CustomResponse.swift
//  HblMobile_newDesign
//
//  Created by Adil Abbas on 3/12/18.
//  Copyright © 2018 Nargis Hameed. All rights reserved.
//

import Foundation

public class CustomResponse: NSObject, Codable  {
   
    var page : Int?
    var total_results : Int?
    var total_pages : Int?
    var results : [Results]?
    
}
