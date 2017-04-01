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
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonToTextInputsViews(views: [userInfoTextView])
        
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.selectPhoto))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
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
        present(successAlert, animated: true, completion: nil)
    }
    
    func showErrorAlert() {
        
    }
    
    // - MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // - MARK: ViewControllerButtonActions
    @IBAction func GCDsaveButtonAction(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        sender.setTitle("", for: .normal)
        loadingIndicator.center = sender.center
        loadingIndicator.startAnimating()
        showSuccessAlert()
        loadingIndicator.stopAnimating()
        sender.setTitle(title, for: .normal)
        //dismiss(animated: true, completion: nil)
    }
    
    @IBAction func operationSaveButtonAction(_ sender: UIButton) {
        let title = sender.titleLabel?.text
        sender.setTitle("", for: .normal)
        loadingIndicator.center = sender.center
        loadingIndicator.startAnimating()
        showErrorAlert()
        loadingIndicator.stopAnimating()
        sender.setTitle(title, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func colorButtonsAction(_ sender: UIButton) {
        colorTextLabel.textColor = sender.backgroundColor
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
