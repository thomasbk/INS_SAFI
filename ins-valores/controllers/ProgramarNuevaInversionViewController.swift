//
//  ProgramarNuevaInversionViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/27/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class ProgramarNuevaInversionViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {

    typealias JSONStandard = Dictionary<String, Any>
    
    var user: User!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cancelarButton: UIButton!
    @IBOutlet weak var aceptarButton: UIButton!
    @IBOutlet weak var aceptarHuellaButton: UIButton!
    
    
    @IBOutlet weak var subcuentasButton: UIButton!
    @IBOutlet weak var fondosButton: UIButton!
    @IBOutlet weak var cuentasButton: UIButton!
    @IBOutlet weak var frecuenciasButton: UIButton!
    @IBOutlet weak var diasButton: UIButton!
    @IBOutlet weak var sinFechaButton: UIButton!
    
    @IBOutlet weak var fechaInicioButton: UIButton!
    @IBOutlet weak var fechaFinButton: UIButton!
    
    @IBOutlet weak var descripcionField: UITextField!
    @IBOutlet weak var montoField: UITextField!
    @IBOutlet weak var fechaInicioField: UITextField!
    @IBOutlet weak var fechaFinField: UITextField!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var tipoPicker = 1
    
    var subcuentas = [JSONStandard]()
    var fondos = [JSONStandard]()
    var cuentas = [JSONStandard]()
    var frecuencias = [JSONStandard]()
    var dias = [JSONStandard]()
    var selectedSubcuenta = -1
    var selectedFondo = -1
    var selectedCuenta = -1
    var selectedFrecuencia = -1
    var selectedDia = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        obtenerSubcuentas()
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: aceptarButton.frame.origin.y + 80)
        
        hideKeyboardWhenTappedAround()
        
        let context = LAContext()
        var error: NSError?
        
        if (!context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || !UserDefaults.standard.bool(forKey: "TransaccionTouchID")) {
            aceptarHuellaButton.isHidden = true
            
            aceptarButton.center = CGPoint(x:aceptarHuellaButton.center.x, y:aceptarHuellaButton.center.y)
        }
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "seleccionarCorreoSegue") {
            let vc = segue.destination as! SeleccionarCorreoViewController
            vc.solicitudProgramada = getJSONSolicitud(isTouch: false)
        }
    }
    
    
    @IBAction func sinFechaAction(_ sender: Any) {
        if(sinFechaButton.isSelected) {
            sinFechaButton.isSelected = false
        }
        else {
            sinFechaButton.isSelected = true
            fechaFinField.text = ""
        }
    }
    
    
    @IBAction func cancelarAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func aceptarAction(_ sender: Any) {
        if( selectedSubcuenta > -1 && selectedFondo > -1 && selectedCuenta > -1 && selectedFrecuencia > -1 && selectedDia > -1 && (fechaInicioField.text?.count)! > 0 && (sinFechaButton.isSelected || (fechaFinField.text?.count)! > 0) && (descripcionField.text?.count)! > 0 && (montoField.text?.count)! > 0) {
            
            if( Double(montoField.text!)! > 0) {
                
                performSegue(withIdentifier: "seleccionarCorreoSegue", sender: nil)
            }
            else {
                showAlert(title: "Información incompleta", message: "Debe ingresar un monto mayor a 0")
            }
        }
        else {
            showAlert(title: "Información incompleta", message: "Todos los campos son requeridos")
        }
    }
    
    @IBAction func aceptarHuellaAction(_ sender: Any) {
        
        if( selectedSubcuenta > -1 && selectedFondo > -1 && selectedCuenta > -1 && selectedFrecuencia > -1 && selectedDia > -1 && (fechaInicioField.text?.count)! > 0 && (sinFechaButton.isSelected || (fechaFinField.text?.count)! > 0) && (descripcionField.text?.count)! > 0 && (montoField.text?.count)! > 0) {
            
            if( Double(montoField.text!)! > 0) {
                
                let context = LAContext()
                var error: NSError?
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    
                    let reason = "Valide la acción con su huella"
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                        {(success, error) in
                            if success {
                                self.grabarInversion()
                            }
                            else {
                                
                            }
                    })
                }
                else {
                    // Not available
                    
                }
            }
            else {
                showAlert(title: "Información incompleta", message: "Debe ingresar un monto mayor a 0")
            }
        }
        else {
            showAlert(title: "Información incompleta", message: "Todos los campos son requeridos")
        }
    }

    @IBAction func seleccionarSubcuenta(_ sender: Any) {
        tipoPicker = 1
        pickerView.reloadAllComponents()
        pickerView.selectRow(selectedSubcuenta, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
    }
    @IBAction func seleccionarFondo(_ sender: Any) {
        
        if fondos.count > 0 && selectedSubcuenta > -1 {
            tipoPicker = 2
            pickerView.reloadAllComponents()
            pickerView.selectRow(selectedFondo, inComponent: 0, animated: false)
            pickerViewBack.isHidden = false
        }
    }
    @IBAction func seleccionarCuenta(_ sender: Any) {
        if cuentas.count > 0 {
            tipoPicker = 3
            pickerView.reloadAllComponents()
            pickerView.selectRow(selectedCuenta, inComponent: 0, animated: false)
            pickerViewBack.isHidden = false
        }
    }
    @IBAction func seleccionarFrecuencia(_ sender: Any) {
        if frecuencias.count > 0 {
        tipoPicker = 4
        pickerView.reloadAllComponents()
        pickerView.selectRow(selectedFrecuencia, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
        }
    }
    @IBAction func seleccionarDia(_ sender: Any) {
        if dias.count > 0 {
        tipoPicker = 5
        pickerView.reloadAllComponents()
        pickerView.selectRow(selectedDia, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
        }
    }
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        switch tipoPicker {
        case 1:
            selectedSubcuenta = pickerView.selectedRow(inComponent: 0)
            subcuentasButton.setTitle(subcuentas[selectedSubcuenta]["NC"] as? String, for: .normal)
            obtenerFondos()
        case 2:
            selectedFondo = pickerView.selectedRow(inComponent: 0)
            fondosButton.setTitle(fondos[selectedFondo]["FO"] as? String, for: .normal)
            obtenerCuentasBancarias()
        case 3:
            selectedCuenta = pickerView.selectedRow(inComponent: 0)
            cuentasButton.setTitle(cuentas[selectedCuenta]["CC"] as? String, for: .normal)
        case 4:
            selectedFrecuencia = pickerView.selectedRow(inComponent: 0)
            frecuenciasButton.setTitle(frecuencias[selectedFrecuencia]["DF"] as? String, for: .normal)
            obtenerDias()
        case 5:
            selectedDia = pickerView.selectedRow(inComponent: 0)
            diasButton.setTitle(dias[selectedDia]["DD"] as? String, for: .normal)
        default:
            selectedSubcuenta = pickerView.selectedRow(inComponent: 0)
            subcuentasButton.setTitle(subcuentas[selectedSubcuenta]["NC"] as? String, for: .normal)
        }
    }
    
    
    
    
    
    
    @IBAction func selectDate(_ sender: Any) {
        let button = sender as! UIButton
        let date = Date()
        //let currentDate = date.addingTimeInterval(-1*24*60*60)
        let currentDate = date
        //let tenYearsAgo = date.addingTimeInterval(-10*365*24*60*60)
        let inTenYears = date.addingTimeInterval(10*365*24*60*60)
        
        let dialog = LSLDatePickerDialog()
        
        dialog.show(withTitle: "Seleccionar fecha", subtitle: "", doneButtonTitle: "Aceptar", cancelButtonTitle: "Cancelar", defaultDate: currentDate, minimumDate: currentDate, maximumDate: inTenYears, datePickerMode: UIDatePickerMode.date) { (date) in
            
            if(date != nil) {
                let format = DateFormatter()
                format.dateFormat = "dd/MM/yyyy"
                let nsstr = format.string(from: date!)
                
                if(button == self.fechaInicioButton) {
                    self.fechaInicioField.text = nsstr
                }
                else {
                    self.fechaFinField.text = nsstr
                }
            }
        }
    }
    
    
    
    
    
    func obtenerSubcuentas() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getSubcuentas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func getSubcuentas() {
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
                //self.getFondos()
            }
            catch {
                
            }
        }
    }
    
    func obtenerFondos() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getFondos)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getFondos() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_FONDOS_CUENTA)
        
        let params = ["CU":user.getSelectedCuenta()!,"SC":(subcuentas[selectedSubcuenta]["CS"] as! NSNumber).stringValue, "TS":"P","TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            //self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerFondosCuentaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.fondos = contenido
                }
                
                //self.getCuentasBancarias()
                
                self.getFrecuencias()
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
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_CUENTAS_FAVORITAS)
        let moneda = fondos[selectedFondo]["MO"] as! String
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "SC":(subcuentas[selectedSubcuenta]["CS"] as! NSNumber).stringValue, "MO":moneda, "TK":user.getToken()!]
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerCuentasFavoritasResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["CuentasFavoritas"] as? [JSONStandard] {
                    self.cuentas = contenido
                }
                
                
            }
            catch {
                
            }
        }
    }
    
    
    
    func getFrecuencias() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_FRECUENCIA_INVERSION)
        
        
        let params = ["TC":"F","TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerFrecInvProgResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.frecuencias = contenido
                }
            }
            catch {
                
            }
        }
        
    }
    
    
    
    func obtenerDias() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getDias)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func getDias() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_FRECUENCIA_INVERSION)
        
        //TC :- Tipo de consulta (F – Frecuencias, D -Día de aplicación)
        //TF:- Tipo de consulta (S-Semanal,B-Bisemanal,Q-Quincenal,M-Mensual)
        
        let params = ["TC":"D", "TF":frecuencias[selectedFrecuencia]["TF"] as! String, "TK":user.getToken()!]
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerFrecInvProgResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.dias = contenido
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    
    
    func grabarInversion() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: setInversion)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func setInversion() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_INVERSION)
        
        
        let params:JSONStandard = getJSONSolicitud(isTouch: true)
        
        //var params:[String:String]
        
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["GrabarInversionProgramadaResult"] as! String
            
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
                        self.regresar()
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
    
    
    func getJSONSolicitud(isTouch:Bool) -> JSONStandard {
        var params:JSONStandard = ["TV":"C","CU":user.getSelectedCuenta()!,"NI":user.getUser()!,"CF":(fondos[selectedFondo]["CF"] as! NSNumber).stringValue, "SC":(subcuentas[selectedSubcuenta]["CS"] as! NSNumber).stringValue, "DP":descripcionField.text!, "MP":montoField.text!, "CC":cuentas[selectedCuenta]["CC"] as! String, "BD":(cuentas[selectedCuenta]["CE"] as! NSNumber).stringValue,"FI":fechaInicioField.text!,"FP":frecuencias[selectedFrecuencia]["TF"] as! String, "DA":dias[selectedDia]["VD"] as! String, "CO":"", "TK":user.getToken()!]
        
        if(!(sinFechaButton.isSelected)) {
            params["FF"] = fechaFinField.text!
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
    
    func regresar() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var result = 0
        
        switch tipoPicker {
        case 1:
            result = subcuentas.count
        case 2:
            result = fondos.count
        case 3:
            result = cuentas.count
        case 4:
            result = frecuencias.count
        case 5:
            result = dias.count
        default:
            result = subcuentas.count
        }
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        switch tipoPicker {
        case 1:
            let cuenta = subcuentas[row]
            result = cuenta["NC"] as! String
        case 2:
            let fondo = fondos[row]
            result = fondo["FO"] as! String
        case 3:
            let cuenta = cuentas[row]
            result = cuenta["CC"] as! String
        case 4:
            let frecuencia = frecuencias[row]
            result = frecuencia["DF"] as! String
        case 5:
            let dia = dias[row]
            result = dia["DD"] as! String
        default:
            let cuenta = subcuentas[row]
            result = cuenta["NC"] as! String
        }
        return result
    }

}
