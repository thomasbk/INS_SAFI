//
//  MiPortafolioViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 5/16/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
import Charts

class MiPortafolioViewController: UIViewController, PNChartDelegate, sFechaGrafico_iphoneDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    var mainViewHeight: CGFloat!
    @IBOutlet weak var datosView: UIView!
    var datosViewCenterY: CGFloat!
    
    @IBOutlet weak var codigoButton: comboBoxButton!
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var pieChartView2: PieChartView!
    @IBOutlet weak var calendarButton: UIButton!
    
    @IBOutlet weak var grafico: graficoPie_iphone!
    @IBOutlet weak var legenda: legendaGraficoPie_iphone!
    var items:[Any]!
    let colors = [Functions.color(withHexString: "021962"), Functions.color(withHexString: "0071B8"), Functions.color(withHexString: "23B83D"), Functions.color(withHexString: "FC6722"), Functions.color(withHexString: "C0272D"),UIColor.gray, Functions.color(withHexString: "DA70D6"), Functions.color(withHexString: "D2691E"), UIColor.black]
    
    @IBOutlet weak var colonesLabel: UILabel!
    @IBOutlet weak var dolaresLabel: UILabel!
    @IBOutlet weak var colonizadoLabel: UILabel!
    @IBOutlet weak var tipoCambioLabel: UILabel!
    
    @IBOutlet weak var pickerViewBack: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    var cuentas:[Cuenta] = [Cuenta]()
    
    var subcuentas = [JSONStandard]()
    
    
    var selectedCuenta = -1
    var selectedMoneda: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.getInstance()
        cuentas = user.getCuentas() as! [Cuenta]
        
        
        dateField.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        dateField.layer.borderWidth = 1.0
        
        calendarButton.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        calendarButton.layer.borderWidth = 1.0
        
        
        
        let date = Date()
        let yesterday = date.addingTimeInterval(-1*24*60*60)
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        let nsstr = format.string(from: yesterday)
        self.dateField.text = nsstr
        
        obtenerSubcuentas()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mainViewHeight = mainView.frame.size.height
        datosViewCenterY = datosView.center.y
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "portafolioMonedaSegue") {
            let vc = segue.destination as! MiPortafolioMonedaViewController
            vc.fecha = dateField.text!
            vc.moneda = selectedMoneda!
            //vc.cuenta = Int(cuentas[selectedCuenta].cId)
            vc.cuenta = (subcuentas[selectedCuenta]["CS"] as! NSNumber).intValue
        }
    }
    
    
    
    
    
    @IBAction func selectedCuenta(_ sender: Any) {
        let button = sender as! DropdownButton
        if(button.isOpen) {
            selectedCuenta = Int((button.titleLabel?.text)!)!
            
            obtenerDistribucion()
        }
    }
    
    
    
    @IBAction func seleccionarCuenta(_ sender: Any) {
        pickerView.reloadAllComponents()
        pickerViewBack.isHidden = false
    }
    
    @IBAction func cancelPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
    }
    @IBAction func acceptPickerView(_ sender: Any) {
        pickerViewBack.isHidden = true
        
        selectedCuenta = pickerView.selectedRow(inComponent: 0)
        //codigoButton.setTitle(cuentas[selectedCuenta].cNombre, for: .normal)
        codigoButton.setTitle((subcuentas[selectedCuenta]["NC"] as! String), for: .normal)
        
        checkEverythingSelected()
    }
    
    
    func checkEverythingSelected () {
        
        var result = false
        if(dateField.text != "") {
            result = true
        }
        if(selectedCuenta < 0) {
            result = false
        }
        
        if(result) {
            obtenerDistribucion()
        }
    }
    
    
    
    
    func obtenerSubcuentas() {
        
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: getSubcuentas)
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
        }
    }
    
    func getSubcuentas() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_TRAER_SUBCUENTAS)
        
        let params = ["CU":user.getSelectedCuenta()!,"NI":user.getUser()!,"TK":user.getToken()!]
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerSubCuentasResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                let cuentasAux = resultado["Cuentas"] as! [JSONStandard]
                
                for cuenta in cuentasAux {
                    if(self.user.getSelectedCuenta()! == (cuenta["CU"] as! NSNumber).stringValue) {
                        self.subcuentas.append(cuenta)
                    }
                }
            }
            catch {
                
            }
        }
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
        
        let params = ["CU":user.getSelectedCuenta()!, "SC":(subcuentas[selectedCuenta]["CS"] as! NSNumber).stringValue, "FE":dateField.text!, "TK":user.getToken()!]
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
                
                    for monedas in contenido {
                        
                        let moneda = monedas["MO"] as? String
                        let monto = monedas["MS"] as! NSNumber
                        //let porcentaje = monedas["PS"] as! NSNumber
                        
                        if(moneda == "Colones") {
                            self.colonesLabel.text = "‎₡\(monto.formatAmount())"
                        }
                        else {
                            self.dolaresLabel.text = "‎$\(monto.formatAmount())"
                        }
                    }
                    
                    self.agregarGrafico(contenido:contenido)
                    
                    if(contenido.count == 0) {
                        self.showAlert(title: "", message: "No se encontraron resultados en esta consulta")
                    }
                    
                }
                
                let tipoCambio = (resultado["TipoCambio"] as! NSNumber).formatAmount()
                let fecha = resultado["FechaTC"] as? String
                
                self.colonizadoLabel.text = "‎₡\((resultado["TotalMonedaFondo"] as! NSNumber).formatAmount())"
                self.tipoCambioLabel.text = "Tipo cambio: \(tipoCambio) (Fecha:\(fecha!)) Fuente: BCCR"
                
            }
            catch {
                
            }
        }
    }
    
    
    
    
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        /*
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: values[i], y: Double(i))
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Units Sold")
        //let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        let pieChartData = PieChartData(dataSets: [pieChartDataSet])
        //let pieChartData = PieChartData(
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        */
        
        let entry1 = PieChartDataEntry(value: Double(20), label: "INS Liquidez")
        let entry2 = PieChartDataEntry(value: Double(30), label: "INS Crecimiento")
        let entry3 = PieChartDataEntry(value: Double(50), label: "INS Liquidez público")
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: "Widget Types")
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        pieChartView2.data = data
        pieChartView.chartDescription?.text = "Colones"
        pieChartView2.chartDescription?.text = "Dolares"
        
        dataSet.colors = ChartColorTemplates.material()
        //dataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        dataSet.valueColors = [UIColor.black]
        
        pieChartView.backgroundColor = UIColor.clear
        pieChartView.holeColor = UIColor.clear
        //pieChartView.chartDescription?.textColor = UIColor.white
        //pieChartView.legend.textColor = UIColor.white
        
        //This must stay at end of function
        pieChartView.notifyDataSetChanged()
        pieChartView2.notifyDataSetChanged()
        
    }
    
    
    func agregarGrafico(contenido:[JSONStandard]) {
        
        
        grafico.pieChart.tipoGrafico = "IN"
        
        var myItems = [PNPieChartDataItem]()
        
        for i in 0...contenido.count-1 {
            let moneda = contenido[i]["MO"] as? String
            //let monto = contenido[i]["MS"] as? NSNumber
            let porcentaje = contenido[i]["PS"] as? NSNumber
            
            //let item = PNPieChartDataItem.init(value: CGFloat((monto?.floatValue)!), color: colors[i], description: moneda, codigo: "", profundidad: "")
            let item = PNPieChartDataItem.init(value: CGFloat(truncating: porcentaje!), color: colors[i], description: moneda, codigo: "", profundidad: "")
            
            myItems.append(item!)
        }
        
        grafico.pieChart.setItems(nil)
        grafico.pieChart.setItems(myItems as Any as! [Any])
        
        grafico.addSubview(grafico.pieChart)
        grafico.pieChart.stroke()
        grafico.pieChart.delegate = self
        
        
        
        grafico.pieChart.descriptionTextColor = UIColor.white
        //grafico.pieChart.descriptionTextFont  = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
        grafico.pieChart.descriptionTextShadowColor = UIColor.clear
        grafico.pieChart.showAbsoluteValues = false;
        grafico.pieChart.showOnlyValues = true;
        grafico.pieChart.isMultipleTouchEnabled = true
        
        //[grafico.pieChart strokeChart];
        
        //grafico.pieChart.legendStyle = PNLegendItemStyleStacked
        
        //let legenda = legendaGraficoPie_iphone.init(frame: CGRect.zero)
        
        //legenda.translatesAutoresizingMaskIntoConstraints = false;
        
        //let legend = grafico.pieChart.getLegendWithMaxWidth(150)
        
        //legenda.legenda.addSubview(legend!)
        
        if let foundView = view.viewWithTag(91) {
            foundView.removeFromSuperview()
        }
        
        let legend = grafico.pieChart.getLegendWithMaxWidth(300)
        
        legend?.tag = 91
        
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
        
        selectedMoneda = data.textDescription
        
        performSegue(withIdentifier: "portafolioMonedaSegue", sender: nil)
    }
    
    
    
    @IBAction func selectDate(_ sender: Any) {
        let date = Date()
        let currentDate = date
        
        let tenYearsAgo = date.addingTimeInterval(-10*365*24*60*60)
        let yesterday = date.addingTimeInterval(-1*24*60*60)
        
        let dialog = LSLDatePickerDialog()
        
        dialog.show(withTitle: "Seleccionar fecha", subtitle: "No se pueden seleccionar fechas futuras", doneButtonTitle: "Aceptar", cancelButtonTitle: "Cancelar", defaultDate: yesterday, minimumDate: tenYearsAgo, maximumDate: currentDate, datePickerMode: UIDatePickerMode.date) { (date) in
            
            if(date != nil) {
                let format = DateFormatter()
                format.dateFormat = "dd/MM/yyyy"
                let nsstr = format.string(from: date!)
            
                self.dateField.text = nsstr
                
                self.checkEverythingSelected()
            }
            
        }
        
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var result = 0
        result = subcuentas.count
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var result = ""
        
        //result = cuentas[row].cNombre
        result = subcuentas[row]["NC"] as! String
        
        return result
    }
 
}


class BlankCell: UITableViewCell {
    
}
