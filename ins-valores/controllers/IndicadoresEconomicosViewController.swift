//
//  IndicadoresEconomicosViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/6/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class IndicadoresEconomicosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    
    @IBOutlet weak var indicadoresButton: comboBoxButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var selectedIndicador = 0
    var indicadores = ["Tasas de interés","Tipo de cambio"]
    var user: User!
    
    var listaIndicadores = [JSONStandard]()

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        indicadoresButton.setTitle(indicadores[selectedIndicador], for: .normal)
        
        obtenerIndicadores()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "graficoLinealSegue") {
            let vc = segue.destination as! IndicadoresGraficoViewController
            let seleccionado = (sender as! UIButton).tag
            
            vc.tipoIndicador = selectedIndicador == 0 ? .economicoTipo : .economicoCambio
            vc.elegido = listaIndicadores[seleccionado]
        }
    }
    
    
    @IBAction func verGrafico(_ sender: Any) {
        
        performSegue(withIdentifier: "graficoLinealSegue", sender: sender)
    
    }
    
    
    @IBAction func selectedIndicador(_ sender: Any) {
        let button = sender as! DropdownButton
        if(button.isOpen) {
            
            selectedIndicador = button.tag
            
            obtenerIndicadores()
        }
    }
    
    
    @IBAction func seleccionarIndicador(_ sender: Any) {
        pickerView.reloadAllComponents()
        pickerViewBack.isHidden = false
    }
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        selectedIndicador = pickerView.selectedRow(inComponent: 0)
        indicadoresButton.setTitle(indicadores[selectedIndicador], for: .normal)
        obtenerIndicadores()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_INDICADORES_ECONOMICOS)
        
        let indicador = selectedIndicador == 0 ? "TI" : "TC"
        
        let params = ["TI":indicador,"TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerIndicadoresEconomicosResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    self.listaIndicadores = contenido
                    
                    self.tableView.reloadData()
                    
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
        return listaIndicadores.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "indicadorCell") as! IndicadorCell
        
        let indicador = listaIndicadores[indexPath.row]
        
        cell.nombreCuentaLabel.text = indicador["DI"] as? String
        cell.verButton.tag = indexPath.row
        
        if((indicador["VA"] as! NSNumber).doubleValue > (indicador["VI"] as! NSNumber).doubleValue) {
            cell.indicadorImage.image = UIImage(named: "graphic_green")
        }
        else if((indicador["VA"] as! NSNumber).doubleValue < (indicador["VI"] as! NSNumber).doubleValue) {
            cell.indicadorImage.image = UIImage(named: "graphic_red")
        }
        else { // Se mantiene igual
            cell.indicadorImage.image = UIImage(named: "graphic_blue")
        }
        
        cell.backView.layer.borderColor = UIColor.lightGray.cgColor
        cell.backView.layer.borderWidth = 1.0
        
        return cell
        
    }

    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var result = 0
        result = indicadores.count
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        
        result = indicadores[row]
        
        return result
    }
    
}
    
    
class IndicadorCell: UITableViewCell {
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var indicadorImage: UIImageView!
    @IBOutlet weak var verButton: UIButton!
    @IBOutlet weak var backView: UIView!
    
}
