//
//  SeleccionarCorreoViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/19/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class SeleccionarCorreoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var favorita:JSONStandard?
    var vencimiento:JSONStandard?
    var solicitud:JSONStandard?
    var solicitudProgramada:JSONStandard?
    
    var correos = [String]()
    var selectedCorreo = ""
    var subcuenta = ""
    
    var operacion:String = ""
    var referencia:String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        obtenerCorreos()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if (solicitud != nil) {
            titleLabel.text = "Solicitudes"
            titleImageView.image = UIImage(named: "solicitudes2")
        }
        else if (solicitudProgramada != nil) {
            titleLabel.text = "Solicitudes"
            titleImageView.image = UIImage(named: "solicitudes2")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "ingresarCodigoSegue") {
            let vc = segue.destination as! IngresarCodigoViewController
            
            vc.referencia = referencia
            vc.subcuenta = subcuenta
            vc.operacion = operacion
        }
    }
    
    
    
    
    
    func obtenerCorreos() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getCorreos)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getCorreos() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_TRAER_CORREOS)
        
        let params = ["NI":user.getUser()!,"TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerCorreosPersonaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    for correo in contenido {
                        self.correos.append(correo["CO"] as! String)
                    }
                    self.tableView.reloadData()
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    
    func agregarFavorita() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion:addFavorita)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    
    
    func addFavorita() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_FAVORITA)
        
        let moneda = (favorita!["MO"] as! String) == "Colones" ? "COL" : "DOL"
        
        let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":"C", "CC":favorita!["CC"] as! String, "NO":favorita!["NO"] as! String, "MO":moneda, "CE":(favorita!["CE"] as! NSNumber).stringValue, "IT":favorita!["IC"] as! String, "CO":selectedCorreo, "TK":user.getToken()!]
        //let params = ["NI":user.getUser()!, "CU":user.getSelectedCuenta()!, "TV":"C", "CC":"CR70015202001142490739", "NO":favorita!["NO"] as! String, "MO":favorita!["MO"] as! String, "CE":(favorita!["CE"] as! NSNumber).stringValue, "IT":favorita!["IC"] as! String, "CO":selectedCorreo, "TK":user.getToken()!]
        
        
        
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
                    
                    if( String(describing: respuesta["CodMensaje"]!) != "0") {
                        self.showAlert(title: "", message: respuesta["Mensajes"] as! String)
                    }
                    else {
                        let alertSuccess = UIAlertController(title: "Éxito", message: respuesta["Mensajes"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction (title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                            self.operacion = "C"
                            self.referencia = respuesta["Referencia"] as! String
                            
                            self.performSegue(withIdentifier: "ingresarCodigoSegue", sender: nil)
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
    
    
    
    
    func agregarVencimiento() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion:addVencimiento)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    
    
    func addVencimiento() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_VENCIMIENTO)
        
        var params:JSONStandard = self.solicitud!
        
        params["CO"] = selectedCorreo
        
        
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
                    
                    if( String(describing: respuesta["CodMensaje"]!) != "0") {
                        self.showAlert(title: "", message: respuesta["Mensajes"] as! String)
                    }
                    else {
                        let alertSuccess = UIAlertController(title: "Éxito", message: respuesta["Mensajes"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction (title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                            self.operacion = "V"
                            self.referencia = respuesta["Referencia"] as! String
                            
                            self.performSegue(withIdentifier: "ingresarCodigoSegue", sender: nil)
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
        
        var params:JSONStandard = self.solicitud!
        
        params["CO"] = selectedCorreo
        
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
                            
                            if(self.solicitud!["TR"] == nil) {
                                self.operacion = "I"
                            }
                            else {
                                self.operacion = "R"
                            }
                            
                            
                            self.referencia = respuesta["Referencia"] as! String
                            
                            self.performSegue(withIdentifier: "ingresarCodigoSegue", sender: nil)
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
    
    
    
    
    
    
    
    
    func agregarSolicitudProgramada() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: {
                self.addSolicitudProgramada()
            })
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func addSolicitudProgramada() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_INVERSION)
        
        var params:JSONStandard = self.solicitudProgramada!
        
        params["CO"] = selectedCorreo
        
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["GrabarInversionProgramadaResult"] as! String
            
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
                            self.operacion = "P"
                            
                            self.referencia = respuesta["Referencia"] as! String
                            
                            self.performSegue(withIdentifier: "ingresarCodigoSegue", sender: nil)
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
    
    
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return correos.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "correoCell") as! CorreoCell
        
        cell.correoLabel.text = correos[indexPath.row]
        
        return cell
    }
    
    /// Stub for responding to user row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCorreo = correos[indexPath.row]
        
        if (favorita != nil)
        {
            agregarFavorita()
        }
        else if (solicitud != nil)
        {
            agregarSolicitud()
        }
        else if (solicitudProgramada != nil)
        {
            agregarSolicitudProgramada()
        }
        else if (vencimiento != nil)
        {
            agregarVencimiento()
        }
    }
    
    
    

}


class CorreoCell: UITableViewCell {
    @IBOutlet weak var correoLabel: UILabel!
    
}

