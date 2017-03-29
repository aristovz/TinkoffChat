//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 24.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

struct Dialog {
    var name: String?
    var messages: [Message]?
    var online: Bool
    var hasUnreadMessage: Bool
    
    var lastMessage: Message? {
        get {
            return messages?.max { mes1, mes2 in mes1.date < mes2.date }
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

class ConversationsListViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!

    var onlineDialogs = [Dialog]()
    var offlineDialogs = [Dialog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "DialogCell", bundle: nil) , forCellReuseIdentifier: "dialogCell")

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toProfileViewContoller))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(setupData), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        
        self.refreshControl?.beginRefreshingManually()
    }
    
    override func viewDidLayoutSubviews() {
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    func toProfileViewContoller() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        present(vc, animated: true, completion: nil)
    }
    
    func setupData() {
        onlineDialogs.removeAll()
        offlineDialogs.removeAll()
        
        let messages = [[Message(text: "Q", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Привет, как дела? Чем занимаешься?", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Разнообразный и богатый опыт укрепление и развитие структуры играет важную роль в формировании направлений прогрессивного развития. Таким образом начало повседневной работы по формированию позиции обеспечивает широкому кругу (специалистов) участие в формировании системы обучения кадров, соответствует", date: getDateForMessage(), type: .Incoming),
                         
                         Message(text: "W", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Слегка попахивая французские слова", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Стоял под её лица карло вырубил буратино нас в комнате громко тикали. Шелковистые, белокурые локоны выбивались из головы. Вечерами она не слышала от боли фрукты. Красота! первый акт софьи и собака ушла, с четырьмя ногами. Солнечные часы их отличают от него была распахнута. Любви были плохие он имел свиней.", date: getDateForMessage(), type: .Outgoing)],
                        
                        [Message(text: "S", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Товарищи! дальнейшее развитие", date: getDateForMessage(), type: .Incoming),
                         Message(text: "С другой стороны реализация намеченных плановых заданий позволяет оценить значение существенных финансовых и административных условий. Повседневная практика показывает, что укрепление и развитие структуры требуют от нас анализа существенных финансовых и административных условий.", date: getDateForMessage(), type: .Incoming),
                         
                         Message(text: "L", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "К автобусу бежала одевающаяся", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Безухов носил панталоны с толку иванушку бросился спать и неприступная. Вспоминал мать птицы, кроме слова дура тельняшка. Была гордая и излили. Хранил свою смерть в открытую форточку ворвался. Нежностью смотрели друг на земле, но и часто. Дятел уселся и неприступная как перевозили революционеры. Поросят находится кудрявый хвостик, по полю.", date: getDateForMessage(), type: .Outgoing)],
                       
                        [Message(text: "m", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Равным образом постоянный количественный", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Задача организации, в особенности же дальнейшее развитие различных форм деятельности играет важную роль в формировании систем массового участия. Значимость этих проблем настолько очевидна, что реализация намеченных плановых заданий требуют от нас анализа позиций, занимаемых участниками в отношении поставленных задач.", date: Date(), type: .Incoming),
                         
                         Message(text: "u", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Была гордая и тут боец вспомнил", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Во двор и взвыл от страха суворов был зажиточный. Неприступная как танкист сидело невиданное. Поезда и упал на камешке. Могли бы так сделать! длинными зимними холодными вечерами она. Длинные зимние холодные свитера стене висели. Птицы, кроме вороны истинно русской натурой очень. Софьи и нижегородские сделать!", date: Date(), type: .Outgoing)],
                        
                        [Message(text: "x", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Повседневная практика показывает", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Таким образом новая модель организационной деятельности представляет собой интересный эксперимент проверки соответствующий условий активизации. Повседневная практика показывает, что сложившаяся структура организации требуют от нас анализа новых предложений.", date: getDateForMessage(), type: .Incoming),
                         
                         Message(text: "j", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Хвостик, по полю, слегка попахивая", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Она вешала на земле, но и молчалина произошел под дождём. Излили ее на стене висели фрукты. Петр заломов нес красное знамя, по моде женщина, а. Составляет квадратных человека на лбу панталоны с нежностью. Кащей бессмертный хранил свою смерть в космос млекопитающего состоит из сочинения. Грустно опустила зад в одном.", date: getDateForMessage(), type: .Outgoing)],
                        
                        [Message(text: "k", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Значимость этих проблем настолько очевидна", date: getDateForMessage(), type: .Incoming),
                         Message(text: "Товарищи! укрепление и развитие структуры в значительной степени обуславливает создание соответствующий условий активизации. Равным образом постоянный количественный рост и сфера нашей активности позволяет выполнять важные задания по разработке системы обучения кадров, соответствует насущным потребностям", date: getDateForMessage(), type: .Incoming),
                         
                         Message(text: "t", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Уселся и тут боец вспомнил, что постель.", date: getDateForMessage(), type: .Outgoing),
                         Message(text: "Лоси забежали во двор. Холодные свитера висели фрукты с высоким жабо их отличают от него была. Зимнюю спячку любила природу и. Перевозили революционеры свои листовки.в чемоданах с нежностью смотрели друг на уши лапшу. Плотность населения австралии составляет квадратных человека на земле.", date: getDateForMessage(), type: .Outgoing)],
                        [], []]
        
        let names = ["Георгий Якушев", "Александр Дмитриев", "Степан Давыдов", "Борис Костин", "Юрий Никитин", "Дмитрий Ковалёв", "Семён Меркушев", "Евгений Тарасов", "Борис Игнатьев", "Тимофей Агафонов"]
        
        for name in names {
            let currentMessages = messages[Int(arc4random_uniform(UInt32(messages.count)))]
            let sortedCurrentMessages = currentMessages.sorted(by: { x, y in x.date < y.date })
            
            let hasUnreadMessage = currentMessages.count != 0 ? arc4random_uniform(2) == 0 : false
            let online = arc4random_uniform(2) == 0
            
            let dialog = Dialog(name: name, messages: sortedCurrentMessages, online: online, hasUnreadMessage: hasUnreadMessage)

            online ? onlineDialogs.append(dialog) : offlineDialogs.append(dialog)
        }
        
        var index = 0
        var count = onlineDialogs.count
        for _ in 0..<count {
            if onlineDialogs[index].messages?.count == 0 {
                let tempDialog = onlineDialogs[index]
                onlineDialogs.remove(at: index)
                onlineDialogs.append(tempDialog)
                count -= 1
            }
            else { index += 1 }
        }
        
        onlineDialogs.sort { a, b in
            if let aLastMessage = a.lastMessage, let bLastMessage = b.lastMessage {
                return aLastMessage.date > bLastMessage.date
            }
            
            return false
        }
        
        index = 0
        count = offlineDialogs.count
        for _ in 0..<count {
            if offlineDialogs[index].messages?.count == 0 {
                let tempDialog = offlineDialogs[index]
                offlineDialogs.remove(at: index)
                offlineDialogs.append(tempDialog)
                count -= 1
            }
            else { index += 1 }
        }
        
        offlineDialogs.sort { a, b in
            if let aLastMessage = a.lastMessage, let bLastMessage = b.lastMessage {
                return aLastMessage.date > bLastMessage.date
            }
            
            return false
        }
        
        self.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func getDateForMessage() -> Date {
        return Date().addingTimeInterval(TimeInterval(-60 * Int(arc4random_uniform(60 * 48))))
    }

    func getCurrentDialog(_ indexPath: IndexPath) -> Dialog {
        return indexPath.section == 0 ? onlineDialogs[indexPath.row] : offlineDialogs[indexPath.row]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Online" }
        else { return "History" }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? onlineDialogs.count : offlineDialogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogCell
        
        let currentDialog = getCurrentDialog(indexPath)
        let lastMessage = currentDialog.lastMessage
        
        cell.name = currentDialog.name
        cell.date = lastMessage?.date
        cell.message = lastMessage?.text
        cell.online = currentDialog.online
        cell.hasUnreadMessage = currentDialog.hasUnreadMessage
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = .lightGray
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ConversationViewController") as! ConversationViewController
        
        vc.currentDialog = getCurrentDialog(indexPath)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
