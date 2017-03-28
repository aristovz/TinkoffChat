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

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "IncomingMessageCell", bundle: nil) , forCellReuseIdentifier: "incomingCell")
        tableView.register(UINib(nibName: "OutgoingMessageCell", bundle: nil) , forCellReuseIdentifier: "outgoingCell")

        hideKeyboardWhenTappedAround()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    self.scrollToLastRow()
                }
            })
        }
    }

    func scrollToLastRow() {
        let lastSectionIndex = self.tableView.numberOfSections - 1
        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex) - 1
        let pathToLastRow = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        self.tableView.scrollToRow(at: pathToLastRow, at: .bottom, animated: true)
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identefier = indexPath.row % 2 == 0 ? "incomingCell" : "outgoingCell"
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: identefier) as! MessageCell
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
