//
//  TalkService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 27/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol TalkListener: class {
    func updateTalks(talks: [Talk]?, error: NSError?)
}

class TalkService: NSObject {
    let TALKS_UPDATE_TIMER_INTERVAL = 10.0

    private let talkNetworkService: TalkNetworkService
    private let iosService: IosService
    private let currentUserService: CurrentUserService

    //TODO - JUST AWFUL
    var messageService: MessageService!

    var updateTimer: NSTimer?
    
    var talks = [Talk]()
    
    weak var friendsTalkListener: TalkListener?

    //TODO - Should be deleted
    init(talkNetworkService: TalkNetworkService, iosService: IosService, currentUserService: CurrentUserService) {
        self.talkNetworkService = talkNetworkService
        self.iosService = iosService
        self.currentUserService = currentUserService
    }

    init(talkNetworkService: TalkNetworkService, iosService: IosService, currentUserService: CurrentUserService, messageService: MessageService) {
        self.talkNetworkService = talkNetworkService
        self.iosService = iosService
        self.messageService = messageService
        self.currentUserService = currentUserService
    }

    func getTalkByLogin(friend: String) -> Talk? {
        for talk in talks {
            if (currentUserService.getFriendLogin(talk) == friend) {
                return talk
            }
        }

        return nil
    }
    
    func clearTalks() {
        talks = [Talk]()
        iosService.updatePushBadge(talks)
        updateTimer?.invalidate()
        messageService.clear()
        
        let singleModeTalk = createSingleModeTalk()
        talks.append(singleModeTalk)
    }
    
    func setTalksByNewUser(user: User) {
        self.talks = user.talks
        let singleModeTalk = createSingleModeTalk()
        talks.append(singleModeTalk)
        
        iosService.updatePushBadge(talks)
        
        //timer worked only on main
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTimer?.invalidate()

            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.TALKS_UPDATE_TIMER_INTERVAL, target: self, selector: #selector(TalkService.getNewUnreadTalks), userInfo: nil, repeats: true)
        })

        messageService.startUpdateTimer()
        
        fireUpdateTalksEvent()
    }
    
    private func createSingleModeTalk() -> Talk {
        //add singleModeTalk
        let singleModeTalk = Talk(id: "0")
        singleModeTalk.isSingleMode = true
        let singleModeUser = User(login: "Pass and Play", suggestions: 0)
        singleModeTalk.users.append(singleModeUser.login)
        singleModeTalk.users.append("")
        
        //load local messages for singleModeTalk
        singleModeTalk.messages = CoreMessage.getAllLocal()
        if (singleModeTalk.messages.count > 0) {
            singleModeTalk.lastMessage = singleModeTalk.messages.last
        }
        
        return singleModeTalk
    }
    
    func getNewUnreadTalks() {
        if (!currentUserService.isLoggedIn()) {
            return
        }
        
        let lastUpdate = self.getTalksLastUpdate()

        talkNetworkService.getNewUnreadTalks(lastUpdate) { (talks, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    self.friendsTalkListener?.updateTalks(nil, error: requestError)
                } else {
                    if let newTalks = talks {
                        for talk in newTalks {
                            self.updateOrCreateTalkInArray(talk)
                            self.messageService.fireMessagesUpdate(talk.id)
                        }

                        self.fireUpdateTalksEvent()
                    } else {
                        //no new talks - do nothing
                    }
                }
            })
        }
    }
    
    func addNewTalk(talk: Talk) {
        talks.append(talk)
        fireUpdateTalksEvent()
    }
    
    func updateTalkInArray(talk: Talk, withMessages: Bool = false) {
        updateOrCreateTalkInArray(talk, withMessages: withMessages)
        fireUpdateTalksEvent()
    }
    
    func talkViewed(talkId: String) {
        let talk = getByTalkId(talkId)!
        
        if (talk.decipherStatus != DecipherStatus.No) {
            talk.decipherStatus = DecipherStatus.No
            updateTalkInArray(talk)
            messageService.markTalkAsReaded(talk)
        }
    }
    
    func getByTalkId(talkId: String) -> Talk? {
        for talk in talks {
            if (talkId == talk.id) {
                return talk
            }
        }
        
        return nil
    }
    
    func getSingleModeTalk() -> Talk? {
        for talk in talks {
            if (talk.id == "0") {
                return talk
            }
        }
        
        //should never happen
        return nil
    }
    
    private func fireUpdateTalksEvent() {
        iosService.updatePushBadge(talks)
        self.friendsTalkListener?.updateTalks(talks, error: nil)
    }
    
    private func updateOrCreateTalkInArray(talk: Talk, withMessages: Bool = false) {
        for i in 0..<talks.count {
            if (talk.id == talks[i].id) {
                
                if (withMessages) {
                    //update with messages
                    talk.messages = talk.messages.sort { (message1, message2) -> Bool in
                        return message1.timestamp.isLess(message2.timestamp)
                    }
                    talk.lastMessage = talk.messages.last
                } else {
                    //save early downloaded messages before update
                    talk.messages = talks[i].messages
                }
                
                talks[i] = talk
                return
            }
        }
        
        talks.append(talk)
    }
    
    private func getTalksLastUpdate() -> NSDate {
        var lastUpdate: NSDate?
        
        for talk in talks {
            if (talk.isSingleMode) {
                continue
            }
            
            if (lastUpdate == nil || talk.lastUpdate.isGreater(lastUpdate!)) {
                lastUpdate = talk.lastUpdate
            }
        }
        
        if (lastUpdate != nil) {
            return lastUpdate!
        } else {
            return NSDate.defaultPast()
        }
    }
}