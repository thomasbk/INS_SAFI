//
//  SaldosViewController.swift
//  INSValores
//
//  Created by Pro Retina on 5/2/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class SaldosViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias JSONStandard = Dictionary<String, Any>
    
    var listaSaldos:[JSONStandard] = [JSONStandard]()
    
    var sections = [Section]()
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //var rightImage = UIImage(named: "home")
        //rightImage = rightImage?.withRenderingMode(.alwaysOriginal)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightImage, style:.plain, target: nil, action: nil)
        
        
        user = User.getInstance()
        
        getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func completionHandler() {
        let url = RequestUtilities.getURL(WS_SERVICE_USUARIO, method: WS_METHOD_SALDOS_ACTUALES)
        
        let params = ["NI":user.getUser()!, "TK":user.getToken()!, "CU":user.getSelectedCuenta()!]
        let data = ["pClientes":params]
        var dataString = "\(data)"
        dataString = dataString.replacingOccurrences(of: "[", with: "{")
        dataString = dataString.replacingOccurrences(of: "]", with: "}")
        let paramsExtern = ["pJsonString":dataString]
        
        NetworkHandler.getRequest(urlString: url!, data: paramsExtern) { (data) in
            self.dismiss(animated: true, completion: nil)
            
            let response = data["TraerSaldosActualesResult"] as! String
            
            let dataJson = response.data(using: String.Encoding.utf8)
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: dataJson!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.RawValue(0))) as! JSONStandard
                
                print(dataDictionary)
                
                let resultado = dataDictionary["Resultado"] as! JSONStandard
                
                self.listaSaldos = resultado["Contenido"] as! [JSONStandard]
                
                self.setSections()
                
                self.tableView.reloadData()
                
                if(self.listaSaldos.count == 0) {
                    self.showAlert(title: "", message: "No se encontraron saldos en esta cuenta")
                }
            }
            catch {
            
            }
        }
        
    }
    
    func getData () {
        let networkReachability = Reachability.forInternetConnection
        let networkStatus = networkReachability().currentReachabilityStatus
        
        if (networkStatus() == ReachableViaWiFi || networkStatus() == ReachableViaWWAN) {
            let alert = Functions.getLoading("Obteniendo información")
            present(alert!, animated: true, completion: completionHandler)
            
        }
        else {
            // Mostramos el error
            //[self showAlert:@"Iniciar sesión" withMessage:@"No hay conexión a Internet"];
            
        }
    }
    
    
    
    func setSections () {
        
        for fondo in listaSaldos {
            
            if(sections.count == 0) {
                sections.append(Section(subcuenta: fondo["NC"] as! String,
                        fondos: [fondo],
                        expanded: false))
            }
            else {
                var exists = false
                var i = 0
                for section in sections {
                    
                    if(fondo["SC"] as! Int == section.fondos[0]["SC"] as! Int){
                        
                        var myFondos = sections[i].fondos
                        myFondos?.append(fondo)
                        sections[i].fondos = myFondos
                        exists = true
                        break
                    }
                    i = i + 1
                }
                if(!exists) {
                    sections.append(Section(subcuenta: fondo["NC"] as! String,
                                            fondos: [fondo],
                                            expanded: false))
                }
            }
        }
        
    }
    
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].fondos.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections[indexPath.section].expanded) {
            return 135
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let header = ExpandableHeaderView()
        //header.customInit(title: sections[section].genre, section: section, delegate: self)
        
        let nib = UINib(nibName: "ExpandableHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "ExpandableHeaderView")
        
        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "ExpandableHeaderView")
        let header = cell as! ExpandableHeaderView
        header.customInit(title: sections[section].subcuenta, section: section, delegate: self)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaldosCell") as! SaldosCell
        
        let section = sections[indexPath.section]
        let fondo = section.fondos[indexPath.row]
        
        cell.tituloLabel.text = fondo["FO"] as? String
        cell.ccLabel.text = fondo["CC"] as? String
        cell.ibanLabel.text = fondo["IB"] as? String
        //cell.saldoLabel.text = (fondo["MS"] as? NSNumber)?.stringValue
        let monedaSymbol = fondo["MO"] as! String == "Colones" ? "‎₡" : "$"
        cell.saldoLabel.text = "\(monedaSymbol)\((fondo["MS"] as! NSNumber).formatAmount())"
        
        return cell
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].expanded = !sections[section].expanded
        
        if(sections[section].expanded) {
            header.colorView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
            header.imageView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
            header.nameLabel.textColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1)
            
            let downArrow = UIImage(named: "blue_arrow_down")
            header.imageView.image = downArrow
        }
        else {
            header.colorView.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1)
            header.imageView.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1)
            header.nameLabel.textColor = UIColor.white
            
            let whiteArrow = UIImage(named: "white_arrow")
            header.imageView.image = whiteArrow
        }
        
        tableView.beginUpdates()
        for i in 0 ..< sections[section].fondos.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let simpleVC = SimpleVC()
        //simpleVC.customInit(imageName: sections[indexPath.section].movies[indexPath.row])
        //tableView.deselectRow(at: indexPath, animated: true)
        //self.navigationController?.pushViewController(simpleVC, animated: true)
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



// MARK: -

/// The basic prototype table view cell that provides only a single label for textual presentation.
class SaldosCell: UITableViewCell {
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var ccLabel: UILabel!
    @IBOutlet weak var ibanLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    
    //@IBOutlet var roundView: UIView!
    
}
