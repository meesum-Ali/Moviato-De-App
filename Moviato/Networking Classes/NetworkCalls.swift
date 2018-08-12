//
//  HBLHandShake.swift
//  Konnect App
//
//  Created by Muhammad Talha Ashfaque on 12/13/17.
//  Copyright © 2017 Muhammad Talha Ashfaque. All rights reserved.
//

import Foundation
import UIKit

// MARK:- Common call
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
    
    NetworkManager.shared().sendrequest(body: requestData!,
                                        vc: VC,
                                        shouldShowAlert: shouldShowAlert) { (resp, isSuccess) in
                                            
                                            progV.removeFromSuperview()
                                            
                                            completionHandler(resp, isSuccess)
    }
    
}

fileprivate func toJson(data: AnyObject) -> String? {
    var jsonData : NSData? = nil
    var result: String? = nil
    
    do {
        jsonData = try JSONSerialization.data(withJSONObject: data, options: []) as NSData
    } catch {
        return nil
    }
    if jsonData != nil {
        result = NSString(data: jsonData! as Data, encoding:String.Encoding.utf8.rawValue) as String?
    }
    
    
    return result
    
}

