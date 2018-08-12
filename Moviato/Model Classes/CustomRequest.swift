//
//  CustomRequest.swift
//  HblMobile_newDesign
//
//  Created by Adil Abbas on 3/12/18.
//  Copyright © 2018 Nargis Hameed. All rights reserved.
//

import Foundation
import UIKit

public class CustomRequest: NSObject, Codable {
    
    public var header:RequestHeader?
    public var body:RequestBody?
    
    public override init() {
        header = RequestHeader()
        body = RequestBody()
    }
}
