//
//  IndicadoresGraficoViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/10/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit
import Charts

class IndicadoresGraficoViewController: UIViewController {
    
    typealias JSONStandard = Dictionary<String, Any>
    var user: User!
    
    @IBOutlet weak var lineChartView: LineChartView! //New line
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var fechaInicioField: UITextField!
    @IBOutlet weak var fechaFinField: UITextField!
    @IBOutlet weak var fechaInicioButton: UIButton!
    @IBOutlet weak var fechaFinButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    enum TiposIndicadores {
        case fondos, economicoCambio, economicoTipo
    }
    
    var tipoIndicador = TiposIndicadores.fondos
    var claseIndicador = ""
    
    var elegido: JSONStandard!
    var datos:[JSONStandard]!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        user = User.getInstance()
        
        if tipoIndicador == .fondos {
            titleLabel.text = "Fondos"
        }
        
        /*
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        //setChart(months, values: unitsSold)
        setChart(dataPoints: months, values: unitsSold)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func canRotate() -> Void {}
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 600)
            self.navigationItem.hidesBackButton = true
            //self.navigationController?.navigationBar.setBackgroundImageLandscape()
        } else {
            print("Portrait")
            scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 600)
            self.navigationItem.hidesBackButton = false
            
            //self.navigationController?.navigationBar.setBackgroundImage()
        }
    }
    
    
    
    @IBAction func selectDate(_ sender: Any) {
        let button = sender as! UIButton
        let date = Date()
        //let currentDate = date.addingTimeInterval(-1*24*60*60)
        let currentDate = date
        let tenYearsAgo = date.addingTimeInterval(-10*365*24*60*60)
        
        let dialog = LSLDatePickerDialog()
        
        dialog.show(withTitle: "Seleccionar fecha", subtitle: "No se pueden seleccionar fechas futuras", doneButtonTitle: "Aceptar", cancelButtonTitle: "Cancelar", defaultDate: currentDate, minimumDate: tenYearsAgo, maximumDate: currentDate, datePickerMode: UIDatePickerMode.date) { (date) in
            
            if(date != nil) {
                let format = DateFormatter()
                format.dateFormat = "dd/MM/yyyy"
                let nsstr = format.string(from: date!)
                
                if(button == self.fechaInicioButton) {
                    self.fechaInicioField.text = nsstr
                }
                else {
                    self.fechaFinField.text = nsstr
                }
            }
            if(self.fechaInicioField.text != "" && self.fechaFinField.text != "") {
                self.obtenerIndicadores()
            }
        }
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
        var url:String?
        
        var params:[String:String]
        
        let ci = (elegido["CI"] as! NSNumber).stringValue
        
        switch tipoIndicador {
            case .fondos:
                url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_INDICADORES_FONDOS)
                params = ["FO":(elegido["FO"] as! NSNumber).stringValue, "CI":claseIndicador, "FD": fechaInicioField.text!, "FH":fechaFinField.text!,"TK":user.getToken()!]
            case .economicoTipo:
                url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_INDICADORES_ECONOMICOS)
                params = ["TI":"TI", "CI":ci, "FD": fechaInicioField.text!, "FH":fechaFinField.text!,"TK":user.getToken()!]
            case .economicoCambio:
                url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_INDICADORES_ECONOMICOS)
                params = ["TI":"TC", "CI":ci, "FD": fechaInicioField.text!, "FH":fechaFinField.text!,"TK":user.getToken()!]
        }
        
        
        let data = ["pConsulta":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            var response:String
            
            if(self.tipoIndicador == .fondos) {
                response = data["TraerIndicadoresFondosResult"] as! String
            }
            else {
                response = data["TraerIndicadoresEconomicosResult"] as! String
            }
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                if let contenido = resultado["Contenido"] as? [JSONStandard] {
                    
                    self.datos = contenido
                    
                    //self.pintarGrafico()
                    
                    self.setChart()
                }
                
                
            }
            catch {
                
            }
        }
    }
    
    /*
    func drawGradient() {
        
        //2 - get the current context
        let context2 = UIGraphicsGetCurrentContext()
        let colors2 = [UIColor.blue.cgColor, UIColor.black.cgColor]
        
        //3 - set up the color space
        let colorSpace2 = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations2:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient2 = CGGradient(colorsSpace: colorSpace2,
                                   colors: colors2 as CFArray,
                                   locations: colorLocations2)
        
        //6 - draw the gradient
        let startPoint2 = CGPoint.zero
        let endPoint2 = CGPoint(x:100, y:self.view.bounds.height)
        context2!.drawLinearGradient(gradient2!,
                                     start: startPoint2,
                                     end: endPoint2,
                                     options: CGGradientDrawingOptions(rawValue: 0))
    }
    
    
    func pintarGrafico() {
        
        // Create a gradient to apply to the bottom portion of the graph
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let num_locations = 2;
        //let locations = [0.0, 1.0]
        let locations : [CGFloat] = [0, 0.25, 0.75, 1.0]
        //let components = [1.0, 1.0, 1.0, 1.0,1.0, 1.0, 1.0, 0.0] as CFArray
        
        let components : [CGFloat] = [
            0,   0,   0,   0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            0,   0,   0,   0
        ]
        
        graficoView.dataSource = self
        graficoView.delegate = self
        
        
        //graficoView.enableBezierCurve = true
        let lineColor = Functions.color(withHexString: "004976")
        let color = Functions.color(withHexString: "53BDFF")
        graficoView.colorTop = UIColor.clear
        graficoView.colorBottom = color!
        
        let colours = [color!.cgColor, UIColor.white.cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //let gradient = CGGradient(colorsSpace: colorSpace, colors: colours , locations: locations)
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 4)
        //graficoView.gradientBottom = gradient!
        
        
        
        
        let colorSpace1 = CGColorSpaceCreateDeviceRGB()
        let componentCount1 : UInt = 4
        
        let components1 : [CGFloat] = [
            0,   0,   0,   0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            0,   0,   0,   0
        ]
        
        let locations1 : [CGFloat] = [0, 0.25, 0.75, 1.0]
        
        let gradient1 = CGGradient(colorSpace: colorSpace1, colorComponents: components1, locations: locations1, count: Int(componentCount1))
        
        //graficoView.gradientBottom = gradient1!
        
        // Create a gradient to apply to the bottom portion of the graph
        let colorspace4 = CGColorSpaceCreateDeviceRGB()
        let num_locations4 = 2
        let locations4 : [CGFloat] = [ 0.0, 1.0 ]
        let components4 : [CGFloat] = [
            0.0, 0.0, 0.0, 0.0,
            1.0, 1.0, 1.0, 1.0
        ]
        let gradient4 = CGGradient(colorSpace: colorspace4, colorComponents: components4, locations: locations4, count: num_locations4)!
        //graficoView.gradientBottom = gradient4
        
        
        //graficoView.backgroundColor = color
        graficoView.colorXaxisLabel = UIColor.white
        graficoView.colorYaxisLabel = UIColor.black
        
        //graficoView.grafico.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations)
        
        // Enable and disable various graph properties and axis displays
        graficoView.enableTouchReport = true
        graficoView.enablePopUpReport = true
        graficoView.enableYAxisLabel = true
        graficoView.enableXAxisLabel = true
        graficoView.autoScaleYAxis = true
        graficoView.alwaysDisplayDots = false
        graficoView.enableReferenceXAxisLines = false
        graficoView.enableReferenceYAxisLines = false
        graficoView.enableReferenceAxisFrame = true
        graficoView.colorLine = lineColor!
        
        // Draw an average line
        graficoView.averageLine.enableAverageLine = false
        graficoView.averageLine.alpha = 0.6
        graficoView.averageLine.color = UIColor.lightGray
        graficoView.averageLine.width = 2.5
        //graficoView.grafico.averageLine.dashPattern = @[@(2),@(2)]
        graficoView.averageLine.dashPattern = [2,2]
        
        
        // Set the graph's animation style to draw, fade, or none
        //graficoView.grafico.animationGraphStyle = BEMLineAnimationDraw
        
        // Dash the y reference lines
        graficoView.lineDashPatternForReferenceYAxisLines = [2,2]
        
        // Show the y axis values with this format string
        graficoView.formatStringForValues = "%.2f"
        
        graficoView.reloadGraph()
    }
    */
    
