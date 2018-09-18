//
//  DistribucionCalculadaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 5/23/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
import Charts

class DistribucionCalculadaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PNChartDelegate {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var params: [[String:String]]!
    
    var fondos: [JSONStandard]!
    var selectedFondo = -1
    var pieChartItems = [PNPieChartDataItem]()
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var grafico: graficoPie_iphone!
    
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pieChartView: PieChartView!
    let colors = [Functions.color(withHexString: "021962"), Functions.color(withHexString: "0071B8"), Functions.color(withHexString: "23B83D"), Functions.color(withHexString: "FC6722"), Functions.color(withHexString: "C0272D"),UIColor.gray, Functions.color(withHexString: "DA70D6"), Functions.color(withHexString: "D2691E"), UIColor.black]

    let nombres = ["Monto a invertir", "Beneficios anuales", "Beneficios mensuales", "Rendimiento a 30 días", "Rendimiento a 12 meses"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        
        obtenerCalculo()
        
        
        /*
        let alert = UIAlertController(title: "Atención", message: "Los calculos realizados por esta herramienta corresponden a un valor estimado basado en los rendimientos históricos del fondo. Los rendimientos producidos en el pasado no garantizan un rendimiento similar en el futuro. Antes de invertir solicite el prospecto del fondo de inversión. Manténgase informado, contacte con nuestro equipo de asesores de inversión para más información.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.obtenerCalculo()
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
        */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        let entry1 = PieChartDataEntry(value: Double(15), label: "INS Liquidez")
        let entry2 = PieChartDataEntry(value: Double(25), label: "INS Crecimiento")
        let entry3 = PieChartDataEntry(value: Double(30), label: "INS Liquidez público")
        let entry4 = PieChartDataEntry(value: Double(30), label: "INS Liquidez público")
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3, entry4], label: "Distribución")
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        pieChartView.chartDescription?.text = "Colones"
        
        dataSet.colors = ChartColorTemplates.material()
        //dataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        dataSet.valueColors = [UIColor.black]
        
        pieChartView.backgroundColor = UIColor.clear
        pieChartView.holeColor = UIColor.clear
        //pieChartView.chartDescription?.textColor = UIColor.white
        //pieChartView.legend.textColor = UIColor.white
        
        //This must stay at end of function
        pieChartView.notifyDataSetChanged()
        
    }
    
    
    
    
    
    func obtenerCalculo() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getCalculo)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    
    func getCalculo() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_CALCULAR_PORTAFOLIO)
        
        //let paramData = ["pConsulta":params]
        var paramDataString = "\(params!)"
        paramDataString = String(paramDataString.dropFirst())
        paramDataString = String(paramDataString.dropLast())
        
        
        //paramDataString = "(\(paramDataString))"
        paramDataString = "¿\(paramDataString)¡"
        
        
        let parametros = ["DC":paramDataString,"TK":user.getToken()!]
        
        let data = ["pConsulta":parametros]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        
        dataString = dataString.replacingOccurrences(of: "\\", with: "")
        
        dataString = dataString.replacingOccurrences(of: "\"¿", with: "[")
        dataString = dataString.replacingOccurrences(of: "¡\"", with: "]")
        
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            
            let response = data["CalcularPortafolioResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    self.fondos = contenido
                    
                    if(self.fondos.count == 0) {
                        self.showAlert(title: "", message: "No se obtuvieron resultados")
                    }
                    
                    else if(self.fondos.count > 0) {
                        self.selectedFondo = 0
                        self.agregarGrafico()
                        //self.userClicked(onPieIndexItem: 0, tipo: "IN", data: self.pieChartItems[0])
                        //self.grafico.pieChart.stroke()
                        //self.grafico.pieChart.recompute()
                        
                        //self.grafico.pieChart.update
                    }
                    
                    self.tableView.reloadData()
                }
                
                
                if let contenido = resultado["Respuesta"] as? JSONStandard {
                    if let advertencia = contenido["Advertencia"] as? String {
                        self.showAlert(title: "Atención", message: advertencia)
                    }
                }
                
            }
            catch {
                
            }
        }
    }
    
    
    func agregarGrafico() {
        pieChartItems.removeAll()
        
        grafico.pieChart.tipoGrafico = "IN"
        
        //var myItems = [PNPieChartDataItem]()
        
        for i in 1...fondos.count-1 {
            let moneda = fondos[i]["FO"] as? String
            let monto = fondos[i]["PR"] as? NSNumber
            
            let item = PNPieChartDataItem.init(value: CGFloat((monto?.floatValue)!), color: colors[i], description: moneda, codigo: "", profundidad: "")
            
            pieChartItems.append(item!)
        }
        
        
        grafico.pieChart.setItems(pieChartItems as Any as! [Any])
        
        grafico.addSubview(grafico.pieChart)
        grafico.pieChart.stroke()
        grafico.pieChart.delegate = self
        
        grafico.pieChart.legendStyle = .stacked
        grafico.pieChart.legendPosition = .bottom
        
        
        grafico.pieChart.descriptionTextColor = UIColor.white
        grafico.pieChart.descriptionTextShadowColor = UIColor.clear
        grafico.pieChart.showAbsoluteValues = false;
        grafico.pieChart.showOnlyValues = true;
        grafico.pieChart.isMultipleTouchEnabled = true
        
        let legend = grafico.pieChart.getLegendWithMaxWidth(300)
        
        var frameView = legend!.frame
        frameView.size.height = (legend?.frame.size.height)!
        frameView.origin.x = (grafico.frame.origin.x+(grafico.frame.size.width / 2)) - (frameView.size.width / 2)
        frameView.origin.y = grafico.frame.origin.y + grafico.frame.size.height + 20
        legend!.frame = frameView
        //legend?.backgroundColor = UIColor.red
        //grafico.backgroundColor = UIColor.yellow
        
        
        self.topView.addSubview(legend!)
        
        var topFrame = topView.frame
        topFrame.size.height = topView.frame.height + (legend?.frame.height)!
        topView.frame = topFrame
        
        var tituloFrame = tituloLabel.frame
        tituloFrame.origin.y = (legend?.frame.origin.y)! + (legend?.frame.height)! + 10
        tituloLabel.frame = tituloFrame
        
    }
    
    
    func userClicked(onPieIndexItem OnPieIndexItem:Int, tipo:String!, data: PNPieChartDataItem!) {
        
        //if(selectedFondo == OnPieIndexItem + 1) {
            
        //    grafico.pieChart.shouldHighlightSectorOnTouch = false
        //    selectedFondo = 0
        //}
        //else {
            selectedFondo = OnPieIndexItem + 1
            tituloLabel.text = data.textDescription
            tituloLabel.textColor = colors[OnPieIndexItem]
            
        //}
        
        
        tableView.reloadData()
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        if(fondos != nil && fondos.count > 0) {
            
            if(selectedFondo <= 0) {
                result = nombres.count - 1
            }
            else {
                result = nombres.count
            }
        }
        return result
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "distribucionCell") as! DistribucionCell
        
        cell.nombreLabel.text = nombres[indexPath.row]
        
        if(selectedFondo >= 0) {
            let myFondo = fondos[selectedFondo]
            let monedaSymbol = myFondo["MO"] as! String == "Colones" ? "‎₡" : "$"
            switch indexPath.row {
            case 0:
                cell.valorLabel.text = "\(monedaSymbol)\((myFondo["MI"] as! NSNumber).formatAmount())"
            case 1:
                cell.valorLabel.text = "\(monedaSymbol)\((myFondo["BA"] as! NSNumber).formatAmount())"
                cell.descripcionLabel.text = "\((myFondo["BC"] as! String))"
            case 2:
                //cell.valorLabel.text = "\(monedaSymbol)\((myFondo["RH"] as! NSNumber).formatAmount())"
                cell.valorLabel.text = "\((myFondo["RH"] as! NSNumber).stringValue)%"
            case 3:
                cell.valorLabel.text = "\((myFondo["RM"] as! NSNumber).stringValue)%"
                cell.nombreLabel.text = "\((myFondo["BR"] as! String))"
            case 4:
                cell.valorLabel.text = "\((myFondo["RA"] as! NSNumber).stringValue)%"
            //case 4:
                //cell.valorLabel.text = (myFondo[""] as! NSNumber).stringValue
                //cell.valorLabel.text = ""
            default:
                cell.valorLabel.text = "0.00%"
            }
            
            if(selectedFondo > 0) {
                cell.nombreLabel.textColor = colors[selectedFondo-1]
                //cell.valorLabel.textColor = colors[selectedFondo]
            }
            else {
                cell.nombreLabel.textColor = UIColor.darkGray
            }
            
            if(indexPath.row != 2) {
                cell.descripcionLabel.isHidden = true
            }
            else {
                cell.descripcionLabel.text = myFondo["BC"] as? String
            }
        }
        else {
            cell.valorLabel.text = ""
        }
        
        
        return cell
        
    }
    
}

// MARK: -

/// The basic prototype table view cell that provides only a single label for textual presentation.
class DistribucionCell: UITableViewCell {
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var valorLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    
    
    override func didMoveToSuperview() {
        
        
    }
}

