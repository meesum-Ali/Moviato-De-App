//
//  HBLHandShake.swift
//  Konnect App
//
//  Created by Muhammad Talha Ashfaque on 12/13/17.
//  Copyright © 2017 Muhammad Talha Ashfaque. All rights reserved.
//

import Foundation
import UIKit

private let sessionObject: Session = Session.singleton


//Login Request
func getDefaultParametersMap() -> NSDictionary{
    
    let map = NSMutableDictionary()
    map.setValue(kAppVersionNumber, forKey: "versionumber")
    map.setValue(kOSVersion, forKey: "deviceVersion")
    map.setValue(kModelName, forKey: "deviceModel")
    map.setValue(kManufacturer, forKey: "deviceMake")
    map.setValue((kDeviceId ?? ""), forKey: "deviceImei")
    
    return map
    
}

func getDefaultParameterMergeRequest(reqDict: [String:Any]? , session_token : String?) -> NSMutableDictionary{
    
    let params = NSMutableDictionary()
    params.setValue(toJson(data:getDefaultParametersMap()), forKey: "deviceDetails")
    
    if reqDict != nil{
        var keys = Array(reqDict!.keys)
        
        
        var i = 0;
        for _ in (reqDict?.keys)! {
            
            print(keys[i])
            print(reqDict![keys[i]]!)
            params.setValue(reqDict![keys[i]]!, forKey: keys[i])
            i+=1;
        }
    }
    if session_token != nil {
        params.setValue(session_token, forKey: "token")
    }
    params.setValue(kAppVersionNumber, forKey: "versionumber")
    
    return params
}

//public func logout(successHandler: @escaping  (_ success: Bool) -> Void) {
//
//    var _token = "";
//    if let token = sessionObject.token() {
//        _token = token
//    }
//    let params = NSMutableDictionary()
//    params.setValue(_token, forKey: "token")
//
//    let jsonStr = toJson(data: params)
//
//    client.asyncPost(urlString: "\(Constants.serviceUrl)logout", httpdata: jsonStr, contentType : Constants.contentTypeJson, callback: {(data, isSuccess, error) -> Void in
//        successHandler(true)
//    })
//}

func callLogOutRequest(vc: UIViewController, successHandler: @escaping  () -> Void, errorHandler: @escaping () -> Void) {
    
    let updatedDic = ["token": sessionData![SK_SESSION_TOKEN]]
    
    NetworkManager.shared().defaultManager.session.getAllTasks { (tasks) in
        tasks.forEach({$0.cancel()})
    }
    
    NetworkManager.shared().sendRequestForLogin(endUrl: kLogout2, body: updatedDic as Any as! [String : Any], vc: vc, contentType: Constants.contentTypeJson, shouldShowProgress: false, shouldShowAlert: false) { (js, data, isSuccess, error) in
        if isSuccess {
            successHandler()
        }else{
            errorHandler()
        }
    }
    
}


