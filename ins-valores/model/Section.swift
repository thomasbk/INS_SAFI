//
//  Section.swift
//  INSValores
//
//  Created by Pro Retina on 5/2/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import Foundation

struct Section {
    var subcuenta: String!
    var fondos: [JSONStandard]!
    var expanded: Bool!
    
    
    typealias JSONStandard = Dictionary<String, Any>
    
    init(subcuenta: String, fondos: [JSONStandard], expanded: Bool) {
        self.subcuenta = subcuenta
        self.fondos = fondos
        self.expanded = expanded
    }
}
