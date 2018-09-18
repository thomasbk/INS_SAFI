//
//  CalculadoraInversionViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 5/22/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class CalculadoraInversionViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>

    @IBOutlet weak var colonesLabel: UILabel!
    @IBOutlet weak var dolaresLabel: UILabel!
    @IBOutlet weak var colonizadoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //let fondos = ["INS Liquidez C", "IMS Liquidez D", "INS Liquidez Público C", "INS Liquidez Público D", "INS Inmobiliario no diversificado", "INS Público Bancario C", "INS Financiero Abierto de Crecimiento No Diversificado Colones","INS Financiero Abierto de Crecimiento No Diversificado Dólares"]
    
    var user: User!
    
    var fondos = [JSONStandard]()
    var textFieldList = [UITextField]()
    var amountList = [String]()
    var tipoDeCambio = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        obtenerFondos()
        
        tableView.keyboardDismissMode = .onDrag // .interactive
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "calcularSegue") {
            let vc = segue.destination as! DistribucionCalculadaViewController
            vc.params = obtenerParams()
        }
    }
    
    
    @IBAction func calcular() {
        let list = obtenerParams()
        
        if(list.count > 0) {
            performSegue(withIdentifier: "calcularSegue", sender: nil)
        }
        else {
            self.showAlert(title: "Atención", message: "Ingresar monto para al menos un fondo")
        }
    }
    
    
    func obtenerParams() -> [[String:String]] {
        var list = [[String:String]]()
        
        for index in 0 ... fondos.count-1 {
            
            if(Double(amountList[index])! > 0.0) {
                let dictionary = ["CF":(fondos[index]["CF"] as! NSNumber).stringValue,"VC":amountList[index]]
                
                list.append(dictionary)
            }
            
            
        }
        
        
        return list
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let removedCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        
        textField.text = textField.text!.trimmingCharacters(in: removedCharacters)
        amountList[textField.tag] = textField.text! != "" ? textField.text! : "0"
        
        var colones = 0.0
        var dolares = 0.0
        
        for index in 0 ... fondos.count - 1 {
            
            if((textField.text?.count)! > 0) {
                if(fondos[index]["MO"] as! String == "COL") {
                    colones += Double(amountList[index])!
                }
                else {
                    dolares += Double(amountList[index])!
                }
            }
        }
        
        let numberColones = NSNumber(value: colones)
        let numberDolares = NSNumber(value: dolares)
        let numberColonizado = NSNumber(value: colones + (dolares * tipoDeCambio))
        
        colonesLabel.text = "₡\(numberColones.formatAmount())"
        dolaresLabel.text = "$\(numberDolares.formatAmount())"
        colonizadoLabel.text = "₡\(numberColonizado.formatAmount())"
    }
    
    
    @objc func textFieldDidBegin(_ textField: UITextField) {
        let newText = String(textField.text!.dropFirst())
        if(Double(newText)! <= 0) {
            textField.text = ""
        }
        else {
            textField.text = newText
        }
    }
    
    @objc func textFieldDidEnd(_ textField: UITextField) {
        if textField.text!.count > 0 {
            let removedCharacters = CharacterSet(charactersIn: "0123456789,.").inverted
            
            textField.text = textField.text!.trimmingCharacters(in: removedCharacters)
        }
        else {
            textField.text = "0.00"
        }
        if(fondos[textField.tag]["MO"] as! String == "COL") {
            //textField.text = "₡\(textField.text!.stringFormattedValue())"
            textField.text = "₡\(textField.text!)"
        }
        else {
            //textField.text = "$\(textField.text!.stringFormattedValue())"
            textField.text = "$\(textField.text!)"
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
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_FONDOS_PORTAFOLIO)
        
        let params = ["NI":user.getUser()!,"TK":user.getToken()!]
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerFondosCalcPortafolioResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    self.fondos = contenido
                    
                    for _ in self.fondos {
                        self.amountList.append("0.00")
                    }
                    self.obtenerTipoCambio()
                    self.tableView.reloadData()
                    
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    
    func obtenerTipoCambio() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getTipoCambio)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getTipoCambio() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_TRAER_TIPO_CAMBIO)
        
        let params = ["TK":user.getToken()!]
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerTipoCambioResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Datos"] as? [JSONStandard] {
                    
                    self.tipoDeCambio = (contenido[0]["MC"] as! NSNumber).doubleValue
                    
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    
    
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fondos.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calculadoraCell") as! CalculadoraCell
        
        let fondo = fondos[indexPath.row]
        cell.inversionLabel.text = fondo["FO"] as? String
        
            if(fondo["MO"] as! String == "COL") {
                cell.inversionField.text = "₡\(amountList[indexPath.row])"
            }
            else {
                cell.inversionField.text = "$\(amountList[indexPath.row])"
            }
        
        //cell.inversionField.text = amountList[indexPath.row]
        cell.inversionField.tag = indexPath.row
        cell.inversionField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.inversionField.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
        cell.inversionField.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        
        return cell
        
    }
    
}

// MARK: -

/// The basic prototype table view cell that provides only a single label for textual presentation.
class CalculadoraCell: UITableViewCell {
    @IBOutlet weak var inversionLabel: UILabel!
    @IBOutlet weak var inversionField: UITextField!
    
    
    override func didMoveToSuperview() {
        
        
    }
}
