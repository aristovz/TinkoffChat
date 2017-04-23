//
//  IncomingMessageCell.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 28.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell, MessageCellConfiguration {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var _date: Date? = nil
    
    private let formatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var messageText: String? {
        get {
            return messageLabel.text
        }
        set {
            messageLabel.text = newValue
        }
    }
    
    var date: Date? {
        get {
            return _date
        }
        set {
            _date = newValue
            
            if let newDate = newValue {
                if Calendar.current.compare(Date(), to: newDate, toGranularity: .day).rawValue == 0 {
                    formatter.dateFormat = "HH:mm"
                }
                else { formatter.dateFormat = "dd MMM" }
                
                dateLabel.text = formatter.string(from: newDate)
            }
        }
    }
}

protocol MessageCellConfiguration: class {
    var messageText: String? { get set }
    var date: Date? { get set }
}
