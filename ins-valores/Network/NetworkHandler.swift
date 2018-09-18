//
//  NetworkHandler.swift
//  GMaps
//
//  Created by Novacomp on 1/30/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
//import Foundation
import Alamofire
import CoreLocation

class NetworkHandler: NSObject {
    
    static let url = "https://www.insinversiones.com/INSSAFI.InterfaceAppMovil/AppMovilServiceInterface.svc/json/" // Local
    
    typealias JSONStandard = Dictionary<String, Any>
    
    
    class func getRequest(urlString:String, data:JSONStandard, completed: @escaping (_ data:JSONStandard )-> ()) {
        
        
        //let urlString = "\(url)\(servicio)"
        
        
        Alamofire.request(urlString, method: .put, parameters: data, encoding: JSONEncoding.default, headers: [:]).responseJSON(completionHandler: {
            response in
            let result = response.result
            
            if let dict = result.value as? JSONStandard {
                
                print("This is my result: \(result.value!)")
                
                let componentArray = Array(dict.keys) // for NSDictionary
                
                
                // show the alert
                let currentView = getCurrentController()
                
                //currentView.dismiss(animated: true, completion: nil)
                
                let response = dict[componentArray[0]] as! String
                
                let dataJson = response.data(using: String.Encoding.utf8)
                
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                    
                    print(dataDictionary)
                    
                    if let resultado = dataDictionary["Resultado"] as? JSONStandard {
                    
                        if let respuesta = resultado["Respuesta"] as? JSONStandard {
                        
                            if(String(describing: respuesta["CodMensaje"]!) == "-999") {
                            
                                currentView.dismiss(animated: true, completion: nil)
                            
                                let alertSuccess = UIAlertController(title: "Sesión vencida", message: respuesta["Mensajes"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                            
                                let okAction = UIAlertAction (title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                                
                                    currentView.dismiss(animated: true, completion: nil)
                                })
                            
                                alertSuccess.addAction(okAction)
                            
                                currentView.present(alertSuccess, animated: true, completion: nil)
                            }
                            else {
                        
                            completed(dict)
                            }
                        }
                    }
                    else {
                        completed(dict)
                    }
                }
                catch {
                    currentView.dismiss(animated: true, completion: nil)
                }
                
            }
            
        })
        
    }
    
    
    
    class func getRequest(urlString:String, completed: @escaping (_ data:JSONStandard )-> ()) {
        
        //let urlString = "\(url)/General/ObtenerCaracteristicaCalidad"
        
        Alamofire.request(urlString).responseJSON(completionHandler: {
            response in
            let result = response.result
            print("This is my result: \(result.value!)");
            
            if let dict = result.value as? JSONStandard {
                
                completed(dict)
            }
            
        })
    }
    
    
    
    class func isReachable() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    
    class func getCurrentController () -> UIViewController {
        
        var currentViewController : UIViewController!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let viewControllers = appDelegate.window?.rootViewController?.presentedViewController
        {
            currentViewController = viewControllers as UIViewController
        }
        else if let viewControllers = appDelegate.window?.rootViewController?.childViewControllers
        {
            currentViewController = viewControllers.last! as UIViewController
        }
        
        return currentViewController
        
    }

}


extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}


extension Double
{
    public func formattedSeconds(format:String) -> String {
        
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let dateString = formatter.string(from: date)
        return dateString
    }
}

extension Date
{
    public func formattedDate(format:String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        let dateString = formatter.string(from: self)
        return dateString
    }
}
