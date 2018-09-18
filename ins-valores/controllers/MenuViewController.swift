//
//  MenuViewController.swift
//  INSValores
//
//  Created by Pro Retina on 5/3/18.
//  Copyright © 2018 Novacomp. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var saldosButton: UIButton!
    @IBOutlet weak var solicitudesButton: UIButton!
    @IBOutlet weak var consultasButton: UIButton!
    @IBOutlet weak var indicadoresButton: UIButton!
    @IBOutlet weak var adminCuentasButton: UIButton!
    @IBOutlet weak var configuracionButton: UIButton!
    @IBOutlet weak var cerrarButton: UIButton!
    
    @IBOutlet weak var saludoLabel: UILabel!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var proximoVencimientoLabel: UILabel!
    @IBOutlet weak var ultimoIngresoLabel: UILabel!
    
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigationbar color gradient
        var colors = [UIColor]()
        colors.append(UIColor(red: 8/255, green: 77/255, blue: 158/255, alpha: 1))
        colors.append(UIColor(red: 1/255, green: 34/255, blue: 86/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)
        navigationController?.navigationBar.setBackgroundImage()
        
//        let image = UIImage(named: "ins_safilogo")
//        imageView.image = image
//        let backButton = UIBarButtonItem(customView: self.backButtonView)
//        self.backButtonView.heightAnchor.constraint(equalToConstant: 45).isActive = true
//        self.backButtonView.widthAnchor.constraint(equalToConstant: 75).isActive = true
//        self.navigationItem.leftBarButtonItem = backButton
        
//        let barButtonAppearance = UIBarButtonItem.appearance()
//        let backButton = UIImage(named: "white_arrow_back")
//        let backButtonImage = backButton?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 10)
//        barButtonAppearance.setBackgroundImage(backButtonImage, for: .normal, barMetrics: .default)
        
        
        saldosButton.centerVertically()
        solicitudesButton.centerVertically()
        consultasButton.centerVertically()
        indicadoresButton.centerVertically()
        adminCuentasButton.centerVertically()
        configuracionButton.centerVertically()
        cerrarButton.centerVertically()
        
        
        user = User.getInstance()

        // Do any additional setup after loading the view.
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12 : saludoLabel.text = "Buenos días,"
        case 12..<18 : saludoLabel.text = "Buenas tardes,"
        default: saludoLabel.text = "Buenas noches,"
        }
        
        nombreLabel.text = user.getName()
        //proximoVencimientoLabel.text = user.get
        
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        let fecha = format.string(from: Date())
        
        
        ultimoIngresoLabel.text = "Último ingreso: \(user.getLastSession()!)"
        proximoVencimientoLabel.text = user.getCurrentCuenta().vencimiento
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func popView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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


extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 1, y: 0)
    }
    
    func createGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UINavigationBar {
    
    func setGradientBackground(colors: [UIColor]) {
        
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        //setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
        setBackgroundImage(gradientLayer.createGradientImage()!.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch), for: UIBarMetrics.default)
        //self.appearance().setBackgroundImage(gradientLayer.createGradientImage()!.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch), for: .default)

    }
    
    func setBackgroundImage() {
        
        if let foundView = self.viewWithTag(88) {
            foundView.removeFromSuperview()
        }
        // set logo in navigation bar
        let imageView = UIImageView(frame: CGRect(x: self.frame.width/2 - 35, y: -17, width: 70, height: 70))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "ins_safilogo")
        imageView.image = image
        imageView.tag = 88
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        imageView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        
    }
    
        
}

extension UIButton {
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
}




extension UIViewController
{
    
    func showAlert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
        
    }
}



extension NSNumber
{
    func stringFormattedValue() -> String
    {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "es_CR")
        currencyFormatter.currencySymbol = ""
        currencyFormatter.maximumFractionDigits = 2
        
        return currencyFormatter.string(from: self)!
    }
}

extension String
{
    func stringFormattedValue() -> String
    {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale(identifier: "es_CR")
        currencyFormatter.currencySymbol = ""
        currencyFormatter.maximumFractionDigits = 2
        
        return currencyFormatter.string(from: Double(self)! as NSNumber)!
    }
}
