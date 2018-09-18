//
//  MiPortafolioMonedaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/4/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class MiPortafolioMonedaViewController: UIViewController,PNChartDelegate, sFechaGrafico_iphoneDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    var mainViewHeight: CGFloat!
    @IBOutlet weak var datosView: UIView!
    var datosViewCenterY: CGFloat!
    
    typealias JSONStandard = Dictionary<String, Any>
    
    var fecha: String!
    var moneda: String!
    var cuenta: Int!
    var user: User!
    
    var fondos:[JSONStandard]!
    
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var clienteLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var monedaLabel: UILabel!
    @IBOutlet weak var numeroParticipacionesLabel: UILabel!
    @IBOutlet weak var valorParticipacionesLabel: UILabel!
    @IBOutlet weak var saldoTitleLabel: UILabel!
    @IBOutlet weak var numeroParticipacionesTitleLabel: UILabel!
    @IBOutlet weak var valorParticipacionesTitleLabel: UILabel!
    
    @IBOutlet weak var grafico: graficoPie_iphone!
    var items:[Any]!
    let colors = [Functions.color(withHexString: "021962"), Functions.color(withHexString: "0071B8"), Functions.color(withHexString: "23B83D"), Functions.color(withHexString: "FC6722"), Functions.color(withHexString: "C0272D"),UIColor.gray, Functions.color(withHexString: "DA70D6"), Functions.color(withHexString: "D2691E"), UIColor.black]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
        fechaLabel.text = fecha
        clienteLabel.text = "\(cuenta!)"
        monedaLabel.text = moneda

        // Do any additional setup after loading the view.
        obtenerDistribucion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mainViewHeight = mainView.frame.size.height
        datosViewCenterY = datosView.center.y
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func obtenerDistribucion() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getDistribucion)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getDistribucion() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_DIST_MONEDA)
        
        let params = ["CU":user.getSelectedCuenta()!, "SC":"\(cuenta)","FE":fecha!,"MO":moneda!,"TK":user.getToken()!]
        let data = ["pClientes":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerDistXMonedaResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    self.fondos = contenido
                    
                    self.agregarGrafico()
                    
                }
                
                
            }
            catch {
                
            }
        }
    }
    
    
    
    func agregarGrafico() {
        
        grafico.pieChart.tipoGrafico = "Fondos"
        
        var myItems = [PNPieChartDataItem]()
        
        for i in 0...fondos.count-1 {
            let saldo = fondos[i]["MS"] as? NSNumber
            let fondo = fondos[i]["FO"] as? String
            let porcentaje = fondos[i]["PS"] as? NSNumber
            
            
            //let item = PNPieChartDataItem.init(value: CGFloat((saldo?.floatValue)!), color: colors[i], description: fondo, codigo: "", profundidad: "")
            let item = PNPieChartDataItem.init(value: CGFloat(truncating: porcentaje!), color: colors[i], description: fondo, codigo: "", profundidad: "")
            
            myItems.append(item!)
        }
        
        
        grafico.pieChart.setItems(myItems as Any as! [Any])
        
        grafico.pieChart.descriptionTextColor = UIColor.white
        grafico.pieChart.descriptionTextShadowColor = UIColor.clear
        grafico.pieChart.showAbsoluteValues = false;
        grafico.pieChart.showOnlyValues = true;
        grafico.pieChart.isMultipleTouchEnabled = true
        
        grafico.addSubview(grafico.pieChart)
        grafico.pieChart.stroke()
        grafico.pieChart.delegate = self
        
        
        let legend = grafico.pieChart.getLegendWithMaxWidth(300)
        
        var frameView = legend!.frame
        frameView.size.height = (legend?.frame.size.height)!
        frameView.origin.x = (grafico.frame.origin.x+(grafico.frame.size.width / 2)) - (frameView.size.width / 2)
        frameView.origin.y = grafico.frame.origin.y + grafico.frame.size.height + 20
        legend!.frame = frameView
        
        self.mainView.addSubview(legend!)
        
        datosView.center = CGPoint(x: datosView.center.x, y: datosViewCenterY + (legend?.frame.height)! + 15)
        
        var topFrame = mainView.frame
        topFrame.size.height = mainViewHeight + (legend?.frame.height)! + 15
        mainView.frame = topFrame
        
        tableView.reloadData()
    }
    
    
    func userClicked(onPieIndexItem OnPieIndexItem:Int, tipo:String!, data: PNPieChartDataItem!) {
        
        datosView.isHidden = false
        
        let monedaSymbol = moneda == "Colones" ? "‎₡" : "$"
        
        saldoLabel.text = "‎\(monedaSymbol)\((fondos[OnPieIndexItem]["MS"] as! NSNumber).formatAmount())"
        saldoTitleLabel.textColor = colors[OnPieIndexItem]
        numeroParticipacionesLabel.text = (fondos[OnPieIndexItem]["PS"] as! NSNumber).stringValue
        numeroParticipacionesTitleLabel.textColor = colors[OnPieIndexItem]
        valorParticipacionesLabel.text = (fondos[OnPieIndexItem]["VP"] as? NSNumber)?.stringValue
        valorParticipacionesTitleLabel.textColor = colors[OnPieIndexItem]
        
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = 0
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blankCell") as! BlankCell
        
        return cell
    }

}
