//
//  ImpresionDeOrdenesViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/23/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class ImpresionDeOrdenesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate {

    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    //var clientes = [JSONStandard]()
    var subcuentas = [JSONStandard]()
    var fondos = [JSONStandard]()
    var ordenes = [JSONStandard]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fechaInicioButton: UIButton!
    @IBOutlet weak var fechaFinButton: UIButton!
    @IBOutlet weak var fechaInicioField: UITextField!
    @IBOutlet weak var fechaFinField: UITextField!
    
    @IBOutlet weak var codigoClienteButton: comboBoxButton!
    @IBOutlet weak var fondosButton: comboBoxButton!
    @IBOutlet weak var tipoButton: comboBoxButton!
    @IBOutlet weak var generarTodasButton: UIButton!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    var tipoPicker = 1
    var selectedCuenta = -1
    var selectedFondo = -1
    var selectedTipo = -1
    let tipoCuentas = ["Retiro", "Inversión"]
    var selectedImpresion = 0
    var generarTodas = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        obtenerCuentas()
        //obtenerFondos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @IBAction func seleccionarTipoCuenta(_ sender: Any) {
        let selected = selectedTipo >= 0 ? selectedTipo : 0
        tipoPicker = 3
        pickerView.reloadAllComponents()
        pickerView.selectRow(selected, inComponent: 0, animated: false)
        pickerViewBack.isHidden = false
        
    }
    
    
    
    
    @IBAction func selectDate(_ sender: Any) {
        let button = sender as! UIButton
        let date = Date()
        let currentDate = date
        let tenYearsAgo = date.addingTimeInterval(-10*365*24*60*60)
        let inTenYears = date.addingTimeInterval(10*365*24*60*60)
        
        let dialog = LSLDatePickerDialog()
        
        dialog.show(withTitle: "Seleccionar fecha", subtitle: "", doneButtonTitle: "Aceptar", cancelButtonTitle: "Cancelar", defaultDate: currentDate, minimumDate: tenYearsAgo, maximumDate: inTenYears, datePickerMode: UIDatePickerMode.date) { (date) in
            
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
            self.checkEverythingSelected()
            
        }
    }
    
    
    func checkEverythingSelected () {
        
        var result = false
        if(self.fechaInicioField.text != "" && self.fechaFinField.text != "") {
            result = true
        }
        if(selectedCuenta < 0 || selectedFondo < 0 || selectedTipo < 0) {
            result = false
        }
        
        if(result) {
            obtenerOperaciones()
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
    
    
    @IBAction func imprimirOrden(_ sender: Any) {
        
        let button = sender as! UIButton
        selectedImpresion = button.tag
        
        obtenerPDF()
    }
    
    
    
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        if tipoPicker == 1 {
            selectedCuenta = pickerView.selectedRow(inComponent: 0)
            codigoClienteButton.setTitle(subcuentas[selectedCuenta]["NC"] as? String, for: .normal)
            obtenerFondos()
        }
        else if tipoPicker == 2 {
            selectedFondo = pickerView.selectedRow(inComponent: 0)
            fondosButton.setTitle(fondos[selectedFondo]["FO"] as? String, for: .normal)
        }
        else {
            selectedTipo = pickerView.selectedRow(inComponent: 0)
            tipoButton.setTitle(tipoCuentas[selectedTipo], for: .normal)
        }
        checkEverythingSelected()
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
                
                //self.traerFondosCuentas()
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
        
        let params = ["CU":user.getSelectedCuenta()!,"SC":(subcuentas[selectedCuenta]["CS"] as! NSNumber).stringValue,"TK":user.getToken()!]
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
    
    
    
    func obtenerOperaciones() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getOperaciones)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getOperaciones() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_TRAER_OPERACIONES)
        
        let tipo = selectedTipo == 0 ? "R" : "I"
        
        var params = ["NI":user.getUser()!,"CU":user.getSelectedCuenta()!, "FD":fechaInicioField.text!, "FH":fechaFinField.text!, "SC":(subcuentas[selectedCuenta]["CS"] as! NSNumber).stringValue, "CF":(fondos[selectedFondo]["CF"] as! NSNumber).stringValue, "TO":tipo, "TK":user.getToken()!]
        
        if(generarTodas) {
            params = ["NI":user.getUser()!,"CU":user.getSelectedCuenta()!,"FD":fechaInicioField.text!, "FH":fechaFinField.text!, "CF":(fondos[selectedFondo]["CF"] as! NSNumber).stringValue, "TO":tipo, "TK":user.getToken()!]
        }
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerListaOperacionesResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.ordenes = contenido
                    
                    self.tableView.reloadData()
                    
                    if(self.ordenes.count == 0) {
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
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_OPERACIONES_IMPRIMIR)
        
        let orden = ordenes[selectedImpresion]
        
        let tipo = orden["TO"] as! String == "Retiro" ? "RET" : "INV"
        
        let params = ["NI":user.getUser()!,"CU":user.getSelectedCuenta()!,"SC":(orden["SC"] as! NSNumber).stringValue, "FE":orden["FE"] as! String,"FO":(orden["CF"] as! NSNumber).stringValue, "NO":(orden["NU"] as! NSNumber).stringValue, "TO":tipo, "TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerOperacionImprimirResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                //print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! String
                print(resultado)
                
                self.saveBase64StringToPDF(resultado)
                
                
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
        return ordenes.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ordenesCell") as! OrdenesCell
        
        cell.nombreCuentaLabel.text = (ordenes[indexPath.row]["NU"] as! NSNumber).stringValue
        cell.fondoLabel.text = ordenes[indexPath.row]["FO"] as? String
        cell.montoLabel.text = (ordenes[indexPath.row]["MS"] as! NSNumber).formatAmount()
        cell.estadoLabel.text = ordenes[indexPath.row]["ES"] as? String
        cell.monedaLabel.text = ordenes[indexPath.row]["MO"] as? String
        
        cell.verButton.tag = indexPath.row
        
        return cell
        
    }
    
    /// Stub for responding to user row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedCuenta = filteredArray[indexPath.row]
        //user.setSelectedCuenta(selectedCuenta.cId!)
        
        //performSegue(withIdentifier: "selectCuentaSegue", sender: nil)
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
        else {
            result = tipoCuentas.count
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
        else {
            result = tipoCuentas[row]
        }
        return result
    }
    
    

}


class OrdenesCell: UITableViewCell {
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var fondoLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    @IBOutlet weak var monedaLabel: UILabel!
    @IBOutlet weak var verButton: UIButton!
    
    /*
     override func didMoveToSuperview() {
     cellView.layer.borderColor = UIColor.lightGray.cgColor
     cellView.layer.borderWidth = 1.0
     
     }*/
}
