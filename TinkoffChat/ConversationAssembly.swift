//
//  ConversationAssembly.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 23.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import UIKit

class ConversationAssembly {
    func conversationViewCotnroller(currentPeer: Peer) -> ConversationViewController {
        let model = conversationModel(currentPeer: currentPeer)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "conversationViewController") as! ConversationViewController
        
        vc.model = model
        
        return vc
    }
    
    // MARK: - PRIVATE SECTION
    
    private func conversationModel(currentPeer: Peer) -> IConversationModel {
        return ConversationModel(currentPeer: currentPeer, conversationService: conversationService())
    }
    
    private func conversationService() -> IConversationService {
        return ConversationService(manager: manager())
    }
    
    private func manager() -> ICommunicatorDialogManager {
        return CommunicationManager()
    }
}
