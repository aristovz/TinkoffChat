//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 09.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Peer {
    var id: String?
    var name: String?
    var messages = [Message]()
    var online: Bool
    var hasUnreadMessage: Bool
    
    var lastMessage: Message? {
        get {
            return messages.max { mes1, mes2 in mes1.date < mes2.date }
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

@objc protocol CommunicationManagerDelegate: class {
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
    
    @objc optional func failedToStartBrowsingForUsers(error: Error)
    @objc optional func failedToStartAdvertising(error: Error)
}

class CommunicationManager: NSObject {
    static let shared = CommunicationManager()
    
    var foundedPeers = [Peer]()
    
    weak var delegate: CommunicationManagerDelegate?
    
    var isAdvertisingStarded = false
    
    var communicator: MultipeerCommunicator {
        get {
            return MultipeerCommunicator.shared
        }
    }
    
    override init() {
        super.init()
        
        communicator.delegate = self
    }
    
    func start() {
        communicator.browser.startBrowsingForPeers()
        communicator.advertiser.startAdvertisingPeer()
    }
    
    func stop() {
        communicator.browser.stopBrowsingForPeers()
        communicator.advertiser.stopAdvertisingPeer()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())) {
        communicator.sendMessage(string: string, to: userID, completionHandler: completionHandler)
    }
    
    func invitePeer(userID: String) {
        print(userID)
        
        let session = MCSession(peer: communicator.peer)
        
        session.delegate = self
        
        communicator.invitePeer(userID: userID, to: session)
    }
}

extension CommunicationManager: CommunicatorDelegate {
    func failedToStartBrowsingForUsers(error: Error) {
        delegate?.failedToStartBrowsingForUsers?(error: error)
    }

    func failedToStartAdvertising(error: Error) {
        delegate?.failedToStartAdvertising?(error: error)
    }
    
    func didFoundUser(userID: String, userName: String?) {
        guard foundedPeers.first(where: {$0.id == userID}) == nil else {
            return
        }
        
        let peer = Peer(id: userID, name: userName, messages: [], online: true, hasUnreadMessage: false)
        foundedPeers.append(peer)
        
        delegate?.didFoundUser(userID: userID, userName: userName)
    }
    
    func didLostUser(userID: String) {
        if let index = foundedPeers.index(where: { $0.id == userID }) {
            foundedPeers.remove(at: index)
        }
        
        delegate?.didLostUser(userID: userID)
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        delegate?.didReceiveMessage(text: text, fromUser: fromUser, toUser: toUser)
    }
}

extension CommunicationManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            //delegate?.connectedWithPeer(peerID)
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "receivedMPCDataNotification"), object: dictionary)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
}
