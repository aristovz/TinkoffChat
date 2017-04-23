//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 09.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

var manager: CommunicationManager!

protocol ICommunicatorManager: class {
    weak var delegate: CommunicationManagerDelegate? { get set }
    weak var dialogDelegate: CommunicationDialogManagerDelegate? { get set }
    func invitePeer(peer: Peer)
}

protocol ICommunicatorDialogManager: class {
    weak var dialogDelegate: CommunicationDialogManagerDelegate? { get set }
    
    func sendMessage(string: String, to peer: Peer, completionHandler: @escaping (Bool, Error?) -> Void)
}

protocol CommunicationManagerDelegate: class {
    func didFound(_ peer: Peer)
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
}

protocol CommunicationDialogManagerDelegate: class {
    func didReceive(_ message: Message, from userID: String)
    func didLostUser(_ userID: String)
}

class CommunicationManager: NSObject, ICommunicatorManager, ICommunicatorDialogManager {
    
    weak var delegate: CommunicationManagerDelegate?
    weak var dialogDelegate: CommunicationDialogManagerDelegate?
    
    var communicator: MultipeerCommunicator!
    
    override init() {
        super.init()
        
        communicator = MultipeerCommunicator(delegate: self)
        start()
    }
    
    func start() {
        communicator.browser.startBrowsingForPeers()
        communicator.advertiser.startAdvertisingPeer()
    }
    
    func stop() {
        communicator.browser.stopBrowsingForPeers()
        communicator.advertiser.stopAdvertisingPeer()
    }
    
    func sendMessage(string: String, to peer: Peer, completionHandler: @escaping (Bool, Error?) -> Void) {
        communicator.sendMessage(string: string, to: peer, completionHandler: completionHandler)
    }
    
    func invitePeer(peer: Peer) {
        communicator.invitePeer(peer: peer)
    }
}

extension CommunicationManager: CommunicatorDelegate {
    func failedToStartBrowsingForUsers(error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }

    func failedToStartAdvertising(error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func didFoundUser(peer: MCPeerID, userName: String?) {
        let peer = Peer(peerID: peer, name: userName, messages: [], online: true, hasUnreadMessage: false)
    
        delegate?.didFound(peer)
    }
    
    func didLostUser(userID: String) {
        dialogDelegate?.didLostUser(userID)
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        let message = Message(text: text, date: Date(), type: .Incoming)
        
        dialogDelegate?.didReceive(message, from: fromUser)
    }
}
