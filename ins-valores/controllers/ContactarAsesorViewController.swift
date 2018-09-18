//
//  ContactarAsesorViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/12/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class ContactarAsesorViewController: UIViewController,UITextViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var numAsesorLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mensajeTextView: UITextView!
    @IBOutlet weak var fotoView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        mensajeTextView.delegate = self
        mensajeTextView.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        mensajeTextView.layer.borderWidth = 1.0
        mensajeTextView.text = "Escribir mensaje"
        mensajeTextView.textColor = UIColor.lightGray
        
        obtenerAsesor()
        
        hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                //self.view.frame.origin.y += keyboardSize.height
                self.view.frame.origin.y = 0
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Escribir mensaje"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    @IBAction func enviarMensaje(_ sender: Any) {
        
        if(mensajeTextView.text.count > 0) {
            enviarMensaje()
        }
        else {
            showAlert(title: "", message: "Debe ingresar un texto")
        }
    }
    
    
    func obtenerAsesor() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getAsesor)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getAsesor() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_INFORMACION_ASESOR)
        
        let params = ["CU":user.getSelectedCuenta()!, "SC":"0", "TK":user.getToken()!]
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerInformacionAsesorResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    let asesor = contenido[0]
                    
                    self.nombreLabel.text = asesor["NO"] as? String
                    self.numAsesorLabel.text = "Credencial de la Cámara de Fondos de Inversión Nº: \((asesor["NU"] as! NSNumber).stringValue)"
                    self.telefonoLabel.text = asesor["TE"] as? String
                    self.emailLabel.text = asesor["CO"] as? String
                    
                    
                    let fotoUrl = asesor["FT"] as? String
                    //self.fotoView.imageFromUrl(urlString: fotoUrl!)
                    self.fotoView.load(url: URL(string: fotoUrl!)!)
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    
    func enviarMensaje() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: sendMensaje)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func sendMensaje() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_REMITIR_MENSAJE)
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "SC":"0", "MJ":mensajeTextView.text!, "TK":user.getToken()!]
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["RemitirMensajeAsesorResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                //let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                self.showAlert(title: "Éxito", message: "Mensaje enviado exitosamente.")
                
            }
            catch {
                
            }
        }
    }
    

}


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

