//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 28.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    var currentDialog: Peer? {
        didSet {
            navigationItem.title = currentDialog?.name
        }
    }
    
    let noMessageLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = label.font.withSize(12)
        label.text = "Нет сообщений"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        
        if let currentPeer = currentDialog {
            if currentPeer.session == nil {
                manager.invitePeer(peer: currentPeer.peerID!)
           }
        }
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.title = ""
        
        hideKeyboardWhenTappedAround()
        
        tableView.register(UINib(nibName: "IncomingMessageCell", bundle: nil) , forCellReuseIdentifier: "incomingCell")
        tableView.register(UINib(nibName: "OutgoingMessageCell", bundle: nil) , forCellReuseIdentifier: "outgoingCell")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if currentDialog?.messages.count == 0 { self.tableView.addSubview(noMessageLabel) }
        
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
       if let currentPeer = currentDialog {
            manager.sendMessage(string: messageTextField.text ?? "", to: currentPeer.id!) { (success, error) in
                
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                
                if success {
                    tableView.reloadData()
                }
                else {
                    print("Error send message")
                }
            }
        }
        
        messageTextField.text = ""
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if manager != nil, let peer = manager.getPeer(userID: currentDialog!.id!) {
            return peer.messages.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentMessage = manager.getPeer(userID: currentDialog!.id!)?.messages[indexPath.row] {
            let identefier = currentMessage.type == .Incoming ? "incomingCell" : "outgoingCell"
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: identefier) as! MessageCell
            cell.messageText = currentMessage.text
            cell.date = currentMessage.date
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "incomingCell") as! MessageCell
            cell.messageText = "Error"
            return cell
        }
    }
}

extension ConversationViewController: CommunicationManagerDelegate {
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFoundUser(userID: String, userName: String?) {
        
    }
    
    func didLostUser(userID: String) {
        if userID == currentDialog!.id {
            messageTextField.placeholder = "Пользователь вышел из сети!"
            sendButtonOutlet.isEnabled = false
            sendButtonOutlet.setTitleColor(.darkGray, for: .normal)
        }
    }
}
