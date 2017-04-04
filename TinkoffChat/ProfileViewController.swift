//
//  ViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 06.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var colorTextLabel: UILabel!
    
    @IBOutlet var colorButtonsOutlet: [UIButton]!
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var userInfoTextView: UITextView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var GCDSaveButtonOutlet: UIButton!
    
    @IBOutlet weak var OperationSaveButtonOutlet: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var savingDictionary: [String: AnyObject] {
        get {
            var dictionary = [String: AnyObject]()
            dictionary["name"] = loginTextField.text as AnyObject
            dictionary["about"] = userInfoTextView.text as AnyObject
            dictionary["image"] = UIImagePNGRepresentation(avatarImageView.image!)! as AnyObject
            dictionary["color"] = colorTextLabel.textColor.toHexString() as AnyObject
            
            return dictionary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonToTextInputsViews(views: [userInfoTextView])
        
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.selectPhoto))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
        
        GCDDataManager.sharedInstance.loadData { (currentUser) in
            guard let user = currentUser else { return }
            
            self.loginTextField.text = user.name
            self.userInfoTextView.text = user.about
            self.avatarImageView.image = user.image
            self.colorTextLabel.textColor = user.color
        }
    }
    
    override func viewDidLayoutSubviews() {
        colorButtonsOutlet.forEach { $0.layer.cornerRadius = $0.frame.width / 2 }
        
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    func selectPhoto() {
        let alert: UIAlertController = UIAlertController(title: "Загрузить фото", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Сделать снимок", style: .default) {
            (alert: UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.showWarningAlert(text: "На вашем устройстве камера недоступна!")
            }
        }
        
        let gallaryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) {
            (alert: UIAlertAction!) -> Void in
            
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Удалить фото", style: .destructive) {
            (alert: UIAlertAction!) -> Void in

            let deleteAlert: UIAlertController = UIAlertController(title: "Вы действительно хотите удалить фото?", message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Да", style: .default) {
                (alert: UIAlertAction!) -> Void in
                
                self.avatarImageView.image = #imageLiteral(resourceName: "defaultUser")
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            
            deleteAlert.addAction(yesAction)
            deleteAlert.addAction(cancelAction)
            
            self.present(deleteAlert, animated: true, completion: nil)
        }
        deleteAction.isEnabled = avatarImageView.image != #imageLiteral(resourceName: "defaultUser")
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        // Add the actions
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
    
        self.present(alert, animated: true, completion: nil)
    }

    func showSuccessAlert() {
        let successAlert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        successAlert.addAction(okAction)
        
        present(successAlert, animated: true, completion: nil)
    }
    
    func showErrorAlert(savingFunc: @escaping () -> ()) {
        let errorAlert = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        let repeatAction = UIAlertAction(title: "Повторить", style: .destructive) {
            (alert: UIAlertAction!) -> Void in
            savingFunc()
        }
        
        errorAlert.addAction(okAction)
        errorAlert.addAction(repeatAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    func GCDSaveData() {
        let title = GCDSaveButtonOutlet.titleLabel?.text
        GCDSaveButtonOutlet.setTitle("", for: .normal)
        OperationSaveButtonOutlet.isEnabled = false
        GCDSaveButtonOutlet.isEnabled = false
        loadingIndicator.center = GCDSaveButtonOutlet.center
        loadingIndicator.startAnimating()
        
        GCDDataManager.sharedInstance.save(data: savingDictionary) { (error) in
            DispatchQueue.main.async {
                self.GCDSaveButtonOutlet.isEnabled = true
                self.OperationSaveButtonOutlet.isEnabled = true
                self.loadingIndicator.stopAnimating()
                self.GCDSaveButtonOutlet.setTitle(title, for: .normal)
                
                if error != nil {
                    self.showErrorAlert(savingFunc: self.GCDSaveData)
                }
                else {
                    self.showSuccessAlert()
                }
            }
        }
    }
    
    func OperationSaveData() {
        let title = OperationSaveButtonOutlet.titleLabel?.text
        OperationSaveButtonOutlet.setTitle("", for: .normal)
        GCDSaveButtonOutlet.isEnabled = false
        OperationSaveButtonOutlet.isEnabled = false
        loadingIndicator.center = OperationSaveButtonOutlet.center
        loadingIndicator.startAnimating()
        
//        OperationDataManager.sharedInstance.save(data: savingDictionary) { (error) in
//            self.GCDSaveButtonOutlet.isEnabled = true
//            self.OperationSaveButtonOutlet.isEnabled = true
//            
//            if error != nil {
//                self.showErrorAlert(savingFunc: self.OperationSaveData)
//            }
//            else {
//                self.showSuccessAlert()
//                self.loadingIndicator.stopAnimating()
//                self.OperationSaveButtonOutlet.setTitle(title, for: .normal)
//            }
//        }
    }
    
    // - MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // - MARK: ViewControllerButtonActions
    @IBAction func GCDsaveButtonAction(_ sender: UIButton) {
        GCDSaveData()
        //dismiss(animated: true, completion: nil)
    }
    
    @IBAction func operationSaveButtonAction(_ sender: UIButton) {
        OperationSaveData()
        //dismiss(animated: true, completion: nil)
    }
    
    @IBAction func colorButtonsAction(_ sender: UIButton) {
        print(sender.backgroundColor!.toHexString())
        colorTextLabel.textColor = UIColor(hexString: sender.backgroundColor!.toHexString())
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// - MARK: UIImagePickerControllerDelegate Methods

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
