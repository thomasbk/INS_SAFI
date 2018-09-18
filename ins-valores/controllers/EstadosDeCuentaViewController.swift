//
//  EstadosDeCuentaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 6/28/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
import PDFKit

class EstadosDeCuentaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var cuentasButton: comboBoxButton!
    @IBOutlet weak var fondosButton: comboBoxButton!
    
    
    @IBOutlet weak var generarTodasButton: UIButton!
    
    var generarTodas = false
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    var tipoPicker = 1
    
    
    var user: User!
    
    var subcuentas:[JSONStandard] = [JSONStandard]()
    var fondos:[JSONStandard] = [JSONStandard]()
    
    var listaEstados = [JSONStandard]()
    
    var selectedCuenta = -1
    var selectedFondo = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
        obtenerCuentas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func selectDate(_ sender: Any) {
        let date = Date()
        let currentDate = date
        let tenYearsAgo = date.addingTimeInterval(-10*365*24*60*60)
        
        let dialog = LSLDatePickerDialog()
        
        dialog.show(withTitle: "Seleccionar fecha", subtitle: "No se pueden seleccionar fechas futuras", doneButtonTitle: "Aceptar", cancelButtonTitle: "Cancelar", defaultDate: currentDate, minimumDate: tenYearsAgo, maximumDate: currentDate, datePickerMode: UIDatePickerMode.date) { (date) in
            
            if(date != nil) {
                let format = DateFormatter()
                format.dateFormat = "dd/MM/yyyy"
                let nsstr = format.string(from: date!)
                
                self.dateTextField.text = nsstr
                
                self.checkEverythingSelected()
            }
        }
    }
    
    
    
    
    @IBAction func seleccionarCliente(_ sender: Any) {
        let selected = selectedCuenta >= 0 ? selectedCuenta : 0
        tipoPicker = 1
        pickerView.reloadAllComponents()
        pickerView.selectRow(selected, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
    }
    @IBAction func seleccionarFondo(_ sender: Any) {
        if(fondos.count > 0) {
        let selected = selectedFondo >= 0 ? selectedFondo : 0
        tipoPicker = 2
        pickerView.reloadAllComponents()
        pickerView.selectRow(selected, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
        }
    }
    
    
    func checkEverythingSelected () {
        
        var result = false
        if(dateTextField.text != "") {
            result = true
        }
        if(selectedCuenta < 0 || selectedFondo < 0) {
            result = false
        }
        
        if(result) {
            obtenerResumen()
        }
    }
    
    @IBAction func generarTodasSubcuentasAction(_ sender: Any) {
        
        if(generarTodas) {
            generarTodas = false
            generarTodasButton.isSelected = false
        }
        else {
            generarTodas = true
            generarTodasButton.isSelected = true
        }
        checkEverythingSelected()
    }
    
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        if tipoPicker == 1 {
            selectedCuenta = pickerView.selectedRow(inComponent: 0)
            cuentasButton.setTitle(subcuentas[selectedCuenta]["NC"] as? String, for: .normal)
            obtenerFondos()
        }
        else if tipoPicker == 2 {
            selectedFondo = pickerView.selectedRow(inComponent: 0)
            fondosButton.setTitle(fondos[selectedFondo]["FO"] as? String, for: .normal)
        }
        checkEverythingSelected()
    }
    
    
    @IBAction func descargarEstadoCuenta(_ sender: Any) {
        if(selectedCuenta > -1 && selectedFondo > -1) {
            obtenerPDF()
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
                
                //if let contenido = resultado["Contenido"] as? JSONStandard {
                
                self.subcuentas.removeAll()
                let listaCuentas = resultado["Cuentas"] as! [JSONStandard]
                
                for cuenta in listaCuentas {
                    if(self.user.getSelectedCuenta()! == (cuenta["CU"] as! NSNumber).stringValue) {
                        self.subcuentas.append(cuenta)
                    }
                }
                
                //self.obtenerFondos()
                //self.traerFondosCuentas()
                
                
                /*
                    self.subcuentas = resultado["Cuentas"] as! [JSONStandard]
                    
                    var cuentasOptions = [String]()
                    for cuenta in self.subcuentas {
                        if(self.user.getSelectedCuenta()! == (cuenta["CU"] as! NSNumber).stringValue) {
                        cuentasOptions.append((cuenta["CS"] as! NSNumber).stringValue)
                        }
                    }
                //}
                */
                
                
            }
            catch {
                
            }
        }
    }
    
    
    // Obtener Resumen de Estado de Cuenta
    
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
        
        let params = ["CU":user.getSelectedCuenta()!,"SC":(subcuentas[selectedCuenta]["CS"] as! NSNumber).stringValue, "TS":"E", "TK":user.getToken()!]
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
                    
                    let todos = ["FO":"Todos los fondos" as Any]
                    
                    self.fondos.insert(todos, at: 0)
                    
                    //var fondosOptions = [String]()
                    //for fondo in self.fondos {
                    //    fondosOptions.append((fondo["CF"] as! NSNumber).stringValue)
                    //}
                    
                }
            }
            catch {
                
            }
        }
        
    }
    
    
    
    
    // Obtener Resumen de Estado de Cuenta
    
    func obtenerResumen() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: obtenerResumenEstadoCuenta)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func obtenerResumenEstadoCuenta() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_RESUMEN_ESTADO_DE_CUENTA)
        
        var params = ["CU":user.getSelectedCuenta()!,"SC":(subcuentas[selectedCuenta]["CS"] as! NSNumber).stringValue, "FE":dateTextField.text!, "TK":user.getToken()!]
        if(generarTodas) {
            params = ["CU":user.getSelectedCuenta()!,"FE":dateTextField.text!, "TK":user.getToken()!]
        }
        if(selectedFondo > 0) {
            params["CF"] = (fondos[selectedFondo]["CF"] as! NSNumber).stringValue
        }
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerResumenEstadoDeCuentaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    
                    self.listaEstados = contenido
                    
                    self.tableView.reloadData()
                    
                    if(self.listaEstados.count == 0) {
                        self.showAlert(title: "", message: "No se encontraron resultados en esta consulta")
                    }
                }
            }
            catch {
                
            }
        }
        
    }
    
    
    // Descargar y mostrar PDF
    
    func obtenerPDF() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: descargarPDF)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func descargarPDF() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_ESTADO_DE_CUENTA)
        
        //let params = ["NI":user.getUser()!,"CU":user.getSelectedCuenta()!,"SC":"\(selectedCuenta)","FE":dateTextField.text!,"CF":"\(selectedFondo)","TK":user.getToken()!]
        
        var params = ["NI":user.getUser()!,"CU":user.getSelectedCuenta()!,"SC":(subcuentas[selectedCuenta]["CS"] as! NSNumber).stringValue,"FE":dateTextField.text!,"TK":user.getToken()!]
        
        if(selectedFondo > 0) {
            params["CF"] = (fondos[selectedFondo]["CF"] as! NSNumber).stringValue
        }
        
        /*if(generarTodas) {
            params = ["NI":user.getUser()!,"CU":user.getSelectedCuenta()!, "FE":dateTextField.text!,"CF":(fondos[selectedFondo]["CF"] as! NSNumber).stringValue,"TK":user.getToken()!]
        }*/
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerEstadoDeCuentaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                //print(dataDictionary)
                
                if let resultado = dataDictionary["Resultado"] as? String
                {
                    print(resultado)
                
                    self.saveBase64StringToPDF(resultado)
                }
                
                
            }
            catch {
                
            }
        }
        
    }
    
    
    func saveBase64StringToPDF(_ base64String: String) {
        
        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
                //handle error when getting documents URL
                return
        }
        
        //name your file however you prefer
        documentsURL.appendPathComponent("yourFileName.pdf")
        
        do {
            try convertedData.write(to: documentsURL)
        } catch {
            //handle write error here
        }
        
        //if you want to get a quick output of where your
        //file was saved from the simulator on your machine
        //just print the documentsURL and go there in Finder
        print(documentsURL)
        
        let webView = UIWebView(frame: self.view.frame)
        webView.loadRequest(NSURLRequest(url: documentsURL) as URLRequest)
        webView.scalesPageToFit = true
        
        let viewController = UIViewController()
        viewController.view.addSubview(webView)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaEstados.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "estadosCell") as! EstadosCell
        
        let fondo = listaEstados[indexPath.row]
        
        cell.nombreFondoLabel.text = fondo["FO"] as? String
        cell.fechaCorteLabel.text = fondo["FC"] as? String
        cell.monedaLabel.text = fondo["MO"] as? String
        cell.saldoLabel.text = (fondo["MS"] as! NSNumber).formatAmount()
        cell.rendimientoLabel.text = (fondo["RE"] as? NSNumber)?.stringValue
        
        
        return cell
        
    }
    
    /// Stub for responding to user row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedCuenta = vencimientos[indexPath.row]
        //user.setSelectedCuenta(selectedCuenta.cId!)
        
        //performSegue(withIdentifier: "vencimientosSegue", sender: nil)
    }
    
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var result = 0
        if tipoPicker == 1 {
            result = subcuentas.count
        }
        else if tipoPicker == 2 {
            result = fondos.count
        }
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        if tipoPicker == 1 {
            let subcuenta = subcuentas[row]
            result = subcuenta["NC"] as! String
        }
        else if tipoPicker == 2 {
            let fondo = fondos[row]
            result = fondo["FO"] as! String
        }
        return result
    }
    
    

}


class EstadosCell: UITableViewCell {
    @IBOutlet weak var nombreFondoLabel: UILabel!
    @IBOutlet weak var fechaCorteLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var rendimientoLabel: UILabel!
    @IBOutlet weak var monedaLabel: UILabel!
    
}

