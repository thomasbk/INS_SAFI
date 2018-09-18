//
//  VencimientosViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/3/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class VencimientosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    @IBOutlet weak var ordenButton: comboBoxButton!
    
    var vencimientos:[JSONStandard] = [JSONStandard]()
    let ordenamientos = ["Fondo", "Fecha de vencimiento"]
    
    var selectedOrden = 0
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()

        obtenerVencimientos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "vencimientosSegue") {
            let vc = segue.destination as! SolicitudVencimientoViewController
            let tag = (sender as! UIButton).tag
            vc.vencimiento = vencimientos[tag]
        }
    }
    
    
    
    @IBAction func selectedOrden(_ sender: Any) {
        let button = sender as! DropdownButton
        if(button.isOpen) {
            selectedOrden = button.tag
            
            if(selectedOrden == 0) {
                vencimientos = vencimientos.sorted(by: { $0["FO"] as! String > $1["FO"] as! String })
            }
            else if(selectedOrden == 1) {
                vencimientos = vencimientos.sorted(by: { convertToDate(date:($0["FV"] as! String)).compare(convertToDate(date:($1["FV"] as! String))) == .orderedDescending })
                //vencimientos.sorted(by: { $0["FV"] as? NSNumber > $1["FV"] as? NSNumber })
            }
            else if(selectedOrden == 2) {
                vencimientos = vencimientos.sorted(by: { convertToDate(date:($0["FG"] as! String)).compare(convertToDate(date:($1["FG"] as! String))) == .orderedDescending })
                //vencimientos.sorted(by: { $0["FG"] > $1["FG"] })
            }
            tableView.reloadData()
        }
    }
    
    func convertToDate (date:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return dateFormatter.date(from: date)!
    }
    
    @IBAction func seleccionarOrden(_ sender: Any) {
        pickerView.reloadAllComponents()
        pickerViewBack.isHidden = false
    }
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        
        selectedOrden = pickerView.selectedRow(inComponent: 0)
        ordenButton.setTitle(ordenamientos[selectedOrden], for: .normal)
        
        if(selectedOrden == 0) {
            vencimientos = vencimientos.sorted(by: { $0["FO"] as! String > $1["FO"] as! String })
        }
        else if(selectedOrden == 1) {
            vencimientos = vencimientos.sorted(by: { convertToDate(date:($0["FV"] as! String)).compare(convertToDate(date:($1["FV"] as! String))) == .orderedDescending })
            //vencimientos.sorted(by: { $0["FV"] as? NSNumber > $1["FV"] as? NSNumber })
        }
        else if(selectedOrden == 2) {
            vencimientos = vencimientos.sorted(by: { convertToDate(date:($0["FG"] as! String)).compare(convertToDate(date:($1["FG"] as! String))) == .orderedDescending })
            //vencimientos.sorted(by: { $0["FG"] > $1["FG"] })
        }
        tableView.reloadData()
    }
    
    
    
    func obtenerVencimientos() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getVencimientos)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getVencimientos() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_LISTA_VENCIMIENTOS)
        
        let params = ["CU":user.getSelectedCuenta()!,"NI":user.getUser()!,"TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerListaVencimientosResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                self.vencimientos = resultado["Contenido"] as! [JSONStandard]
                
                self.tableView.reloadData()
                
                if(self.vencimientos.count == 0) {
                    self.showAlert(title: "", message: "No se encontraron resultados en esta consulta")
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
        return vencimientos.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "vencimientoCell") as! VencimientoCell
        
        cell.nombreCuentaLabel.text = vencimientos[indexPath.row]["NC"] as? String
        cell.nombreFondoLabel.text = vencimientos[indexPath.row]["FO"] as? String
        cell.fechaLabel.text = vencimientos[indexPath.row]["FV"] as? String
        cell.fechaGraciaLabel.text = vencimientos[indexPath.row]["FG"] as? String
        cell.montoLabel.text = (vencimientos[indexPath.row]["MR"] as! NSNumber).formatAmount()
        cell.saldoLabel.text = (vencimientos[indexPath.row]["MS"] as! NSNumber).formatAmount()
        cell.monedaLabel.text = vencimientos[indexPath.row]["MO"] as? String
        cell.verButton.tag = indexPath.row
        
        
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
        result = ordenamientos.count
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        
        result = ordenamientos[row]
        
        return result
    }

}






class VencimientoCell: UITableViewCell {
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var nombreFondoLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var fechaGraciaLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var monedaLabel: UILabel!
    @IBOutlet weak var verButton: UIButton!
    
    /*
    override func didMoveToSuperview() {
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        cellView.layer.borderWidth = 1.0
        
    }*/
}