    func setChart() {
        
        var dataPoints = [String]()
        var values = [Double]()
        
        for i in 0 ... datos.count-1 {
            
            if tipoIndicador == .fondos {
                values.append( Double(truncating: (datos[i][claseIndicador] as? NSNumber)!))
            }
            else {
                values.append( Double(truncating: (datos[i]["VI"] as? NSNumber)!) )
            }

            if tipoIndicador == .fondos {
                dataPoints.append( datos[i]["FE"] as! String)
            }
            else {
                dataPoints.append( datos[i]["FV"] as! String)
            }
        }
        
        setChart(dataPoints: dataPoints, values: values)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            
            dataEntries.append(dataEntry)
        }
        
        //let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Units Sold")
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: elegido["DI"] as? String)
        
        lineChartDataSet.drawIconsEnabled = false
        
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.setColor(Functions.color(withHexString: "021962"))
        lineChartDataSet.setCircleColor(Functions.color(withHexString: "021962"))
        lineChartDataSet.lineWidth = 1
        lineChartDataSet.circleRadius = 3
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.valueFont = .systemFont(ofSize: 9)
        lineChartDataSet.formLineDashLengths = [5, 2.5]
        lineChartDataSet.formLineWidth = 1
        lineChartDataSet.formSize = 15
        //lineChartDataSet.drawCubicEnabled = true;
        lineChartDataSet.drawCirclesEnabled = true
        //lineChartDataSet.cubicIntensity = 0.5
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00021962").cgColor,
                              ChartColorTemplates.colorFromString("#ff021962").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        lineChartDataSet.fillAlpha = 1
        lineChartDataSet.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        lineChartDataSet.drawFilledEnabled = true
        
        
        
        //let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        //let lineChartData = LineChartData(dataSets: [lineChartDataSet])
        //lineChartView.data = lineChartData
        
        let d = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = d
        lineChartView.xAxis.valueFormatter = XValsFormatter(xVals: dataPoints)
        //xAxis.axisMinimum = Double(0)
        //xAxis.axisMaximum = Double(presenter.xLabels.count - 1)
        
    }
    
    
    /*
    //#pragma mark - SimpleLineGraph Data Source
    
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return datos.count
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        var result:CGFloat
        
        if tipoIndicador == .fondos {
            result = CGFloat(truncating: (datos[index][claseIndicador] as? NSNumber)!)
        }
        else {
            result = CGFloat(truncating: (datos[index]["VI"] as? NSNumber)!)
        }
        return result
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, labelOnXAxisFor index: Int) -> String? {
        var result:String?
        if tipoIndicador == .fondos {
            result = datos[index]["FE"] as? String
        }
        else {
            result = datos[index]["FV"] as? String
        }
        return result
    }
    */

}



class XValsFormatter: NSObject, IAxisValueFormatter {
    
    let xVals: [String]
    init(xVals: [String]) {
        self.xVals = xVals
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var result: String
        result = Int(value) < xVals.count ? xVals[Int(value)] : String(describing: value)
        result = result.count > 5 ? String(result.prefix(5)) : result
        return result
    }
    
}
