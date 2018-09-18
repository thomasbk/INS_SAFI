//
//  IngresarCodigoViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/19/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class IngresarCodigoViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var codigoTextField: UITextField!
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var operacion:String = ""
    var referencia:String = ""
    
    //var numeroDocumento = ""
    var subcuenta = "0"

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        subcuenta = "0"
        codigoTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (operacion == "I" || operacion == "R" || operacion == "P") {
            titleLabel.text = "Solicitudes"
            titleImageView.image = UIImage(named: "solicitudes2")
        }
    }
    
    @IBAction func verificarAction(_ sender: Any) {
        verificarCuenta()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
        
        return false
    }
    
    
    func verificarCuenta() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: verifyCuenta)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func verifyCuenta() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_CODIGO_VERIFICACION)
        
        let params = ["TO":operacion, "CU":user.getSelectedCuenta()!,"NI":user.getUser()!,"SC":subcuenta, "ND":referencia,"CG":codigoTextField.text!, "TK":user.getToken()!]
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["VerificarCodigoVerificacionResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let respuesta = resultado["Respuesta"] as? JSONStandard {
                    
                    if(String(describing: respuesta["CodMensaje"]!) != "0") {
                        self.showAlert(title: "", message: respuesta["Mensajes"] as! String)
                    }
                    else {
                        let alertSuccess = UIAlertController(title: "Éxito", message: respuesta["Mensajes"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction (title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                            
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
                        })
                        
                        alertSuccess.addAction(okAction)
                        
                        self.present(alertSuccess, animated: true, completion: nil)
                    }
                }
            }
            catch {
                
            }
        }
    }
    
    
    

}
