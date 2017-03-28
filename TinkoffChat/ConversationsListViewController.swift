//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 24.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class ConversationsListViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "DialogCell", bundle: nil) , forCellReuseIdentifier: "dialogCell")

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toProfileViewContoller))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    func toProfileViewContoller() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        present(vc, animated: true, completion: nil)
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogCell
        
        cell.online = indexPath.section == 0
        
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
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
