//
//  ConversationsService.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 23.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Peer: Hashable {
    var peerID: MCPeerID?
    var name: String?
    var messages = [Message]()
    var online: Bool
    var hasUnreadMessage: Bool
    
    var id: String? {
        get {
            return self.peerID?.displayName
        }
    }
    
    var lastMessage: Message? {
        get {
            return messages.max { mes1, mes2 in mes1.date < mes2.date }
        }
    }
    
    static func ==(lhs: Peer, rhs: Peer) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        get {
            return name!.hashValue
        }
    }
}

struct Message {
    enum MessageType: Int {
        case Incoming = 0
        case Outgoing = 1
    }
    
    var text: String
    var date: Date
    var type: MessageType?
}

protocol IConversationListService: class {
    weak var delegate: IConversationListServiceDelegate? { get set }
    
    func startDialog(with peer: Peer)
}

protocol IConversationListServiceDelegate: class {
    func didFound(_ peer: Peer)
    func didLost(_ userID: String)
    func didReceive(_ message: Message, from userID: String)
}

class ConversationListService: IConversationListService {

    weak var delegate: IConversationListServiceDelegate?
    weak var dialogDelegate: IConversationListServiceDelegate?
    
    let manager: ICommunicatorManager
    
    init(manager: ICommunicatorManager) {
        self.manager = manager
        self.manager.delegate = self
        self.manager.dialogDelegate = self
    }
    
    func startDialog(with peer: Peer) {
        manager.invitePeer(peer: peer)
    }
}

extension ConversationListService: CommunicationManagerDelegate, CommunicationDialogManagerDelegate {
    func didFound(_ peer: Peer) {
        delegate?.didFound(peer)
    }
    
    func didLostUser(_ userID: String) {
        delegate?.didLost(userID)
    }
    
    func didReceive(_ message: Message, from userID: String) {
        delegate?.didReceive(message, from: userID)
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print(error.localizedDescription)
    }
    
    func failedToStartAdvertising(error: Error) {
        print(error.localizedDescription)
    }
}
