//
//  ConversationListAssembly.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 23.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import UIKit

class ConversationListAssembly {
    func conversationListViewCotnroller() -> UINavigationController {
        let model = conversationListModel()
        
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "startVC") as! UINavigationController
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "conversationListViewCotnroller") as! ConversationsListViewController
        
        vc.model = model
        
        navVC.setViewControllers([vc], animated: false)
        
        return navVC
    }
    
    // MARK: - PRIVATE SECTION
    
    private func conversationListModel() -> IConversationListModel {
        return ConversationListModel(conversationService: conversationListService())
    }
    
    private func conversationListService() -> IConversationListService {
        return ConversationListService(manager: manager())
    }
    
    private func manager() -> ICommunicatorManager {
        return CommunicationManager()
    }

}
