//
//  DropdownButton.swift
//  INSSAFI
//
//  Created by Pro Retina on 5/17/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

protocol DropdownProtocol {
    func dropDownPressed(string : String)
    func setTag(selected: Int)
}

class DropdownButton: UIButton, DropdownProtocol {
    
    
    var boderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
    
    @IBInspectable
    var titleText: String? {
        didSet {
            self.setTitle(titleText, for: .normal)
            self.setTitleColor(UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1), for: .normal)
        }
    }
    
    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        self.sendActions(for: UIControlEvents.touchUpInside)
        
        self.dismissDropDown()
    }
    
    func setTag(selected: Int) {
        self.tag = selected
    }
    
    var dropView = DropdownView()
    
    //var height = NSLayoutConstraint()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        
        //dropView = DropdownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        //dropView.delegate = self
        //dropView.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    func setup() {
        self.clipsToBounds = true
        self.layer.borderColor = boderColor
        self.layer.borderWidth = 1.0
        
        //self.setImage(UIImage(named: "combobox_arrow"), for: .normal)
        
        imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 20), bottom: 5, right: 5)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    override func didMoveToSuperview() {
        
        //self.imageEdgeInsets = UIEdgeInsetsMake(0, self.frame.size.width - (20), 0, 0)
        //self.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        
        //self.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        //self.layer.borderWidth = 1.0
        
        //dropView = DropdownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView = DropdownView.init(frame: CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y+self.frame.size.height, width: self.frame.size.width, height: 0))
        dropView.delegate = self
        //dropView.translatesAutoresizingMaskIntoConstraints = false
        
        self.superview?.addSubview(dropView)
        self.superview?.bringSubview(toFront: dropView)
        if #available(iOS 9.0, *) {
            //dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            //dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            //dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            //height = dropView.heightAnchor.constraint(equalToConstant: 0)
        } else {
            // Fallback on earlier versions
        }
    }
    
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            
            //self.sendActions(for: UIControlEvents.touchUpInside)
            
            isOpen = true
            
            //NSLayoutConstraint.deactivate([self.height])
            
            //if self.dropView.tableView.contentSize.height > 150 {
            //    self.height.constant = 150
            //} else {
            //    self.height.constant = self.dropView.tableView.contentSize.height
            //}
            
            
            //NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                //self.dropView.layoutIfNeeded()
                //self.dropView.center.y += self.dropView.frame.height / 2
                self.dropView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 150)
                self.dropView.tableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 150)
                //self.dropView.tableView.contentSize.height = 150
                //self.dropView.tableView.contentSize.width = self.frame.size.width
                
            }, completion: nil)
            
        } else {
            isOpen = false
            
            //NSLayoutConstraint.deactivate([self.height])
            //self.height.constant = 0
            //NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                //self.dropView.center.y -= self.dropView.frame.height / 2
                //self.dropView.layoutIfNeeded()
                
                self.dropView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
                self.dropView.tableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 0)
                
            }, completion: nil)
            
        }
    }
    
    func dismissDropDown() {
        isOpen = false
        //NSLayoutConstraint.deactivate([self.height])
        //self.height.constant = 0
        //NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            //self.dropView.center.y -= self.dropView.frame.height / 2
            //self.dropView.layoutIfNeeded()
            
            self.dropView.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
            self.dropView.tableView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 0)
            
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
}