func callLoginRequest(doDataEncryption: Bool? = false, vc: UIViewController,reqDict: [String : Any], successHandler: @escaping  ( _ payload: NSDictionary?,  _ newMsg: AnyObject?, _ link: String?, _ advisory: NSDictionary?,_ tncUpdate:NSDictionary?) -> Void, errorHandler: @escaping (_ error: String) -> Void, updateRequired:  @escaping ( _ newMsg: AnyObject, _ link: String,_ updateType:String) -> Void) {
    
    Constants.lastActivityTime = Date()
    kElapsedTime = 0
    
    let updatedDic = reqDict.merging(getDefaultParametersMap() as! [String : Any]) { (_, new) in new }
    
    //////
    var encryptedData: [String: AnyObject]?
    if(doDataEncryption)!{
        
        let keyString = generateRandomBytes()
        let ivString = "abcaqwerabcaqwer"
        let encrytedData = toJson(data: updatedDic as AnyObject)?.aesEncrypt(key: keyString!, iv: ivString, options: kCCOptionPKCS7Padding)
        let rsaEncryptedKey = rsaEncrypt(stringToEncrypt: keyString!)
        
        let encryptedParams: [String: AnyObject]? = ["data1":encrytedData as AnyObject, "data2":rsaEncryptedKey as AnyObject, "data3":"1" as AnyObject]
        encryptedData = encryptedParams
    }else{
        encryptedData = updatedDic as [String : AnyObject]
    }
    
    /////
    
    NetworkManager.shared().sendRequestForLogin(endUrl: kLogin, body: encryptedData!, vc: vc, contentType: Constants.contentTypeForm) { (js, data, isSuccess, error) in
        
        //progV.removeFromSuperview()
        if isSuccess {
            
            Constants.shouldCheckSession = true
            
            hideProgressController()
            let token: String? = data?.value(forKey: "token") as? String
            
            sessionData![SK_SESSION_TOKEN] = token
            
            sessionData![kSessionIdleTime] = data?.value(forKey: kSessionIdleTime) as? Int
            
            sessionData![SK_DASHBOARD_NAME] = data?.value(forKey: "dashboardName") as? String
            sessionData![SK_CUSTOMER_TYPE] = data?.value(forKey: "customertype") as? String
            sessionData![SK_IS_ACCOUNT_PREVIEW_ENABLED] = data?.value(forKey: "isAccountPreviewEnabled") as? String
            
            let lastLoggedInUserName = UserDefaults.standard.string(forKey: SK_DASHBOARD_NAME)
            if (sessionData![SK_DASHBOARD_NAME] as? String) != nil {
                if lastLoggedInUserName != (sessionData![SK_DASHBOARD_NAME] as! String) {
                    
                    UserDefaults.standard.removeObject(forKey: SK_DASHBOARD_CALLS)
                    
                }
            }
            
            UserDefaults.standard.set(sessionData![SK_DASHBOARD_NAME] ?? "", forKey: SK_DASHBOARD_NAME)
            
            let dashboardCallsDictionary = data?.value(forKey: "Dashboard_Calls") as? [String:String]
            
            if dashboardCallsDictionary != nil && dashboardCallsDictionary!["fetchSuccess"] == "1" {
                
                UserDefaults.standard.set(data?.value(forKey: "Dashboard_Calls"), forKey: SK_DASHBOARD_CALLS)
                
            }
            
            let disabledAccounts = data?.value(forKey: "disabledAccountTypes") as? NSDictionary
            //            let disabledMessage = data?.value(forKey: "disabledMessage") as? String
            
            //            let params = NSMutableDictionary()
            //            params.setValue(disabledAccounts, forKey: "disabledAccounts")
            //            params.setValue(disabledMessage, forKey: "disabledMessage")
            sessionData![SK_DISABLEDACCOUNTS] = disabledAccounts //params
            //Cache.singleton.put(key: Cache.CACHE_DISABLEDACCOUNTS, val: params)
            
            var tncdata:NSMutableDictionary? = nil
            if let tncUpdateNeeded  = data?.value(forKey: "toUpdateTnc") as? String{
                if tncUpdateNeeded == "true" {
                    tncdata = NSMutableDictionary()
                    tncdata!.setValue(
                        formatAmount(largeNumber: (data?.value(forKey: "currentTncVersion") as? Double)!), forKey: "currentTncVersion")
                }
            }
            if data?.value(forKey: "userstatus") as? String == Constants.passwordChangeRequired || data?.value(forKey: "userstatus") as? String == "PASSWORD_RESET_REQUIRED" {
                
                successHandler( data, data?.value(forKey: "DetailsNew") as AnyObject,  data?.value(forKey: "Link") as? String,  data?.value(forKey: "advisory") as? NSDictionary, tncdata)
            } else {
                
                var newDetail : AnyObject? = nil
                var link : String? = nil
                
                
                if (data?.value(forKey: "DetailsNew") != nil){
                    newDetail = data?.value(forKey: "DetailsNew") as AnyObject
                }
                if let lnk = data?.value(forKey: "Link") as? String{
                    link = lnk
                }
                
                let userDefaults = UserDefaults.standard
                if data?.value(forKey: "appUpdate") != nil{
                    
                    userDefaults.setValue(data?.value(forKey: "appUpdate"), forKey: Constants.isNewVersion)
                    
                }
                else{
                    
                    userDefaults.setValue("false", forKey: Constants.isNewVersion)
                    
                }
                userDefaults.synchronize()
                
                successHandler( nil,   newDetail,  link,  data?.value(forKey: "advisory") as? NSDictionary, tncdata)
                
            }
            
        }else{
            errorHandler(error!)
        }
        
    }
    
}

