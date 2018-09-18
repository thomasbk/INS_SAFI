//
//  InversionesProgramadasViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/27/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class InversionesProgramadasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias JSONStandard = Dictionary<String, Any>
    
    var user: User!
    
    var inversiones = [JSONStandard]()
    var cuentaSeleccionada = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        obtenerInvProgramadas()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detalleInversionSegue") {
            let vc = segue.destination as! DetalleInversionViewController
            vc.inversion = inversiones[cuentaSeleccionada]
            vc.tipo = 3
        }
    }
    
    
    
    func obtenerInvProgramadas() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getInvProgramadas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func getInvProgramadas() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_LISTA_INVERSIONES_PROGRAMADAS)
        
        //{"pJsonString":"{\"pConsulta\":{\"NI\":\"113220852\",\"CU\":\"4058\",\"SC\":\"0\",\"TK\":\"LBJTV2K0MR3KJV7KFW9HUSJMB5D6D500100220180720010709\"}}"}
        
        let params = ["CU":user.getSelectedCuenta()!,"NI":user.getUser()!,"TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerListaInvProgResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.inversiones = contenido
                    self.tableView.reloadData()
                    
                    if(self.inversiones.count == 0) {
                        self.showAlert(title: "", message: "No se encontraron resultados en esta consulta")
                    }
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
        return inversiones.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "inversionesProgramadasCell") as! InversionesProgramadasCell
        
        cell.nombreCuentaLabel.text = inversiones[indexPath.row]["DE"] as? String
        cell.nombreFondoLabel.text = inversiones[indexPath.row]["FO"] as? String
        cell.fechaLabel.text = inversiones[indexPath.row]["FI"] as? String
        cell.montoLabel.text = (inversiones[indexPath.row]["MP"] as! NSNumber).formatAmount()
        cell.frecuenciaLabel.text = inversiones[indexPath.row]["FP"] as? String
        cell.estadoLabel.text = inversiones[indexPath.row]["ES"] as? String
        //cell.verButton.tag = indexPath.row
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let solicitud:JSONStandard = inversiones[indexPath.row]
        if(solicitud["ES"] as? String == "Pendiente Firma Mancomunada"){
            cuentaSeleccionada = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "detalleInversionSegue", sender: nil)
            
        }
    }

}


class InversionesProgramadasCell: UITableViewCell {
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var nombreFondoLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var frecuenciaLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    @IBOutlet weak var verButton: UIButton!
    
}
