//
//  IndicadoresFondosViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/6/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class IndicadoresFondosViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    
    @IBOutlet weak var indicadoresButton: comboBoxButton!
    @IBOutlet weak var tipoButton: comboBoxButton!
    @IBOutlet weak var rendimiento30diasLabel: UILabel!
    @IBOutlet weak var rendimiento12mesesLabel: UILabel!
    @IBOutlet weak var valorLabel: UILabel!
    @IBOutlet weak var comisionLabel: UILabel!
    @IBOutlet weak var liquido30diasLabel: UILabel!
    @IBOutlet weak var liquido12mesesLabel: UILabel!
    
    
    @IBOutlet weak var rendimiento30View: UIView!
    @IBOutlet weak var rendimiento12View: UIView!
    @IBOutlet weak var liquido30View: UIView!
    @IBOutlet weak var liquido12View: UIView!
    @IBOutlet weak var participacionView: UIView!
    @IBOutlet weak var comisionView: UIView!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var selectedIndicador: Int!
    var selectedFondo = -1
    var user: User!
    
    var fondos = [JSONStandard]()
    
    var clasesIndicadores = ["RM","RA","LM","LA","VP","CO","CI"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
        rendimiento30View.layer.borderColor = UIColor.lightGray.cgColor
        rendimiento30View.layer.borderWidth = 1.0
        rendimiento12View.layer.borderColor = UIColor.lightGray.cgColor
        rendimiento12View.layer.borderWidth = 1.0
        liquido30View.layer.borderColor = UIColor.lightGray.cgColor
        liquido30View.layer.borderWidth = 1.0
        liquido12View.layer.borderColor = UIColor.lightGray.cgColor
        liquido12View.layer.borderWidth = 1.0
        participacionView.layer.borderColor = UIColor.lightGray.cgColor
        participacionView.layer.borderWidth = 1.0
        comisionView.layer.borderColor = UIColor.lightGray.cgColor
        comisionView.layer.borderWidth = 1.0
        
        obtenerIndicadores()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func seleccionarFondo(_ sender: Any) {
        pickerView.reloadAllComponents()
        pickerViewBack.isHidden = false
    }
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        selectedFondo = pickerView.selectedRow(inComponent: 0)
        tipoButton.setTitle(fondos[selectedFondo]["NF"] as? String, for: .normal)
        //obtenerIndicadores()
        
        //selectedFondo = button.tag
        setFondo()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "graficoLinealSegue") {
            let vc = segue.destination as! IndicadoresGraficoViewController
            let seleccionado = (sender as! UIButton).tag
            
            vc.tipoIndicador = .fondos
            vc.claseIndicador = clasesIndicadores[seleccionado]
            vc.elegido = fondos[selectedFondo]
        }
    }
    
    
    @IBAction func verGrafico(_ sender: Any) {
        
        performSegue(withIdentifier: "graficoLinealSegue", sender: sender)
        
    }
    
    
    
    
    
    func setFondo () {
        //let fondo = fondos[tipoButton.tag]
        let fondo = fondos[selectedFondo]
        
        rendimiento12View.isHidden = false
        rendimiento30View.isHidden = false
        participacionView.isHidden = false
        comisionView.isHidden = false
        
        rendimiento30diasLabel.text = "\((fondo["RM"] as! NSNumber).stringValue)%"
        rendimiento12mesesLabel.text = "\((fondo["RA"] as! NSNumber).stringValue)%"
        if( (fondo["LA"] as! NSNumber).doubleValue > 0) {
            liquido30View.isHidden = false
            liquido12View.isHidden = false
            liquido12mesesLabel.text = "\((fondo["LA"] as! NSNumber).stringValue)%"
            liquido30diasLabel.text = "\((fondo["LM"] as! NSNumber).stringValue)%"
            
            participacionView.center = CGPoint(x: participacionView.center.x, y: liquido30View.center.y + liquido12View.frame.height + 6)
            comisionView.center = CGPoint(x: participacionView.center.x, y: liquido30View.center.y + (liquido12View.frame.height * 2) + 12)
        }
        else {
            liquido30View.isHidden = true
            liquido12View.isHidden = true
            
            participacionView.center = CGPoint(x: participacionView.center.x, y: liquido30View.center.y)
            comisionView.center = CGPoint(x: comisionView.center.x, y: liquido12View.center.y)
        }
        
        valorLabel.text = (fondo["VP"] as! NSNumber).stringValue
        comisionLabel.text = "\((fondo["CO"] as! NSNumber).stringValue)%"
    }
    
    
    func obtenerIndicadores() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getIndicadores)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getIndicadores() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_INDICADORES_FONDOS)
        
        var params:[String:String]
        if(selectedFondo < -1) {
            params = ["FO":"\(selectedFondo)","CI":"VP", "FD":"03/07/2018","FH":"03/07/2018","TK":user.getToken()!]
        }
        else if(selectedFondo == -1) {
            
            params = ["TK":user.getToken()!]
        }
        else {
            params = ["FO":"\(selectedFondo)","TK":user.getToken()!]
        }
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerIndicadoresFondosResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    self.fondos = contenido
                    
                    //var cuentasOptions = [String]()
                    //for cuenta in contenido {
                    //    cuentasOptions.append(cuenta["NF"] as! String)
                        
                    //}
                    
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
        result = fondos.count
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        
        result = fondos[row]["NF"] as! String
        
        return result
    }
    
    
    

}
