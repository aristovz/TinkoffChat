//
//  Extensions.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 18.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showWarningAlert(text: String) {
        let alertWarning = UIAlertController(title: "Внимание", message: text, preferredStyle: .alert)
        present(alertWarning, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func addDoneButtonToTextInputsViews(views: [UIView], toolBarStyle: UIBarStyle = .blackTranslucent, buttonColor: UIColor = .yellow) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barStyle = toolBarStyle
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIViewController.dismissKeyboard))
        doneButton.tintColor = buttonColor
        
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        _ = views.map {
            if let textView = $0 as? UITextView {
                textView.inputAccessoryView = toolBar
            }
            else if let textField = $0 as? UITextField {
                textField.inputAccessoryView = toolBar
            }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    class var background: UIColor {
        return UIColor(hexString: "3F4657")
    }
    
    class var backgroundOfflineCell: UIColor {
        return UIColor(hexString: "323847").withAlphaComponent(0.6)
    }
    
    class var backgroundOnlineCell: UIColor {
        return UIColor(hexString: "FFF59D")
    }
    
    class var darkField: UIColor {
        return UIColor(hexString: "323847").withAlphaComponent(0.83)
    }
}