// MARK:- Common call
fileprivate func networkCall(_ doDataEncryption: Bool?,
                             _ reqObj: CustomRequest,
                             _ VC: HblBaseViewController,
                             _ shouldShowAlert: Bool?,
                             _ shouldCache: Bool?,
                             _ shouldShowProgress: Bool? = true,
                             _ completionHandler: @escaping (CustomResponse?, Bool) -> Void) {
    
    if !SERVER_MODULE_NAME.contains("hblmbsignup"){
       let state = VC.calculateIdleTime()
        if state! {
            return
        }
    }
    
    VC.determineMyCurrentLocation()
    reqObj.header?.clientDetails?.latitude = sessionData![SK_LAT] as? String
    reqObj.header?.clientDetails?.longitude = sessionData![SK_LONG] as? String
    
    var encryptedData: [String: AnyObject]?
    guard let body = getSerializeDictionary(request: reqObj) else {
        return
    }
    
    let progV = RequestProgressIndicatiorView(frame: UIScreen.main.bounds)
    
    if shouldShowProgress! {
        // VC.view.addSubview(progV)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(progV);
        
    }
    
    if(doDataEncryption)!{
        
        let keyString = generateRandomBytes()
        let ivString = "abcaqwerabcaqwer"
        let encrytedData = toJson(data: body as AnyObject)?.aesEncrypt(key: keyString!, iv: ivString, options: kCCOptionPKCS7Padding)
        let rsaEncryptedKey = rsaEncrypt(stringToEncrypt: keyString!)
        
        let encryptedParams: [String: AnyObject]? = ["data1":encrytedData as AnyObject, "data2":rsaEncryptedKey as AnyObject, "data3":"1" as AnyObject]
        encryptedData = encryptedParams
        //        let encryptedParams = [NSMutableDictionary()]
        //
        //        // The complete AES-Encrypted data
        //        encryptedParams.setValue(encrytedData, forKey: "data1")
        //        // RSA encrypt the Key which has been used for AES encryption
        //        encryptedParams.setValue(rsaEncryptedKey, forKey: "data2")
        //        // This is for the identification of the platform i.e. iOS
        //        encryptedParams.setValue("1", forKey: "data3")
        
        //        let encryptedParamsString = toJson(data: encryptedParams)
        //        request.httpBody = encryptedParamsString?.data(using: String.Encoding.utf8)
        
    }else{
        encryptedData = body as [String : AnyObject]
    }
    
    
    
    NetworkManager.shared().sendrequest(body: encryptedData!,
                                        vc: VC,
                                        shouldShowAlert: shouldShowAlert) { (resp, isSuccess) in
                                            progV.removeFromSuperview()
                                            
                                            if isSuccess {
                                                if shouldCache! {
                                                    let k = getCacheKey(reqObj: reqObj)
                                                    if k.contains((resp?.header?.transactionType)!)  {
                                                        sessionData![k] = resp
                                                    }
                                                    else {
                                                        if let a = resp?.header?.transactionType {
                                                            sessionData![a] = resp
                                                        }
                                                    }
                                                }
                                                clearCacheRelavantToTransactionType(tranType: resp?.header?.transactionType, reqObj: reqObj)
                                            }
                                            completionHandler(resp, isSuccess)
    }
    
}

