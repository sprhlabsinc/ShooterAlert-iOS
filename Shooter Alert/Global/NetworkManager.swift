//
//  NetworkManager.swift
//  Shooter Alert
//
//  Created by Akira on 7/3/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
    static let sharedClient = NetworkManager()
    var baseURLString: String? = nil
    
    override init() {
        self.baseURLString = KServerURL
        super.init()
    }
    
    func postRequest(tag:String, parameters params:Parameters, completion:@escaping (_ error:String, _ response:NSDictionary)->Void){
        sendRequest(type: .post, urlTag: tag, parameters: params){ (error, result) in
            completion(error, result)
        }

    }
    func getRequest(tag:String, parameters params:Parameters, completion:@escaping (_ error:String, _ response:NSDictionary)->Void){
        sendRequest(type: .get, urlTag: tag, parameters: params){ (error, result) in
            completion(error, result)
        }
        
    }
    func putRequest(tag:String, parameters params:Parameters, completion:@escaping (_ error:String, _ response:NSDictionary)->Void){
        sendRequest(type: .put, urlTag: tag, parameters: params){ (error, result) in
            completion(error, result)
        }
        
    }
    func deleteRequest(tag:String, parameters params:Parameters, completion:@escaping (_ error:String, _ response:NSDictionary)->Void){
        sendRequest(type: .delete, urlTag: tag, parameters: params){ (error, result) in
            completion(error, result)
        }
        
    }
    fileprivate func sendRequest(type:HTTPMethod, urlTag tag:String, parameters params:Parameters, completion:@escaping (_ error:String, _ response:NSDictionary)->Void){

        URLCache.shared.removeAllCachedResponses()
        
        let url =  "\(KServerURL)\(tag)"
        //let Auth_header    = [ "Authentication" : AppManager.sharedInstance.getApiKey()]
        let Auth_header    = [ "Authentication" : ""]
        
        Alamofire.request(url, method:type, parameters: params, encoding: URLEncoding.default, headers: Auth_header).responseJSON { (response) in
            if (response.result.value != nil)
            {
                
                let json = response.result.value as! NSDictionary
                //print (json)
                let error = json.value(forKey: "error") as! Bool
                
                if !error
                {
                    completion("", json)
                }
                else
                {
                    let error_message = json.value(forKey: "message") as! String
                    completion(error_message,[:])
                }
                
            }
            else{
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
                let statusCode = response.response?.statusCode
                let error = "HTTP Status:\(String(describing: statusCode))"
                completion(error, [:])
            }
        }
    }
    func uploadImageWithParameter(tag:String, file data:[String : Any], parameters params:NSDictionary, completion:@escaping (_ error:String, _ response:NSDictionary)->Void) {
        let url =  "\(KServerURL)\(tag)"
        //let auth_header    = [ "Authentication" : AppManager.sharedInstance.getApiKey()]
        let Auth_header    = [ "Authentication" : ""]
        
        let imgData:Data = data["image"]! as! Data
        let fileName:String = data["name"] as! String
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if (data["image"] != nil){
               multipartFormData.append(imgData, withName: "uploadFile", fileName: fileName, mimeType: "image/jpg")
            }
            
            for (key, value) in params {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as! String)
            }
        },
        to:url,
        method:.post,
        headers:Auth_header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if (response.result.value != nil)
                    {
                        
                        let json = response.result.value as! NSDictionary
                        print (json)
                        
                        let error = json.value(forKey: "error") as! Bool
                        
                        if !error
                        {
                            completion("", json)
                        }
                        else
                        {
                            let error_message = json.value(forKey: "message") as! String
                            completion(error_message,[:])
                        }
                        
                    }
                    else{
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            print("Data: \(utf8Text)")
                        }
                        let statusCode = response.response?.statusCode
                        let error = "HTTP Status:\(String(describing: statusCode))"
                        completion(error, [:])
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)  
            }
        }
    }


}
