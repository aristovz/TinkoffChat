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
