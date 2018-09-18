//
//  SolicitudRetiroViewController.swift
//  INSSAFI
//
//  Created by Novacomp on 7/23/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
import LocalAuthentication

class SolicitudRetiroViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var lblFechaValor: UITextField!
    @IBOutlet weak var lblSubCuenta: UITextField!
    @IBOutlet weak var lblFondo: UITextField!
    @IBOutlet weak var lblCuentaBancaria: UITextField!
    @IBOutlet weak var lblSaldo: UITextField!
    @IBOutlet weak var lblTipoRetiro: UITextField!
    @IBOutlet weak var lblMonto: UITextField!
    @IBOutlet weak var lblOrigen: UITextField!
    
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var agregarHuellaButton: UIButton!
    
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    typealias JSONStandard = Dictionary<String, Any>
    
    var user: User!
    
    var subcuentas:[JSONStandard] = [JSONStandard]()
    var fondos:[JSONStandard] = [JSONStandard]()
    var cuentasBancarias:[JSONStandard] = [JSONStandard]()
    var tiposRetiro:[String] = []
    
    var currentPickerDataType:String!
    
    var indexSubcuenta:Int!
    var indexFondo:Int!
    var indexCuentaBancaria:Int!
    var indexTipoRetiro:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        
        lblFechaValor.text = format.string(from: Date())
        
        currentPickerDataType = nil
        
        tiposRetiro.append("Parcial")
        tiposRetiro.append("Total")
        
        lblTipoRetiro.text = "Parcial"
        lblMonto.text = "0"
        
        lblSubCuenta.delegate = self
        lblFondo.delegate = self
        lblCuentaBancaria.delegate = self
        lblTipoRetiro.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        let context = LAContext()
        var error: NSError?
        if (!context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) || !UserDefaults.standard.bool(forKey: "TransaccionTouchID")) {
            agregarHuellaButton.isHidden = true
            
            agregarButton.center = CGPoint(x:self.view.center.x, y:agregarButton.center.y)
        }
        
        
        lblFechaValor.makeBlue()
        lblSubCuenta.makeBlue()
        lblFondo.makeBlue()
        lblSaldo.makeBlue()
        lblTipoRetiro.makeBlue()
        lblCuentaBancaria.makeBlue()
        
        lblMonto.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lblMonto.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
        lblMonto.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        obtenerCuentas()
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
                self.view.frame.origin.y = 0
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (currentPickerDataType == "SubCuenta")
        {
            return subcuentas.count
        }
        else if (currentPickerDataType == "Fondo")
        {
            return fondos.count
        }
        else if (currentPickerDataType == "CuentaBancaria")
        {
            return cuentasBancarias.count
        }
        else if (currentPickerDataType == "TipoRetiro")
        {
            return 2
        }
        else
        {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 14)
            pickerLabel?.textAlignment = .center
        }
        
        if (currentPickerDataType == "SubCuenta")
        {
            pickerLabel?.text = subcuentas[row]["NC"] as? String
        }
        else if (currentPickerDataType == "Fondo")
        {
            pickerLabel?.text = fondos[row]["FO"] as? String
        }
        else if (currentPickerDataType == "CuentaBancaria")
        {
            pickerLabel?.text = cuentasBancarias[row]["NC"] as? String
        }
        else if (currentPickerDataType == "TipoRetiro")
        {
            pickerLabel?.text = tiposRetiro[row]
        }
        
        return pickerLabel!
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
            //self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerSubCuentasResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                self.subcuentas = resultado["Cuentas"] as! [JSONStandard]
                
                if (self.subcuentas.count > 0)
                {
                    self.indexSubcuenta = 0
                    self.lblSubCuenta.text = self.subcuentas[0]["NC"] as? String
                    
                    //self.obtenerFondos()
                    self.traerFondosCuentas()
                }
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
            present(alert!, animated: true, completion: traerFondosCuentas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func traerFondosCuentas() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_FONDOS_CUENTA)
        
        let params = ["CU":user.getSelectedCuenta()!,"SC":String(describing: subcuentas[indexSubcuenta]["CS"] as! Int),"TS":"R","TK":user.getToken()!]
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
                    
                    if (self.fondos.count > 0)
                    {
                        self.indexFondo = 0
                        self.lblFondo.text = self.fondos[0]["FO"] as? String
                        self.lblSaldo.text = (self.fondos[0]["MS"] as! NSNumber).formatAmount()
                        
                        //self.obtenerCuentasBancarias()
                        self.getCuentasBancarias()
                    }
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
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_CUENTAS_BANCARIAS_RETIRO)
        
        let params = ["CU":user.getSelectedCuenta()!, "SC":String(describing: subcuentas[indexSubcuenta]["CS"] as! Int), "NI":user.getUser()!,"MO":fondos[indexFondo]["MO"] as! String, "TK":user.getToken()!]
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
                
                self.cuentasBancarias = resultado["Resultado"] as! [JSONStandard]
                
                if (self.cuentasBancarias.count > 0)
                {
                    self.indexCuentaBancaria = 0
                    self.lblCuentaBancaria.text = self.cuentasBancarias[0]["NC"] as? String
                }
            }
            catch {
                
            }
        }
    }
    
    @IBAction func btnCancelPicker(_ sender: UIBarButtonItem) {
        viewPicker.isHidden = true
    }
    
    @IBAction func btnOKPicker(_ sender: UIBarButtonItem) {
        if (currentPickerDataType == "SubCuenta")
        {
            indexSubcuenta = pickerView.selectedRow(inComponent: 0)
            
            lblSubCuenta.text = subcuentas[indexSubcuenta]["NC"] as? String
            
            obtenerFondos()
        }
        else if (currentPickerDataType == "Fondo")
        {
            indexFondo = pickerView.selectedRow(inComponent: 0)
            
            lblFondo.text = fondos[indexFondo]["FO"] as? String
            lblSaldo.text = String(describing: fondos[indexFondo]["MS"]! as! NSNumber)
            
            if (indexTipoRetiro == 0)
            {
                lblMonto.text = "0"
            }
            else
            {
                lblMonto.text = lblSaldo.text
            }
            
            obtenerCuentasBancarias()
        }
        else if (currentPickerDataType == "CuentaBancaria")
        {
            indexCuentaBancaria = pickerView.selectedRow(inComponent: 0)
            
            lblCuentaBancaria.text = cuentasBancarias[indexCuentaBancaria]["NC"] as? String
        }
        else if (currentPickerDataType == "TipoRetiro")
        {
            indexTipoRetiro = pickerView.selectedRow(inComponent: 0)
            
            lblTipoRetiro.text = tiposRetiro[indexTipoRetiro]
            
            if (indexTipoRetiro == 0)
            {
                lblMonto.text = "0"
                lblMonto.isEnabled = true
            }
            else
            {
                lblMonto.text = lblSaldo.text
                lblMonto.isEnabled = false
            }
        }
        
        viewPicker.isHidden = true
    }
    
    
    @IBAction func lblSubCuentaTap(_ sender: Any) {
        currentPickerDataType = "SubCuenta"
        
        pickerView.reloadComponent(0)
        
        if (cuentasBancarias.count > 0)
        {
            pickerView.selectRow(indexSubcuenta, inComponent: 0, animated: false)
        }
        
        viewPicker.isHidden = false
    }
    
    @IBAction func lblFondoTap(_ sender: Any) {
        currentPickerDataType = "Fondo"
        
        pickerView.reloadComponent(0)
        
        if (cuentasBancarias.count > 0)
        {
            pickerView.selectRow(indexFondo, inComponent: 0, animated: false)
        }
        
        viewPicker.isHidden = false
    }
    
    @IBAction func lblCuentaBancariaTap(_ sender: Any) {
        currentPickerDataType = "CuentaBancaria"
        
        pickerView.reloadComponent(0)
        
        if (cuentasBancarias.count > 0)
        {
            pickerView.selectRow(indexCuentaBancaria, inComponent: 0, animated: false)
        }
        
        viewPicker.isHidden = false
    }
    
    @IBAction func lblTipoRetiroTap(_ sender: Any) {
        currentPickerDataType = "TipoRetiro"
        
        pickerView.reloadComponent(0)
        
        if (tiposRetiro.count > 0)
        {
            pickerView.selectRow(indexTipoRetiro, inComponent: 0, animated: false)
        }
        
        viewPicker.isHidden = false
    }
    
    @IBAction func agregarSolicitudCorreoAction() {
        if( (lblMonto.text?.count)! > 0 && (lblMonto.text?.count)! > 0) {
            
            if( Double(lblMonto.text!)! > 0) {
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
    
    @IBAction func agregarSolicitudHuellaAction () {
        
        if( (lblMonto.text?.count)! > 0 && (lblMonto.text?.count)! > 0) {
            
            if( Double(lblMonto.text!)! > 0) {
                
                let context = LAContext()
                var error: NSError?
                
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    
                    let reason = "Valide la acción con su huella"
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                        {(success, error) in
                            if success {
                                self.agregarSolicitud()
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
    
    func agregarSolicitud() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: {
                self.addSolicitud()
            })
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func addSolicitud() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_SOLICITUD)
        
        let params:JSONStandard = getJSONSolicitud(isTouch: true)
        
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["GrabarSolicitudesResult"] as! String
            
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
        var params:JSONStandard = ["TV":isTouch ? "B" : "C", "TS":"R", "NI":user.getUser()!, "CF":String(describing: fondos[indexFondo]["CF"] as! Int), "CU":user.getSelectedCuenta()!, "SC":String(describing: subcuentas[indexSubcuenta]["CS"] as! Int), "CC":String(describing: lblCuentaBancaria.text!),"CB":cuentasBancarias[indexCuentaBancaria]["CB"] as! String,"OR":lblOrigen.text!,"TR":indexTipoRetiro == 0 ? "P" : "T","MS":String(describing: lblMonto.text!),"TK":user.getToken()!]
        
        if (isTouch)
        {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            let fecha = format.string(from: Date())
            
            let detallesDispositivo = "Apple " + UIDevice.current.model + " " + UIDevice.current.systemVersion
            
            let DV = ["DI":detallesDispositivo,"FE":fecha]
            
            params["DV"] = DV
        }
        
        return params
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "seleccionarCorreoSegue") {
            let vc = segue.destination as! SeleccionarCorreoViewController
            vc.solicitud = getJSONSolicitud(isTouch: false)
        }
    }
    
    func regresar() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let removedCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        
        textField.text = textField.text!.trimmingCharacters(in: removedCharacters)
        
    }
    
    
    @objc func textFieldDidBegin(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidEnd(_ textField: UITextField) {
        if textField.text!.count > 0 {
            let removedCharacters = CharacterSet(charactersIn: "0123456789,.").inverted
            
            textField.text = textField.text!.trimmingCharacters(in: removedCharacters)
        }
    }
}
