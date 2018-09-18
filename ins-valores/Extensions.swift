//
//  Extensions.swift
//  INSSAFI
//
//  Created by Novacomp on 7/24/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = ""
        currencyFormatter.locale = Locale(identifier: "es_CR")
        currencyFormatter.maximumFractionDigits = 0
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        if(amountWithPrefix == "₡" || amountWithPrefix == "") {
            amountWithPrefix = "0"
        }
        
        let number = Int(amountWithPrefix )! as NSNumber
        
        
        return currencyFormatter.string(from: number)!
        
    }
    
    // formatting text for currency textField
    func flattenCurrency() -> String {
        
        var newAmount = self.replacingOccurrences(of: ".", with: "")
        newAmount = newAmount.replacingOccurrences(of: ",", with: ".")
        
        return newAmount
        
    }
}



extension NSNumber {
    
    
    func formatAmount() -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "es_CR")
        currencyFormatter.currencySymbol = ""
        currencyFormatter.maximumFractionDigits = 2
        
        let amount = currencyFormatter.string(from: self)!
        
        return amount
        
        //return currencyFormatter.string(from: Int(trip.value(forKeyPath: "price") as! String)! as NSNumber)!
        
    }
}


extension UITextField {
    
    func makeBlue () {
        let borderColor = UIColor(red: 0/255, green: 113/255, blue: 184/255, alpha: 1)
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1
        self.textColor = borderColor
    }
}
