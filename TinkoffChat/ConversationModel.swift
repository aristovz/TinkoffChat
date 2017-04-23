//
//  ConversationsModel.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 23.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation

protocol IConversationModel: class {
    weak var delegate: IConversationModelDelegate? { get set }
    
    var currentPeer: Peer { get set }
    func send(_ message: Message)
}

protocol IConversationModelDelegate: class {
    func refreshMessages(at message: Message)
    func didLostConnection()
}

class ConversationModel: IConversationModel, IConversationServiceDelegate {
    
    weak var delegate: IConversationModelDelegate?

    var currentPeer: Peer
    
    let conversationService: IConversationService
    
    init(currentPeer: Peer, conversationService: IConversationService) {
        self.currentPeer = currentPeer
        self.conversationService = conversationService
        self.conversationService.delegate = self
    }
    
    // MARK: - IConversationModel methods
    
    func send(_ message: Message) {
        conversationService.sendMessage(message, to: currentPeer) { (success, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if success {
                self.currentPeer.messages.append(message)
                self.delegate?.refreshMessages(at: message)
            }
            else {
                print("Can't send message to peer: \(self.currentPeer)")
            }
        }
    }
    
    // MARK: - IConversationServiceDelegate methods
    
    func didLostUser(_ userID: String) {
        if currentPeer.id == userID {
            delegate?.didLostConnection()
        }
    }
    
    func didRecieve(_ message: Message, from userID: String) {
        if currentPeer.id == userID {
            delegate?.refreshMessages(at: message)
        }
    }
}
