//
//  SolicitudesRetiroViewController.swift
//  INSSAFI
//
//  Created by Novacomp on 7/23/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class SolicitudesRetiroViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias JSONStandard = Dictionary<String, Any>
    
    var user:User!
    
    var solicitudes: [JSONStandard]!
    var cuentaSeleccionada = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
        solicitudes = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        obtenerSolicitudes()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detalleInversionSegue") {
            let vc = segue.destination as! DetalleInversionViewController
            vc.inversion = solicitudes[cuentaSeleccionada]
            vc.tipo = 2
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section != 0)
        {
            return 10
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solicitudes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SolicitudCell = tableView.dequeueReusableCell(withIdentifier: "cellSolicitud", for: indexPath) as! SolicitudCell
        
        let solicitud:JSONStandard = solicitudes[indexPath.row]
        
        cell.lblSolicitud.text = "No. de solicitud: " + String(describing: solicitud["NS"] as! Int)
        cell.lblFechaSolicitud.text = solicitud["FS"] as? String
        cell.lblFechaValor.text = solicitud["FV"] as? String
        cell.lblEstado.text = solicitud["ES"] as? String
        cell.lblValorParticipacion.text = String(describing:solicitud["VP"] as! NSNumber)
        cell.lblMonto.text = (solicitud["MS"] as! NSNumber).formatAmount()
        cell.lblMoneda.text = solicitud["MO"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let solicitud:JSONStandard = solicitudes[indexPath.row]
        if(solicitud["ES"] as? String == "Pendiente Firma Mancomunada"){
            cuentaSeleccionada = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "detalleInversionSegue", sender: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func obtenerSolicitudes() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getSolicitudes)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func getSolicitudes() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_SOLICITUDES)
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "SC":"0", "TS":"R", "TK":user.getToken()!]
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["TraerListaSolicitudesResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    self.solicitudes = contenido
                    
                    self.tableView.reloadData()
                    
                    if(self.solicitudes.count == 0) {
                        self.showAlert(title: "", message: "No se encontraron resultados en esta consulta")
                    }
                }
                
            }
            catch {
                
            }
        }
    }
    
}
