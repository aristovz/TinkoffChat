//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 24.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConversationsListViewController: UITableViewController, IConversationListModelDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    private var dataSource: [Peer] = []
    var model: IConversationListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model?.delegate = self
        
        tableView.register(UINib(nibName: "DialogCell", bundle: nil) , forCellReuseIdentifier: "dialogCell")

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toProfileViewContoller))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.avatarImageView.image = Global.currentUser!.image
        
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
    
    // MARK: - IConversationsModelDelegate methods
    
    func refreshConversationsList(list: Set<Peer>) {
        self.dataSource = Array(list)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func dialogDidStart(with peer: Peer) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
       let vc = appDelegate.rootAssembly.conversationModel.conversationViewCotnroller(currentPeer: peer)
        navigationController?.pushViewController(vc, animated: true)
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
        return section == 0 ? dataSource.count : 0//offlineDialogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogCell
        
        let currentDialog = dataSource[indexPath.row]//getCurrentDialog(indexPath)
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
        model?.startDialog(with: dataSource[indexPath.row])
    }
}
