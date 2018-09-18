//
//  CuentasFavoritasViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/17/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class CuentasFavoritasViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    typealias JSONStandard = Dictionary<String, Any>
    
    var user: User!
    
    @IBOutlet weak var tableView: UITableView!
    
    var cuentasFavoritas: [JSONStandard]!
    var cuentaSeleccionada = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        obtenerFavoritas()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detalleFavoritaSegue") {
            let vc = segue.destination as! DetalleFavoritaViewController
            vc.favorita = cuentasFavoritas[cuentaSeleccionada]
        }
    }
    
    
    
    
    func obtenerFavoritas() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getFavoritas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getFavoritas() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_CUENTAS_FAVORITAS)
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TK":user.getToken()!]
        
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
                    
                    self.cuentasFavoritas = contenido
                    
                    self.tableView.reloadData()
                    
                    if(self.cuentasFavoritas.count == 0) {
                        self.showAlert(title: "", message: "No se encontraron resultados en esta consulta")
                    }
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    func eliminarFavorita() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: deleteFavorita)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func deleteFavorita() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_FAVORITA)
        
        let favorita = cuentasFavoritas[cuentaSeleccionada]
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":"X", "CC":favorita["CC"] as! String, "NO":favorita["CN"] as! String, "MO":favorita["MO"] as! String, "CE":(favorita["CE"] as! NSNumber).stringValue, "ND":(favorita["NC"] as! NSNumber).stringValue, "IT":favorita["NI"] as! String, "TK":user.getToken()!]
        
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["GrabarCuentaFavoritaResult"] as! String
            
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
                        self.cuentasFavoritas.remove(at: self.cuentaSeleccionada)
                        self.tableView.reloadData()
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
        var result = 0
        if(cuentasFavoritas != nil && cuentasFavoritas.count > 0) {
            result = cuentasFavoritas.count
        }
        return result
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritaCell") as! FavoritaCell
        
        let favorita = cuentasFavoritas[indexPath.row]
        
        cell.nombreLabel.text = favorita["CC"] as? String
        cell.titularLabel.text = favorita["CN"] as? String
        cell.idLabel.text = favorita["NI"] as? String
        cell.monedaLabel.text = favorita["MO"] as? String
        cell.estadoLabel.text = favorita["ES"] as? String
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            cuentaSeleccionada = indexPath.row
            eliminarFavorita()
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cuentaSeleccionada = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "detalleFavoritaSegue", sender: nil)
    }
    
    
}

// MARK: -

/// The basic prototype table view cell that provides only a single label for textual presentation.
class FavoritaCell: UITableViewCell {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var titularLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var monedaLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    
    
    override func didMoveToSuperview() {
        
        
    }
}
