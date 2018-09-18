//
//  DropdownView.swift
//  INSSAFI
//
//  Created by Pro Retina on 5/17/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class DropdownView: UIView, UITableViewDelegate, UITableViewDataSource  {
    
    var dropdownOptions = [String]()
    
    var tableView = UITableView()
    
    var delegate : DropdownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        
        self.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        self.layer.borderWidth = 1.0
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(tableView)
        
        if #available(iOS 9.0, *) {
            //tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            //tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            //tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            //tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let option = dropdownOptions[indexPath.row]
        
        cell.textLabel?.text = option
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.setTag(selected:indexPath.row)
        self.delegate.dropDownPressed(string: dropdownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