func generateRandomBytes() -> String? {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$&"
    let len = UInt32(letters.length)
    
    var randomString = ""
    let length = 16
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

func rsaEncrypt(stringToEncrypt:String) -> String {
    
    let keyData = NSData(base64Encoded: Constants.RSA_Public_Key, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
    
    let dictionary: [NSString: AnyObject] = [
        kSecClass: kSecClassKey,
        kSecAttrKeyType: kSecAttrKeyTypeRSA,
        kSecAttrKeyClass: kSecAttrKeyClassPublic,
        kSecAttrApplicationTag: "HBLMobilePublicKeyTag" as AnyObject,
        kSecValueData: keyData!,
        kSecAttrKeySizeInBits: NSNumber(value: 1024),
        kSecReturnRef: true as AnyObject
    ];
    
    var err = SecItemAdd(dictionary as CFDictionary, nil);
    
    if ((err != noErr) && (err != errSecDuplicateItem)) {
        print("error loading public key");
    }
    
    var keyRef: AnyObject?;
    var base64String: String?
    err = SecItemCopyMatching(dictionary as CFDictionary, &keyRef);
    if (err == noErr) {
        if let keyRef = keyRef as! SecKey? {
            
            let plaintextLen = stringToEncrypt.lengthOfBytes(using: String.Encoding.utf8);
            let plaintextBytes = [UInt8](stringToEncrypt.utf8);
            
            var encryptedLen: Int = SecKeyGetBlockSize(keyRef);
            var encryptedBytes = [UInt8](repeating: 0, count: encryptedLen);
            
            err = SecKeyEncrypt(keyRef, SecPadding.PKCS1, plaintextBytes, plaintextLen, &encryptedBytes, &encryptedLen);
            let data = NSData(bytes: encryptedBytes, length: encryptedBytes.count)
            
            base64String = data.base64EncodedString(options: [])
        }
    }
    
    SecItemDelete(dictionary as CFDictionary);
    return base64String!
}

public func toJson(data: AnyObject) -> String? {
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

fileprivate func generalNetworkCall(_ doDataEncryption: Bool?,
                                    _ reqObj: CustomRequest,
                                    _ sessionKey: String,
                                    _ VC: HblBaseViewController,
                                    _ shouldShowAlert: Bool?,
                                    _ shouldCache: Bool?,
                                    _ shouldShowProgress: Bool? = true,
                                    _ completionHandler: @escaping (CustomResponse?, Bool) -> Void) {
    
    let sessionKey1  =  getCacheKey(reqObj: reqObj)
    if let response = sessionData![sessionKey1] {
        completionHandler(response as? CustomResponse, true)
    }
    else
    {
        networkCall(doDataEncryption,
                    reqObj,
                    VC,
                    shouldShowAlert,
                    shouldCache,
                    shouldShowProgress,
                    { (resp, isSuccess) in
                        completionHandler(resp, isSuccess)
        })
        
    }
}

func generalRequest(doDataEncryption: Bool? = true,
                    reqObj:CustomRequest,
                    VC: HblBaseViewController,
                    shouldShowAlert: Bool? = true,
                    shouldCache: Bool? = false,
                    shouldShowProgress: Bool? = true,
                    completionHandler: @escaping (_ result: CustomResponse?, _ isSuccess: Bool) -> Void) {
    
    reqObj.header?.token = sessionData?[SK_SESSION_TOKEN] as? String
    
    if shouldCache! {
        let key =  getCacheKey(reqObj: reqObj)
        generalNetworkCall(doDataEncryption,
                           reqObj,
                           key,
                           VC,
                           shouldShowAlert,
                           true,
                           shouldShowProgress,
                           { (resp, isSuccess) in
                            
                            completionHandler(resp, isSuccess)
                            
        })
    }
    else {
        networkCall(doDataEncryption,
                    reqObj,
                    VC,
                    shouldShowAlert,
                    shouldCache,
                    shouldShowProgress,  { (resp, isSuccess) in
                        completionHandler(resp, isSuccess)
        })
    }
    
}


// MARK:- Send money call
func callSendMoneyInitialRequests(reqObj:CustomRequest,
                                  VC: HblBaseViewController,
                                  shouldShowAlert: Bool? = true,
                                  shouldCache: Bool? = true,
                                  completionHandler: @escaping (_ result: CustomResponse?, _ isSuccess: Bool) -> Void) {
    
    reqObj.header?.transactionType = kListAccountsCards
    reqObj.body?.transactionDetails?.getCards = Constants.isCreditCardCallEnabeled ? "TRUE" : "FALSE"
    
    generalRequest(reqObj: reqObj,
                   VC: VC,
                   shouldShowAlert: shouldShowAlert,
                   shouldCache: shouldCache) { (resp, isSuccess) in
                    if isSuccess {
                        reqObj.header?.transactionType = kGetBeneList
                        
                        generalRequest(reqObj: reqObj, VC: VC, shouldShowAlert: shouldShowAlert, shouldCache: shouldCache, completionHandler: { (resp, isSuccess) in
                            
                            completionHandler(resp, isSuccess)
                            
                        })
                    }
                    else {
                        completionHandler(resp, isSuccess)
                    }
    }
}


func callPaymentBene(reqObj:CustomRequest, VC: HblBaseViewController,
                     shouldShowAlert: Bool? = true,
                     shouldCache: Bool? = true, isBeneMng : Bool? = false,
                     completionHandler: @escaping (_ result: CustomResponse?, _ isSuccess: Bool) -> Void) {
    
    
    reqObj.header?.transactionType = kBillBeneNickCRUDServices
    reqObj.body?.transactionDetails?.operationType = "READ"
    
    
    generalRequest(reqObj: reqObj,
                   VC: VC,
                   shouldShowAlert: shouldShowAlert,
                   shouldCache: shouldCache) { (resp, isSuccess) in
                    if isSuccess {
                        if let data = resp?.body?.billNickBeneficiaries {
                            // if let data = resp?.body?.categorizedBillNickBene {
                            if data.count > 0 {
                                completionHandler(resp, isSuccess)
                            }
                            else{
                                //if isBeneMng! {
                                completionHandler(resp, isSuccess)
                                //}
                                //                                else{
                                //                                account_cards_CommonHandler(vc: VC, _getCards: false, completionHandler: { (_ result, _ isSuccess) in
                                //
                                //                                    reqObj.header?.transactionType = kGetDynamicBillCategories
                                //
                                //                                    generalRequest(reqObj: reqObj, VC: VC, shouldShowAlert: shouldShowAlert, shouldCache: shouldCache, completionHandler: { (resp, isSuccess) in
                                //
                                //                                        completionHandler(resp, isSuccess)
                                //
                                //                                    })
                                //
                                //                                })
                                //                                }
                                
                            }
                        }
                        
                    }
                    else {
                        completionHandler(resp, isSuccess)
                    }
    }
}

func getEipo(reqObj:CustomRequest, VC: HblBaseViewController,
             shouldShowAlert: Bool? = true,
             shouldCache: Bool? = true,
             completionHandler: @escaping (_ result: CustomResponse?, _ isSuccess: Bool) -> Void) {
    
    account_cards_CommonHandler(vc: VC, _getCards: true, completionHandler: { (_ result, _ isSuccess) in
        
        reqObj.header?.transactionType = kGetDynamicBillCompanies
        reqObj.body?.transactionDetails?.billCategory = "BILL_BASED"
        reqObj.body?.transactionDetails?.billSubCategory = "e-IPO"
        generalRequest(reqObj: reqObj, VC: VC, shouldCache: true) { (resp, isSuccess) in
            if isSuccess {
                
                completionHandler(resp, isSuccess)
                
            }
            else {
                completionHandler(resp, isSuccess)
            }
        }
        
    })
    
}


func getAccountsandCardsData(reqObj:CustomRequest, VC: HblBaseViewController,
                             shouldShowAlert: Bool? = true,
                             shouldCache: Bool? = true,
                             completionHandler: @escaping (_ result: CustomResponse?, _ isSuccess: Bool) -> Void) {
    
    account_cards_CommonHandler(vc: VC, _getCards: false, completionHandler: { (_ result, _ isSuccess) in
        
        
        completionHandler(result, isSuccess)
        
        
    })
    
}

func account_cards_CommonHandler(vc: HblBaseViewController, _getCards:Bool,  completionHandler: @escaping  (_ result: CustomResponse?, _ isSuccess: Bool) -> Void){
    
    
    let reqObj = CustomRequest()
    
    reqObj.header?.token = sessionData?[SK_SESSION_TOKEN] as? String
    reqObj.header?.transactionType = kListAccountsCards
    reqObj.body?.transactionDetails?.getCards = Constants.isCreditCardCallEnabeled ? "TRUE" : "FALSE" //String(_getCards).uppercased()
    
    generalRequest(reqObj: reqObj,
                   VC: vc,shouldShowAlert: true,
                   shouldCache: true,
                   shouldShowProgress: true,
                   completionHandler: { (resp, isSuccess) in
                    if isSuccess {
                        sessionData![SK_ACCOUNTS] = resp?.body?.customerAccountList
                        sessionData![SK_CREDIT_CARDS] = resp?.body?.customerCreditCardList
                        completionHandler(resp, isSuccess)
                        
                        
                    }
                    //                    else {
                    //                        completionHandler(resp, isSuccess)
                    //                    }
    })
    
}

func getCacheKey(reqObj: CustomRequest) -> String {
    var key = ""
    switch reqObj.header?.transactionType {
        
//    case kListAccountsCards?:
//        key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.getCards) ?? "FALSE")"
//        break
        
    case kAccountStatement?:
        if reqObj.body?.transactionDetails?.searchType == "4" {
            key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.noOfDays)!)|\((reqObj.body?.sourceAccount?.accno)!)"
        }
        else {
            key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.from_date)!)|\((reqObj.body?.transactionDetails?.to_date)!)|\((reqObj.body?.sourceAccount?.accno)!)"
        }
        break
    case kGetCreditCardStatement?:
        key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.creditCardNumber)!)|\((reqObj.body?.month)!)"
        break
    case kChequeBookStatusInquiry?:
        key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.sourceAccount?.accno)!)|\((reqObj.body?.chequeBookId)!)"
        break
    case kGetDynamicBillCompanies?:
        key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.billCategory)!)|\((reqObj.body?.transactionDetails?.billSubCategory)!)"
        break
    case kBillBeneNickCRUDServices?:
        key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.operationType)!)"
        break
    case kGetLoanStatement?:
        if(reqObj.body?.transactionDetails?.noOfDays != nil){
            key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.loanAccountNo)!)|\((reqObj.body?.transactionDetails?.noOfDays)!)"
        }else{
            key = "\((reqObj.header?.transactionType)!)|\((reqObj.body?.transactionDetails?.loanAccountNo)!)|\((reqObj.body?.transactionDetails?.from_date)!)|\((reqObj.body?.transactionDetails?.to_date)!)"
        }
        
        break
    default:
        key = (reqObj.header?.transactionType)!
        break
    }
    return key
}

