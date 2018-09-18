//
//  CambiarContraseñaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/27/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class CambiarContrasenaViewController: UIViewController {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    @IBOutlet weak var contrasenaViejaField: UITextField!
    @IBOutlet weak var contrasenaNuevaField: UITextField!
    @IBOutlet weak var contrasenaNuevaConfirmacionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        hideKeyboardWhenTappedAround()
        
        var boderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        contrasenaViejaField.layer.borderColor = boderColor
        contrasenaViejaField.layer.borderWidth = 1
        contrasenaNuevaField.layer.borderColor = boderColor
        contrasenaNuevaField.layer.borderWidth = 1
        contrasenaNuevaConfirmacionField.layer.borderColor = boderColor
        contrasenaNuevaConfirmacionField.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cambiarAction(_ sender: Any) {
        if (contrasenaNuevaField.text == contrasenaNuevaConfirmacionField.text) {
            cambiarContrasena()
        }
        else {
            showAlert(title: "", message: "Las contraseñas no coinciden")
        }
    }
    
    
    func cambiarContrasena() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: changeContrasena)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func changeContrasena() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_CAMBIO_CONTRASENA)
        
        let params = ["NI":user.getUser()!, "PA":contrasenaViejaField.text!, "NP":contrasenaNuevaField.text!]
        
        let data = ["pUsuario":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        
        let encriptado = RequestUtilities.getencrypt(RequestUtilities.jsonCastWithoutReplaced(data))
        
        let paramsExtern = ["pJsonString":encriptado!]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["CambioContrasennaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                if let codigo = dataDictionary["Codigo"] {
                    if(String(describing: codigo) == "0") {
                        self.contrasenaViejaField.text = ""
                        self.contrasenaNuevaField.text = ""
                        self.contrasenaNuevaConfirmacionField.text = ""
                        self.showAlert(title: "", message: "Contraseña cambiada exitosamente")
                        
                        
                    }
                    else {
                        self.showAlert(title: "", message: dataDictionary["DesResultado"] as! String)
                    }
                }
                
                
            }
            catch {
                
            }
        }
    }

}
