//
//  ConversationsModel.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 23.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation

protocol IConversationListModel: class {
    weak var delegate: IConversationListModelDelegate? { get set }
    func startDialog(with peer: Peer)
}

protocol IConversationListModelDelegate: class {
    func refreshConversationsList(list: Set<Peer>)
    func dialogDidStart(with peer: Peer)
}

class ConversationListModel: IConversationListModel, IConversationListServiceDelegate {
   
    weak var delegate: IConversationListModelDelegate?
    
    private var foundedPeers: Set<Peer>
    
    let conversationService: IConversationListService
    
    init(conversationService: IConversationListService) {
        foundedPeers = []
       
        self.conversationService = conversationService
        self.conversationService.delegate = self
    }
   
    // MARK: - IConversationModel methods
    
    func startDialog(with peer: Peer) {
        conversationService.startDialog(with: peer)
        delegate?.dialogDidStart(with: peer)
    }
    
    // MARK: - IConversationListServiceDelegate methods
    
    func didFound(_ peer: Peer) {
        foundedPeers.insert(peer)
        delegate?.refreshConversationsList(list: foundedPeers)
    }
    
    func didLost(_ userID: String) {
        if let peer = foundedPeers.first(where: { $0.id == userID }) {
            foundedPeers.remove(peer)

            delegate?.refreshConversationsList(list: foundedPeers)
        }
    }
    
    func didReceive(_ message: Message, from userID: String) {
        if var currentPeer = foundedPeers.first(where: { $0.id == userID }) {
            currentPeer.messages.append(message)
            foundedPeers.update(with: currentPeer)
            
            delegate?.refreshConversationsList(list: foundedPeers)
        }
    }
}