func removeCacheforKey(key: String) {
    sessionData![key] = nil
}

func removeCacheforKeyContaining(key: String, ignoreKey: String? = "") {
    let arr = sessionData?.keys.filter({ (k) -> Bool in
        return k.contains(key)
    })
    for key in arr!{
        if key == ignoreKey {
            continue
        }
        sessionData![key] = nil
    }
}


func clearCacheRelavantToTransactionType(tranType: String?, reqObj: CustomRequest) {
    
    let k = getCacheKey(reqObj: reqObj)
    
    if let tt = tranType {
        
        switch tt{
            //kGetBeneficiaryManagement_UpdateBene
            //kGetBeneficiaryManagement_RemoveBene
            //        case kGetBeneficiaryManagement_SaveBane:
            //            sessionData![kGetBeneList] = nil
            //            break
            
        case kSetStandingInstructions:
            sessionData![kGetAllStandingInstructions] = nil
            sessionData![kGetAllStandingInstructionOccurrences] = nil
            sessionData![kCustomerAccounts] = nil
            sessionData![kListAccountsCards] = nil
            removeCacheforKeyContaining(key: kAccountStatement)
            break
            
        case kGetInsurancePurchased,
             kFundTransferOwn,
             kFundTransferInterBranch,
             kFundTransferInterBank,
             kMakeBillPayment,
             kDynamicUtilityBillPayment:
            
            sessionData![kCustomerAccounts] = nil
            sessionData![kListAccountsCards] = nil
            removeCacheforKeyContaining(key: kAccountStatement)
            break
            
        case kMarkAccountAsFavorite:
            sessionData![kListAccountsCards] = nil
            break
            
        case kMakeCreditCardPayment:
            sessionData![kCustomerAccounts] = nil
            sessionData![kListAccountsCards] = nil
            removeCacheforKeyContaining(key: kGetCreditCardStatement)
            removeCacheforKeyContaining(key: kGetCreditCardStatementMonthsAndYears)
            break
            
        case kActivateDebitCard,
             kblockDebitCard:
            sessionData![klistDebitCards] = nil
            
        case kblockCreditCard,
             kunblockCreditCard,
             kActivateCreditCard:
            
            sessionData![kGetAllCreditCardList] = nil
            
        case kMakeChequeBookRequest:
            sessionData![kGetChequeBookRequestData] = nil
            sessionData![kGetAllAccountsChequeBookStatus] = nil
            removeCacheforKeyContaining(key: kChequeBookStatusInquiry)
            
        case kMakeLoanBalloonPayment:
            sessionData![kGetLoanList] = nil
            sessionData![kCustomerAccounts] = nil
            sessionData![kListAccountsCards] = nil
            removeCacheforKeyContaining(key: kGetLoanStatement)

        case kBillBeneNickCRUDServices:
            if k.lowercased().contains("remove") || k.lowercased().contains("update") {
                removeCacheforKeyContaining(key: kBillBeneNickCRUDServices)
            }
            break

        case kAccountStatement:
            removeCacheforKeyContaining(key: kAccountStatement, ignoreKey: k)
            break
            
        default:
            break
        }
    }
    
}

extension String {
    
    func aesEncrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = self.data(using: String.Encoding.utf8),
            let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) {
            
            
            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)
            
            
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)
            
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let base64cryptString = cryptData.base64EncodedString(options:[])
                //                print("base64cryptString = " + base64cryptString)
                return base64cryptString
                
                
            }
            else {
                return nil
            }
        }
        return nil
    }
    
    func aesDecrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
            let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {
            
            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }
}

//extension String {
//
//    func fromBase64() -> String? {
//        guard let data = Data(base64Encoded: self) else {
//            return nil
//        }
//
//        return String(data: data, encoding: .utf8)
//    }
//
//    func toBase64() -> String {
//        return Data(self.utf8).base64EncodedString()
//    }
//}

