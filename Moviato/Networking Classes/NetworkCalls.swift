//
//  HBLHandShake.swift
//  Konnect App
//
//  Created by Muhammad Talha Ashfaque on 12/13/17.
//  Copyright © 2017 Muhammad Talha Ashfaque. All rights reserved.
//

import Foundation
import UIKit
/// all network calls are defined here and from here calling a centralized singleton network request defined in wrapper created on alamofire.

// MARK:- Common call
///takes request object, VC from where its called, if alert msg is to be shown, progress if to be shown and returs success status with response object in completion callback
func networkCall(_ reqObj: CustomRequest,
                             _ VC: UIViewController,
                             _ shouldShowAlert: Bool?,
                             _ shouldShowProgress: Bool? = true,
                             _ completionHandler: @escaping (CustomResponse?, Bool) -> Void) {
    
    var requestData: [String: AnyObject]?
    guard let body = getSerializeDictionary(request: reqObj) else {
        return
    }
    
    let progV = RequestProgressIndicatiorView(frame: UIScreen.main.bounds)
    
    if shouldShowProgress! {
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(progV);
        
    }
    
    requestData = body as [String : AnyObject]
    //calling network manager's method (network manager is a custom small wrapper on alamofire)
    NetworkManager.shared().sendrequest(body: requestData!,
                                        vc: VC,
                                        shouldShowAlert: shouldShowAlert) { (resp, isSuccess) in
                                            
                                            progV.removeFromSuperview()
                                            
                                            completionHandler(resp, isSuccess)
    }
    
}


