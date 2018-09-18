//
//  SolicitudVencimientoViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/23/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class SolicitudVencimientoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var vencimiento:JSONStandard!
    var cuentasBancarias = [JSONStandard]()
    var fondos = [JSONStandard]()
    
    enum TiposSolicitud {
        case reinvertir, vista, cuenta
    }
    var tipoSolicitud = TiposSolicitud.reinvertir
    
    var vistaY:CGFloat!
    var cuentaY:CGFloat!
    
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var fondoLabel: UILabel!
    @IBOutlet weak var fechaVencimientoLabel: UILabel!
    @IBOutlet weak var fechaGraciaLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var monedaLabel: UILabel!
    
    
    @IBOutlet weak var reinvertirTextfield: UITextField!
    @IBOutlet weak var reinvertirButton: UIButton!
    @IBOutlet weak var reinvertirOptionButton: UIButton!
    
    @IBOutlet weak var trasladarVistaTextfield: UITextField!
    @IBOutlet weak var trasladarVistaButton: UIButton!
    @IBOutlet weak var trasladarVistaOptionButton: UIButton!
    @IBOutlet weak var fondosLabel: UILabel!
    @IBOutlet weak var fondosButton: comboBoxButton!
    
    
    @IBOutlet weak var trasladarCuentaTextfield: UITextField!
    @IBOutlet weak var trasladarCuentaButton: UIButton!
    @IBOutlet weak var trasladarCuentaOptionButton: UIButton!
    @IBOutlet weak var cuentasLabel: UILabel!
    @IBOutlet weak var cuentasButton: comboBoxButton!
    
    @IBOutlet weak var aceptarButton: UIButton!
    @IBOutlet weak var aceptarHuellaButton: UIButton!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    var tipoPicker = 1
    
    var selectedFondo = -1
    var selectedCuenta = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        let context = LAContext()
        var error: NSError?
        if (!context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || !UserDefaults.standard.bool(forKey: "TransaccionTouchID")) {
            aceptarHuellaButton.isHidden = true
            aceptarButton.center = CGPoint(x:self.view.center.x, y:aceptarButton.center.y)
        }
        
        trasladarVistaButton.titleLabel?.lineBreakMode = .byWordWrapping
        trasladarVistaButton.titleLabel?.numberOfLines = 2
        trasladarCuentaButton.titleLabel?.lineBreakMode = .byWordWrapping
        trasladarCuentaButton.titleLabel?.numberOfLines = 2
        
        
        nombreCuentaLabel.text = vencimiento["NC"] as? String
        fondoLabel.text = vencimiento["FO"] as? String
        fechaVencimientoLabel.text = vencimiento["FV"] as? String
        fechaGraciaLabel.text = vencimiento["FG"] as? String
        montoLabel.text = (vencimiento["MR"] as! NSNumber).formatAmount()
        monedaLabel.text = vencimiento["MO"] as? String
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vistaY = trasladarVistaButton.center.y
        cuentaY = trasladarCuentaButton.center.y
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
            vc.vencimiento = getJSONSolicitud(isTouch: false)
        }
    }
    
    
    
    
    @IBAction func reinvertirAction(_ sender: Any) {
        tipoSolicitud = .reinvertir
        fondosLabel.isHidden = true
        fondosButton.isHidden = true
        cuentasLabel.isHidden = true
        cuentasButton.isHidden = true
        
        reinvertirOptionButton.isSelected = true
        trasladarVistaOptionButton.isSelected = false
        trasladarCuentaOptionButton.isSelected = false
        
        trasladarCuentaButton.center = CGPoint(x:trasladarCuentaButton.center.x, y:cuentaY)
        trasladarCuentaTextfield.center = CGPoint(x:trasladarCuentaTextfield.center.x, y:cuentaY)
        trasladarCuentaOptionButton.center = CGPoint(x:trasladarCuentaOptionButton.center.x, y:cuentaY)
        
        reinvertirTextfield.text = (vencimiento["MR"] as! NSNumber).formatAmount()
        trasladarVistaTextfield.text = ""
        trasladarCuentaTextfield.text = ""
    }
    
    @IBAction func trasladarVistaAction(_ sender: Any) {
        tipoSolicitud = .vista
        fondosLabel.isHidden = false
        fondosButton.isHidden = false
        cuentasLabel.isHidden = true
        cuentasButton.isHidden = true
        
        reinvertirOptionButton.isSelected = false
        trasladarVistaOptionButton.isSelected = true
        trasladarCuentaOptionButton.isSelected = false
        
        trasladarCuentaButton.center = CGPoint(x:trasladarCuentaButton.center.x, y:cuentaY+54)
        trasladarCuentaTextfield.center = CGPoint(x:trasladarCuentaTextfield.center.x, y:cuentaY+54)
        trasladarCuentaOptionButton.center = CGPoint(x:trasladarCuentaOptionButton.center.x, y:cuentaY+54)
        
        trasladarVistaTextfield.text = (vencimiento["MR"] as! NSNumber).formatAmount()
        reinvertirTextfield.text = ""
        trasladarCuentaTextfield.text = ""
        
        if (fondos.count == 0) {
            obtenerFondos()
        }
    }
    
    @IBAction func trasladarCuentaAction(_ sender: Any) {
        tipoSolicitud = .cuenta
        fondosLabel.isHidden = true
        fondosButton.isHidden = true
        cuentasLabel.isHidden = false
        cuentasButton.isHidden = false
        
        reinvertirOptionButton.isSelected = false
        trasladarVistaOptionButton.isSelected = false
        trasladarCuentaOptionButton.isSelected = true
        
        trasladarCuentaButton.center = CGPoint(x:trasladarCuentaButton.center.x, y:cuentaY)
        trasladarCuentaTextfield.center = CGPoint(x:trasladarCuentaTextfield.center.x, y:cuentaY)
        trasladarCuentaOptionButton.center = CGPoint(x:trasladarCuentaOptionButton.center.x, y:cuentaY)
        
        trasladarCuentaTextfield.text = (vencimiento["MR"] as! NSNumber).formatAmount()
        reinvertirTextfield.text = ""
        trasladarVistaTextfield.text = ""
        
        if (cuentasBancarias.count == 0) {
            obtenerCuentasBancarias()
        }
        
    }
    
    
    @IBAction func seleccionarFondo(_ sender: Any) {
        let selected = selectedFondo >= 0 ? selectedFondo : 0
        tipoPicker = 1
        pickerView.reloadAllComponents()
        pickerView.selectRow(selected, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
    }
    @IBAction func seleccionarCuenta(_ sender: Any) {
        let selected = selectedCuenta >= 0 ? selectedCuenta : 0
        tipoPicker = 2
        pickerView.reloadAllComponents()
        pickerView.selectRow(selected, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
    }
    
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        if tipoPicker == 1 {
            selectedFondo = pickerView.selectedRow(inComponent: 0)
            fondosButton.setTitle(fondos[selectedFondo]["FO"] as? String, for: .normal)
        }
        else if tipoPicker == 2 {
            selectedCuenta = pickerView.selectedRow(inComponent: 0)
            cuentasButton.setTitle(cuentasBancarias[selectedCuenta]["NC"] as? String, for: .normal)
        }
    }
    
    
    
    @IBAction func aceptarAction(_ sender: Any) {
        
        performSegue(withIdentifier: "seleccionarCorreoSegue", sender: nil)
    }
    
    @IBAction func aceptarHuellaAction(_ sender: Any) {
        
        if( (tipoSolicitud == .reinvertir && (reinvertirTextfield.text?.count)! > 0) || (tipoSolicitud == .vista && selectedFondo > -1)  || (tipoSolicitud == .cuenta && selectedCuenta > -1)) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Valide la acción con su huella"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.grabarVencimiento()
                    }
                    else {
                        
                    }
            })
        }
            
        else {
            // Not available
            
        }
        }
    }
    
    
    
    
    func grabarVencimiento() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: setVencimiento)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func setVencimiento() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_VENCIMIENTO)
        
        let params:JSONStandard = getJSONSolicitud(isTouch: true)
        
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["GrabarInstruccionVencimientoResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                let respuesta = resultado["Respuesta"] as! JSONStandard
                
                self.showAlert(title: "", message: respuesta["Mensajes"] as! String)
            
                
            }
            catch {
                
            }
        }
    }
    
    
    func getJSONSolicitud(isTouch:Bool) -> JSONStandard {
        var params:JSONStandard
        
        switch tipoSolicitud {
        case .reinvertir:
            params = ["TV":"C", "NI":user.getUser()!,"CF":(vencimiento["CF"] as! NSNumber).stringValue,"NO":(vencimiento["NO"] as! NSNumber).stringValue, "CU":user.getSelectedCuenta()!, "SC":(vencimiento["SC"] as! NSNumber).stringValue, "OT":"I", "CO":"", "TK":user.getToken()!]
        case .vista:
            params = ["TV":"C", "NI":user.getUser()!,"CF":(vencimiento["CF"] as! NSNumber).stringValue,"NO":(vencimiento["NO"] as! NSNumber).stringValue, "CU":user.getSelectedCuenta()!, "SC":(vencimiento["SC"] as! NSNumber).stringValue, "OT":"T", "FI":(fondos[selectedFondo]["CF"] as! NSNumber).stringValue, "CO":"", "TK":user.getToken()!]
        case .cuenta:
            params = ["TV":"C", "NI":user.getUser()!,"CF":(vencimiento["CF"] as! NSNumber).stringValue,"NO":(vencimiento["NO"] as! NSNumber).stringValue, "CU":user.getSelectedCuenta()!, "SC":(vencimiento["SC"] as! NSNumber).stringValue, "OT":"R","MI":trasladarCuentaTextfield.text!,"CB":cuentasBancarias[selectedCuenta]["NC"] as! String, "CO":"", "TK":user.getToken()!]
        }
        
        if (isTouch)
        {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            let fecha = format.string(from: Date())
            
            let detallesDispositivo = "Apple " + UIDevice.current.model + " " + UIDevice.current.systemVersion
            
            let DV = ["DI":detallesDispositivo,"FE":fecha]
            
            params["DV"] = DV
            params["TV"] = "B"
        }
        
        return params
    }
    
    
    
    
    
    func obtenerFondos() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: traerFondosCuentas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func traerFondosCuentas() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_FONDOS_CUENTA)
        
        let moneda = (vencimiento["MO"] as! String) == "Colones" ? "COL" : "DOL"
        let params = ["CU":user.getSelectedCuenta()!,"MO":moneda,"SC":"0","TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerFondosCuentaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.fondos = contenido
                }
            }
            catch {
                
            }
        }
        
    }
    
    
    
    
    
    func obtenerCuentasBancarias() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getCuentasBancarias)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getCuentasBancarias() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_TRAER_BANCARIAS)
        let moneda = (vencimiento["MO"] as! String) == "Colones" ? "COL" : "DOL"
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "SC":(vencimiento["SC"] as! NSNumber).stringValue, "MO":moneda, "TK":user.getToken()!]
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerCuentasBancariasRetiroResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Resultado"] as? [JSONStandard] {
                    self.cuentasBancarias = contenido
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
            result = fondos.count
        }
        else if tipoPicker == 2 {
            result = cuentasBancarias.count
        }
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        if tipoPicker == 1 {
            let fondo = fondos[row]
            result = fondo["FO"] as! String
        }
        else if tipoPicker == 2 {
            let cuenta = cuentasBancarias[row]
            result = cuenta["NC"] as! String
        }
        return result
    }
    

}
