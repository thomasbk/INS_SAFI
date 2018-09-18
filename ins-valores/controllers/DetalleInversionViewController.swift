//
//  DetalleInversionViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 9/4/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class DetalleInversionViewController: UIViewController {

    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var inversion:JSONStandard!
    var tipo = 0
    
    @IBOutlet weak var agregarHuellaButton: UIButton!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var programadaView: UIView!
    @IBOutlet weak var solicitudView: UIView!
    
    @IBOutlet weak var lblSolicitud: UILabel!
    @IBOutlet weak var lblFechaSolicitud: UILabel!
    @IBOutlet weak var lblFechaValor: UILabel!
    @IBOutlet weak var lblEstado: UILabel!
    @IBOutlet weak var lblValorParticipacion: UILabel!
    @IBOutlet weak var lblMonto: UILabel!
    @IBOutlet weak var lblMoneda: UILabel!
    
    
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var nombreFondoLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var frecuenciaLabel: UILabel!
    @IBOutlet weak var estadoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "seleccionarCorreoSegue") {
            let vc = segue.destination as! SeleccionarCorreoViewController
            if(tipo == 3) {
                vc.solicitudProgramada = getJSONSolicitudProgramada(isTouch: false)
            }
            else {
                vc.solicitud = getJSONSolicitud(isTouch: false)
            }
        }
    }
    
    
    func setData() {
        
        if(tipo == 1 || tipo == 2) { // Inversion o retiro
            
            solicitudView.isHidden = false
            programadaView.isHidden = true
        
            lblSolicitud.text = "No. de solicitud: " + String(describing: inversion["NS"] as! Int)
            lblFechaSolicitud.text = inversion["FS"] as? String
            lblFechaValor.text = inversion["FV"] as? String
            lblEstado.text = inversion["ES"] as? String
            lblValorParticipacion.text = String(describing:inversion["VP"] as! NSNumber)
            if let value = (inversion["MS"] as? NSNumber)
            {
                lblMonto.text = value.formatAmount()
            }
            else {
                lblMonto.text = ""
            }
            lblMoneda.text = inversion["MO"] as? String
            
            inversion["NO"] = inversion["CN"] as? String
            inversion["IC"] = inversion["NI"] as? String
        }
        else { // tipo == 3 // Programada
            
            solicitudView.isHidden = true
            programadaView.isHidden = false
            
            nombreCuentaLabel.text = inversion["DE"] as? String
            nombreFondoLabel.text = inversion["FO"] as? String
            fechaLabel.text = inversion["FI"] as? String
            montoLabel.text = (inversion["MP"] as! NSNumber).formatAmount()
            frecuenciaLabel.text = inversion["FP"] as? String
            estadoLabel.text = inversion["ES"] as? String
            
        }
        
        if(inversion["ES"] as! String == "Activa") {
            
            agregarHuellaButton.isHidden = true
            agregarButton.isHidden = true
        }
        else {
            let context = LAContext()
            var error: NSError?
            
            if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                agregarHuellaButton.isHidden = true
                
                agregarButton.center = CGPoint(x:self.view.center.x, y:agregarButton.center.y)
            }
        }
    }
    
    
    @IBAction func agregarCuentaAction () {
        
        performSegue(withIdentifier: "seleccionarCorreoSegue", sender: nil)
    }
    
    @IBAction func agregarCuentaHuellaAction () {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Valide la acción con su huella"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        self.agregarSolicitud()
                    }
                    else {
                        
                    }
            })
        }
            
        else {
            // Not available
            
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
        var url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_SOLICITUD)
        if(tipo == 3) {
            url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_GRABAR_INVERSION)
        }
        
        var params:JSONStandard // = getJSONSolicitud(isTouch: true)
        if(tipo == 3) {
            params = getJSONSolicitudProgramada(isTouch: true)
        }
        else {
            params = getJSONSolicitud(isTouch: true)
        }
        
        let data = ["pTransaccion":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = self.tipo == 3 ? data["GrabarInversionProgramadaResult"] as! String : data["GrabarSolicitudesResult"] as! String
            
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
                            self.navigationController?.popViewController(animated: true)
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
    
    func getJSONSolicitud(isTouch:Bool) -> JSONStandard {
        let ts = tipo == 1 ? "I" : "R"
        var params:JSONStandard = ["TV":isTouch ? "B" : "C", "TS":ts,"NS":String(describing: inversion["NS"] as! Int), "NI":user.getUser()!, "CF":String(describing: inversion["CF"] as! Int), "CU":user.getSelectedCuenta()!, "SC":String(describing: inversion["SC"] as! Int),"TK":user.getToken()!]
        
        if (isTouch)
        {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            let fecha = format.string(from: Date())
            
            let detallesDispositivo = "Apple " + UIDevice.current.model + " " + UIDevice.current.systemVersion
            
            let DV = ["DI":detallesDispositivo,"FE":fecha]
            
            params["DV"] = DV
        }
        
        return params
    }
    
    func getJSONSolicitudProgramada(isTouch:Bool) -> JSONStandard {
        var params:JSONStandard = ["TV":isTouch ? "B" : "C","NC":String(describing: inversion["NC"] as! Int), "NI":user.getUser()!, "CF":String(describing: inversion["CF"] as! Int), "CU":user.getSelectedCuenta()!, "SC":String(describing: inversion["SC"] as! Int),"TK":user.getToken()!]
        
        if (isTouch)
        {
            let format = DateFormatter()
            format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
            let fecha = format.string(from: Date())
            
            let detallesDispositivo = "Apple " + UIDevice.current.model + " " + UIDevice.current.systemVersion
            
            let DV = ["DI":detallesDispositivo,"FE":fecha]
            
            params["DV"] = DV
        }
        
        return params
    }

}
