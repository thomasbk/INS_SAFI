//
//  DetalleFavoritaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/20/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class DetalleFavoritaViewController: UIViewController {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var favorita:JSONStandard!
    
    @IBOutlet weak var agregarHuellaButton: UIButton!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var numCuentaLabel: UILabel!
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var entidadCuentaLabel: UILabel!
    @IBOutlet weak var monedaCuentaLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        setData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "seleccionarCorreoSegue") {
            let vc = segue.destination as! SeleccionarCorreoViewController
            vc.favorita = favorita
        }
    }
    
    
    func setData() {
        
        numCuentaLabel.text = favorita["CC"] as? String
        nombreCuentaLabel.text = favorita["CN"] as? String
        entidadCuentaLabel.text = favorita["NE"] as? String
        monedaCuentaLabel.text = favorita["MO"] as? String
        
        favorita["NO"] = favorita["CN"] as? String
        favorita["IC"] = favorita["NI"] as? String
        
        if(favorita["ES"] as! String == "Activa") {
            
            agregarHuellaButton.isHidden = true
            agregarButton.isHidden = true
        }
        else {
            let context = LAContext()
            var error: NSError?
            
            if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                agregarHuellaButton.isHidden = true
                
                agregarButton.center = CGPoint(x:self.view.center.x, y:agregarButton.center.y)
            }
        }
    }
    
    
    @IBAction func agregarCuentaAction () {
        
        //performSegue(withIdentifier: "seleccionarCorreoSegue", sender: nil)
    }
    
    @IBAction func agregarCuentaHuellaAction () {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Valide la acción con su huella"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.agregarFavorita(tipo:"B")
                    }
                    else {
                        
                    }
            })
        }
            
        else {
            // Not available
            
        }
        
    }
    
    
    
    
    func agregarFavorita(tipo:String) {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: {
                self.addFavorita(tipo: tipo)
            })
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func addFavorita(tipo:String) {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_FAVORITA)
        
        var params:JSONStandard!
        
        params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":tipo, "CC":numCuentaLabel.text!,"NO":nombreCuentaLabel.text!,"MO":monedaCuentaLabel.text!,"CE":entidadCuentaLabel.text!,"CO":"Correo", "IT":favorita["NI"] as! String, "TK":user.getToken()!]
        if(tipo == "B") {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            let fecha = format.string(from: Date())
            
            let detallesDispositivo = "Apple " + UIDevice.current.model + " " + UIDevice.current.systemVersion
            
            let DV = ["DI":detallesDispositivo,"FE":fecha]
            params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":tipo, "CC":numCuentaLabel.text!, "NO":nombreCuentaLabel.text!, "MO":monedaCuentaLabel.text!,"CE":entidadCuentaLabel.text!, "IT":favorita["NI"] as! String, "DV":DV, "TK":user.getToken()!]
        }
        
        let data = ["pTransaccion":params!]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["GrabarCuentaFavoritaResult"] as! String
            
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
                        self.showAlert(title: "Éxito", message: "Cuenta agregada con éxito.")
                    }
                }
                
                
            }
            catch {
                
            }
        }
    }

}
