//
//  TalkService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 27/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol TalkListener: class {
    func updateTalks(talks: [FriendTalk]?, error: NSError?)
}

class TalkService: Service {
    let TALKS_UPDATE_TIMER_INTERVAL = 10.0

    private let talkNetworkService: TalkNetworkService
    private let iosService: IosService
    private let currentUserService: CurrentUserService
    private let coreMessageService: CoreMessageService

    //TODO - JUST AWFUL
    var messageService: MessageService!

    var updateTimer: NSTimer?
    
    var talks = [FriendTalk]()
    
    weak var friendsTalkListener: TalkListener?

    //TODO - Should be deleted
    init(talkNetworkService: TalkNetworkService, iosService: IosService, currentUserService: CurrentUserService, coreMessageService: CoreMessageService) {
        self.talkNetworkService = talkNetworkService
        self.iosService = iosService
        self.currentUserService = currentUserService
        self.coreMessageService = coreMessageService
    }

    init(talkNetworkService: TalkNetworkService, iosService: IosService, currentUserService: CurrentUserService, coreMessageService: CoreMessageService, messageService: MessageService) {
        self.talkNetworkService = talkNetworkService
        self.iosService = iosService
        self.messageService = messageService
        self.currentUserService = currentUserService
        self.coreMessageService = coreMessageService
    }

    func getTalkByLogin(friend: String) -> FriendTalk? {
        for talk in talks {
            if (currentUserService.getFriendLogin(talk) == friend) {
                return talk
            }
        }

        return nil
    }
    
    func clearTalks() {
        talks = [FriendTalk]()
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
    
    private func createSingleModeTalk() -> FriendTalk {
        //add singleModeTalk
        let singleModeTalk = FriendTalk(id: "0")
        singleModeTalk.isSingleMode = true
        let singleModeUser = User(login: "Pass and Play")
        singleModeTalk.users.append(singleModeUser.login)
        singleModeTalk.users.append("")
        
        //load local messages for singleModeTalk
        singleModeTalk.messages = coreMessageService.getAllLocal()
        if (singleModeTalk.messages.count > 0) {
            singleModeTalk.lastMessage = singleModeTalk.messages.last as? RemoteMessage
        }
        
        return singleModeTalk
    }
    
    func getNewUnreadTalks() {
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
    
    func addNewTalk(talk: FriendTalk) {
        talks.append(talk)
        fireUpdateTalksEvent()
    }
    
    func updateTalkInArray(talk: FriendTalk, withMessages: Bool = false) {
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
    
    func getByTalkId(talkId: String) -> FriendTalk? {
        for talk in talks {
            if (talkId == talk.id) {
                return talk
            }
        }
        
        return nil
    }
    
    func getSingleModeTalk() -> FriendTalk? {
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
    
    private func updateOrCreateTalkInArray(talk: FriendTalk, withMessages: Bool = false) {
        for i in 0..<talks.count {
            if (talk.id == talks[i].id) {
                
                if (withMessages) {
                    //update with messages
                    talk.messages = talk.messages.sort { (message1, message2) -> Bool in
                        return message1.timestamp.isLess(message2.timestamp)
                    }
                    talk.lastMessage = talk.messages.last as? RemoteMessage
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