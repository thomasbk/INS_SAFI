//
//  NotificacionesViewController.swift
//  INSSAFI
//
//  Created by Novacomp on 8/3/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class NotificacionesViewController: UIViewController {
    @IBOutlet weak var swNotifications: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    swNotifications.setOn(OneSignal.getPermissionSubscriptionState().subscriptionStatus.subscribed, animated: true)
    }
    
    @IBAction func swNotifications(_ sender: UISwitch) {
        OneSignal.setSubscription(sender.isOn)
    }
    
}
