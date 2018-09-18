//
//  SeguridadViewController.swift
//  INSSAFI
//
//  Created by Pro Retina on 8/6/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class SeguridadViewController: UIViewController {
    @IBOutlet weak var loginSwitch: UISwitch!
    @IBOutlet weak var transaccionesSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        loginSwitch.isOn = defaults.bool(forKey: "LoginTouchID")
        transaccionesSwitch.isOn = defaults.bool(forKey: "TransaccionTouchID")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "LoginTouchID")
        defaults.synchronize()
    }
    
    @IBAction func transaccionesAction(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "TransaccionTouchID")
        defaults.synchronize()
    }

}
