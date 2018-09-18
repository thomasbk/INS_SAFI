//
//  AgregarFavoritaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/17/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
import LocalAuthentication

class AgregarFavoritaViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {

    typealias JSONStandard = Dictionary<String, Any>
    
    var user: User!
    
    var favorita:JSONStandard!
    
    @IBOutlet weak var cuentaField: UITextField!
    
    var subcuentas = [JSONStandard]()
    let tipoCuentas = ["Cuenta Cliente", "IBAN"]
    let tipoCuentasTexto = ["Incluya los 17 caracteres", "Incluya los 22 caracteres"]
    
    @IBOutlet weak var subcuentasButton: UIButton!
    @IBOutlet weak var tipoCuentaButton: UIButton!
    
    @IBOutlet weak var cuentaView: UIView!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    var tipoPicker = 1
    var selectedSubcuenta = 0
    var selectedTipoCuenta = 0
    
    @IBOutlet weak var numCuentaLabel: UILabel!
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var entidadCuentaLabel: UILabel!
    @IBOutlet weak var monedaCuentaLabel: UILabel!
    
    @IBOutlet weak var descripcionCuentaLabel: UILabel!
    
    @IBOutlet weak var agregarHuellaButton: UIButton!
    @IBOutlet weak var agregarButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        cuentaView.isHidden = true
        
        
        let context = LAContext()
        var error: NSError?
        
        if (!context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || !UserDefaults.standard.bool(forKey: "TransaccionTouchID")) {
            agregarHuellaButton.isHidden = true
            
            agregarButton.center = CGPoint(x:cuentaView.center.x, y:agregarButton.center.y)
        }
        
        tipoCuentaButton.setTitle(tipoCuentas[selectedTipoCuenta], for: .normal)
        
        obtenerCuentas()
        
        hideKeyboardWhenTappedAround()
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
    
    

    @IBAction func seleccionarSubcuenta(_ sender: Any) {
        tipoPicker = 1
        pickerView.reloadAllComponents()
        pickerViewBack.isHidden = false
    }
    @IBAction func seleccionarTipoCuenta(_ sender: Any) {
        tipoPicker = 2
        pickerView.reloadAllComponents()
        pickerViewBack.isHidden = false
        
    }
    
    @IBAction func verificarCuentaAction () {
        self.cuentaField.resignFirstResponder()
        verificarCuenta()
    }
    
    @IBAction func agregarCuentaAction () {
        self.cuentaField.resignFirstResponder()
        performSegue(withIdentifier: "seleccionarCorreoSegue", sender: nil)
    }
    
    @IBAction func agregarCuentaHuellaAction () {
        self.cuentaField.resignFirstResponder()
        
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
    
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        if tipoPicker == 1 {
            selectedSubcuenta = pickerView.selectedRow(inComponent: 0)
            subcuentasButton.setTitle(subcuentas[selectedSubcuenta]["NC"] as? String, for: .normal)
        }
        else {
            selectedTipoCuenta = pickerView.selectedRow(inComponent: 0)
            tipoCuentaButton.setTitle(tipoCuentas[selectedTipoCuenta], for: .normal)
            descripcionCuentaLabel.text = tipoCuentasTexto[selectedTipoCuenta]
        }
    }
    
    
    
    func obtenerCuentas() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: obtenerSubcuentas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func obtenerSubcuentas() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_TRAER_SUBCUENTAS)
        
        let params = ["CU":user.getSelectedCuenta()!,"NI":user.getUser()!,"TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerSubCuentasResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                let cuentasAux = resultado["Cuentas"] as! [JSONStandard]
                
                for cuenta in cuentasAux {
                    if(self.user.getSelectedCuenta()! == (cuenta["CU"] as! NSNumber).stringValue) {
                        self.subcuentas.append(cuenta)
                    }
                }
                
            }
            catch {
                
            }
        }
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
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_VERIFICAR_FAVORITA)
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "SC":(subcuentas[selectedSubcuenta]["CS"] as! NSNumber).stringValue, "TC":"P","NC":cuentaField.text!, "TK":user.getToken()!]
        // EJ: CR40015202946000161798
        // CR70015202001142490739
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["VerificaInformacionCuentaFavResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                
                if let respuesta = resultado["Respuesta"] as? JSONStandard {
                    
                    if(String(describing: respuesta["CodMensaje"]!) != "0") {
                        self.showAlert(title: "", message: respuesta["Mensajes"] as! String)
                    }
                    else if let contenido = resultado["Contenido"] as? JSONStandard {
                        
                        self.favorita = contenido
                        
                        self.numCuentaLabel.text = contenido["CC"] as? String
                        self.nombreCuentaLabel.text = (contenido["NO"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.entidadCuentaLabel.text = contenido["NE"] as? String
                        self.monedaCuentaLabel.text = contenido["MO"] as? String
                        
                        self.cuentaView.isHidden = false
                    }
                }
                
                
                
            }
            catch {
                
            }
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
        
        let moned = monedaCuentaLabel.text! == "Colones" ? "COL" : "DOL"
        
        params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":tipo, "CC":numCuentaLabel.text!,"NO":nombreCuentaLabel.text!,"MO":moned,"CE":(favorita["CE"] as! NSNumber).stringValue,"CO":"Correo", "TK":user.getToken()!]
        if(tipo == "B") {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            let fecha = format.string(from: Date())
            
            let detallesDispositivo = "Apple " + UIDevice.current.model + " " + UIDevice.current.systemVersion
            
            
            let DV = ["DI":detallesDispositivo,"FE":fecha]
            params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":tipo, "CC":numCuentaLabel.text!, "IT":favorita["IC"] as! String, "NO":nombreCuentaLabel.text!, "MO":moned,"CE":(favorita["CE"] as! NSNumber).stringValue, "DV":DV, "TK":user.getToken()!]
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
                        
                        let alertSuccess = UIAlertController(title: "Éxito", message: respuesta["Mensajes"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction (title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                            self.navigationController?.popViewController(animated: true)
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
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var result = 0
        if tipoPicker == 1 {
            result = subcuentas.count
        }
        else {
            result = tipoCuentas.count
        }
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        if tipoPicker == 1 {
            let cuenta = subcuentas[row]
            result = cuenta["NC"] as! String
        }
        else {
            result = tipoCuentas[row]
        }
        return result
    }
    

}
