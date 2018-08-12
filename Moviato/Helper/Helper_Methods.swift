//
//  Helper_Methods.swift
//  Moviato
//
//  Created by Syed Meesum Ali on 12/08/2018.
//  Copyright © 2018 SMeesumAli. All rights reserved.
//

import Foundation
import UIKit

public func showAlert(title:String,msg:String,
                      vc:UIViewController,
                      completionHandler: @escaping () -> Void) -> Void {
    
    let errView = ErrorPopupView(frame: UIScreen.main.bounds)
    errView.errorTxtLbl.text = msg
  
    let window = UIApplication.shared.keyWindow!
    window.addSubview(errView);
    errView.completionCodeBlock = {

        completionHandler()
        
    }
    
}

public func UIColorFromRGB(rgbValue: UInt, alphaValue: Float? = 1.0) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alphaValue!)
    )
}


func getSerializeDictionary(request: CustomRequest) -> [String:Any]? {
    
    let jsonEnc = JSONEncoder()
    
    do{
        let jsonData = try jsonEnc.encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString!)
        
        do{
            let body = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String:Any]
            return body
        }
        catch{
            return nil
        }
    }
    catch{
        return nil
    }
}

func getDeSerializeObj(responseData: Any) -> CustomResponse? {
    
    do{
        
        let data = try JSONSerialization.data(withJSONObject: responseData, options: [])
        
        let decoder = JSONDecoder()
        
        do {
            
            let response = try decoder.decode(CustomResponse.self, from: data)
            return response
            
        }
        catch {
            print("error trying to convert data to JSON \(error)")
            return nil
        }
    }
    catch{
        return nil
    }
}

