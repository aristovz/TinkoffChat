//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 24.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConversationsListViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //var onlineDialogs = [Peer]()
    var offlineDialogs = [Peer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Global.currentUser == nil {
            Global.loadCurrentUser {
                manager = CommunicationManager(delegate: self)
                manager.start()
            }
        }
        else {
            manager = CommunicationManager(delegate: self)
            manager.start()
        }
        
        tableView.register(UINib(nibName: "DialogCell", bundle: nil) , forCellReuseIdentifier: "dialogCell")

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toProfileViewContoller))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Global.loadCurrentUser {
            self.avatarImageView.image = Global.currentUser!.image
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    func toProfileViewContoller() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        present(vc, animated: true, completion: nil)
    }
    
    func getCurrentDialog(_ indexPath: IndexPath) -> Peer {
        return indexPath.section == 0 ? manager.foundedPeers[indexPath.row] : offlineDialogs[indexPath.row]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Online" }
        else { return "History" }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard manager != nil else { return 0 }
        
        return section == 0 ? manager.foundedPeers.count : offlineDialogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogCell
        
        let currentDialog = getCurrentDialog(indexPath)
        let lastMessage = currentDialog.lastMessage
        
        cell.name = currentDialog.name
        cell.date = lastMessage?.date
        cell.message = lastMessage?.text
        cell.online = currentDialog.online
        cell.hasUnreadMessage = currentDialog.hasUnreadMessage
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = .lightGray
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ConversationViewController") as! ConversationViewController
        
        let currentDialog = getCurrentDialog(indexPath)
        vc.currentDialog = currentDialog

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationsListViewController: CommunicationManagerDelegate {
    func didFoundUser(userID: String, userName: String?) {
        self.tableView.reloadData()
    }
    
    func didLostUser(userID: String) {
        self.tableView.reloadData()
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
