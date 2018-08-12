//
//  CustomResponse.swift
//  HblMobile_newDesign
//
//  Created by Adil Abbas on 3/12/18.
//  Copyright © 2018 Nargis Hameed. All rights reserved.
//

import Foundation

public class CustomResponse: NSObject, Codable  {
    
    var header: ResponseHeader?
    var body: ResponseBody?
    
    public override init() {
        header = ResponseHeader()
        body = ResponseBody()
    }

}
