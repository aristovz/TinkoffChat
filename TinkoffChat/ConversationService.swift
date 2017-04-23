//
//  ConversationService.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 23.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation

protocol IConversationService: class {
    weak var delegate: IConversationServiceDelegate? { get set }
    
    func sendMessage(_ message: Message, to peer: Peer, completionHandler: @escaping (Bool, Error?) -> Void)
}

protocol IConversationServiceDelegate: class {
    func didLostUser(_ userID: String)
    func didRecieve(_ message: Message, from userID: String)
}

class ConversationService: IConversationService {
    
    weak var delegate: IConversationServiceDelegate?

    let manager: ICommunicatorDialogManager
    
    init(manager: ICommunicatorDialogManager) {
        self.manager = manager
        self.manager.dialogDelegate = self
    }
    
    func sendMessage(_ message: Message, to peer: Peer, completionHandler: @escaping (Bool, Error?) -> Void) {
        manager.sendMessage(string: message.text, to: peer) { (success, error) in
            completionHandler(success, error)
        }
    }
}

extension ConversationService: CommunicationDialogManagerDelegate {
   
    func didReceive(_ message: Message, from userID: String) {
        delegate?.didRecieve(message, from: userID)
    }
    
    func didLostUser(_ userID: String) {
        delegate?.didLostUser(userID)
    }
}
