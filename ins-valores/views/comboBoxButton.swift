//
//  comboBoxButton.swift
//  INSSAFI
//
//  Created by Pro Retina on 7/21/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

@IBDesignable
class comboBoxButton: UIButton {
    var borderWidth = 1.0
    var boderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
    @IBInspectable
    var titleText: String? {
        didSet {
            self.setTitle(titleText, for: .normal)
            self.setTitleColor(UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1), for: .normal)
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        self.clipsToBounds = true
        //self.layer.cornerRadius = self.frame.size.width / 1.0
        self.layer.borderColor = boderColor
        self.layer.borderWidth = CGFloat(borderWidth)
        
        //self.setImage(UIImage(named: "combobox_arrow"), for: .normal)
        self.backgroundColor = UIColor.white
        
        imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 20), bottom: 5, right: 5)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
}
