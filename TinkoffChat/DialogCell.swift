//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 24.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class DialogCell: UITableViewCell, ConversationsCellConfiguration {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var indicatorWidthConstraint: NSLayoutConstraint!
    
    private var _date: Date? = nil
    private var _online: Bool = false
    private var _hasUnreadMessage: Bool = false

    private let formatter = DateFormatter()
    
    let standartFont = UIFont(name: "Helvetica Neue", size: 17)
    let mediumFont = UIFont(name: "HelveticaNeue-Medium", size: 17)
    let noMessageFont = UIFont(name: "HelveticaNeue-Italic", size: 17)
    
    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var message: String? {
        get { return messageLabel.text }
        set {
            if let newMessage = newValue {
                messageLabel.font = standartFont
                messageLabel.text = newMessage
            }
            else {
                messageLabel.font = noMessageFont
                messageLabel.text = "No messages yet"
            }
        }
    }
    
    var date: Date? {
        get { return _date }
        set {
            _date = newValue
            
            if let newDate = newValue {
                if Calendar.current.compare(Date(), to: newDate, toGranularity: .day).rawValue == 0 {
                    formatter.dateFormat = "HH:mm"
                }
                else { formatter.dateFormat = "dd MMM" }
                
                dateLabel.text = formatter.string(from: newDate)
            }
            else { dateLabel.text = "" }
        }
    }
    
    var online: Bool {
        get { return _online }
        set {
            _online = newValue
            self.backgroundColor = newValue ? .backgroundOnlineCell : .backgroundOfflineCell
            nameLabel.textColor = newValue ? .darkText : .darkGray
            nameLabel.textColor = newValue ? .darkGray : .gray
        }
    }
    
    var hasUnreadMessage: Bool {
        get { return _hasUnreadMessage }
        set {
            _hasUnreadMessage = newValue
            indicatorWidthConstraint.constant = newValue ? 20 : 0
            messageLabel.font = newValue ? mediumFont : messageLabel.font
        }
    }
}

protocol ConversationsCellConfiguration: class {
    var name: String? { get set }
    var message: String? { get set }
    var date: Date? { get set }
    var online: Bool { get set }
    var hasUnreadMessage: Bool { get set }
}
