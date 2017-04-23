//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 28.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    let noMessageLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = label.font.withSize(12)
        label.text = "Нет сообщений"
        
        return label
    }()
    
    var model: IConversationModel? {
        didSet {
            navigationItem.title = model?.currentPeer.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model?.delegate = self
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.title = ""
        
        hideKeyboardWhenTappedAround()
        
        tableView.register(UINib(nibName: "IncomingMessageCell", bundle: nil) , forCellReuseIdentifier: "incomingCell")
        tableView.register(UINib(nibName: "OutgoingMessageCell", bundle: nil) , forCellReuseIdentifier: "outgoingCell")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if model?.currentPeer.messages.count == 0 { self.tableView.addSubview(noMessageLabel) }
        
        tableView.scrollToLastRow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint.constant = isKeyboardShowing ? keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutSubviews()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    self.tableView.scrollToLastRow()
                }
            })
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        let message = Message(text: messageTextField.text ?? "", date: Date(), type: .Outgoing)
        model?.send(message)
        messageTextField.text = ""
    }
    
    // MARK: - UITableView methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.currentPeer.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentMessage = model?.currentPeer.messages[indexPath.row]
        let identefier = currentMessage?.type == .Incoming ? "incomingCell" : "outgoingCell"
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: identefier) as! MessageCell
        cell.messageText = currentMessage?.text
        cell.date = currentMessage?.date
        return cell
    }
}

extension ConversationViewController: IConversationModelDelegate {
    func refreshMessages(at message: Message) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didLostConnection() {
        messageTextField.placeholder = "Пользователь вышел из сети!"
        sendButtonOutlet.isEnabled = false
        sendButtonOutlet.setTitleColor(.darkGray, for: .normal)
    }
}
