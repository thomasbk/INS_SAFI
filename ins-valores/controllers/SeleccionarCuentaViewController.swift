//
//  SeleccionarCuentaViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 5/21/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class SeleccionarCuentaViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var codigoCuentaLabel: UILabel!
    
    @IBOutlet weak var nombreCuentaLabel: UILabel!
    @IBOutlet weak var cerrarButton: UIButton!
    
    var user: User!
    var cuentas: [Cuenta]! = []
    var filteredArray:[Cuenta]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "SAFI_background")!)
        
        // Do any additional setup after loading the view.
        let rightImageView = UIImageView.init(image: UIImage.init(named: "user-icon"))
        rightImageView.frame = CGRect(x: 0, y: 0, width: (rightImageView.image?.size.width)!+10.0, height: (rightImageView.image?.size.height)!)
        rightImageView.contentMode = .center;
        
        searchTextField.rightView = rightImageView; // Set right view as image view
        
        codigoCuentaLabel.layer.borderColor = UIColor.lightGray.cgColor
        codigoCuentaLabel.layer.borderWidth = 1.0
        nombreCuentaLabel.layer.borderColor = UIColor.lightGray.cgColor
        nombreCuentaLabel.layer.borderWidth = 1.0
        
        cerrarButton.centerVertically()
        
        
        user = User.getInstance()
        cuentas = user.getCuentas() as! [Cuenta]
        filteredArray = cuentas
        
        searchTextField.addTarget(self, action: #selector(SeleccionarCuentaViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if(textField.text!.count > 0){
            filteredArray = cuentas.filter {
                $0.cNombre.range(of: textField.text!, options: .caseInsensitive) != nil
            }
        }
        else {
            filteredArray = cuentas
        }
        tableView.reloadData()
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cuentaCell") as! CuentaCell
        
        cell.codigoLabel.text = filteredArray[indexPath.row].cId
        cell.nombreLabel.text = filteredArray[indexPath.row].cNombre
        
        return cell
        
    }
    
    /// Stub for responding to user row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCuenta = filteredArray[indexPath.row]
        user.setSelectedCuentaIndex(cuentas.index(of: selectedCuenta)!)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "selectCuentaSegue", sender: nil)
    }
    
}

// MARK: -

/// The basic prototype table view cell that provides only a single label for textual presentation.
class CuentaCell: UITableViewCell {
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    
    override func didMoveToSuperview() {
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        cellView.layer.borderWidth = 1.0
        
    }
}
