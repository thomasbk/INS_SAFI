//
//  ExpandableHeaderView.swift
//  INSValores
//
//  Created by Pro Retina on 5/2/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    var expanded: Bool! = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func headerSelected(_ sender: Any) {
        
        delegate?.toggleSection(header: self, section: self.section)
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        //self.contentView.backgroundColor = UIColor.white
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.nameLabel.text = title
        self.section = section
        self.delegate = delegate
        
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        self.imageView.layer.borderWidth = 1.0
        
        self.colorView.layer.masksToBounds = true
        self.colorView.layer.borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1).cgColor
        self.colorView.layer.borderWidth = 1.0
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.textLabel?.textColor = UIColor.white
//        self.contentView.backgroundColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1.0)
//    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
