//
//  WordsViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 03/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

protocol HintComputer: class {
    func hintTapped(word: Word)
}

class WordsViewController: UITableView, UITableViewDataSource, UITableViewDelegate {
    private let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    private let audioService: AudioService = serviceLocator.get(AudioService)

    var message: Message?
    var rows = WordsField()
    var tempRows = WordsField()
    
    //for use in viewOnly
    var useCipherText = false
    var selfAuthor = false

    var fontSize: CGFloat = 17
    var isHidedText = false
    
    weak var hintComputer: HintComputer?
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.getRowsCount()
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordsRowCell", forIndexPath: indexPath) as UITableViewCell
        cell.backgroundColor = UIColor.clearColor()

        let row = rows.getRow(indexPath.row)
        
        var first = true
        var previousContainer: WordLabelContainer!
        
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        
        for wordContainer in row {
            cell.contentView.addSubview(wordContainer.label)
            
            if (first) {
                first = false
                
                let horizontalConstraint = wordContainer.getFirstHorizontalConstraint(cell.contentView)
                cell.contentView.addConstraint(horizontalConstraint)
                
                if (wordContainer.getWidth() > getMaxWidth()) {
                    let rightHorizontalConstraint = wordContainer.getFullRowHorizontalConstraint(cell.contentView)
                    cell.contentView.addConstraint(rightHorizontalConstraint)
                }
            } else {
                let horizontalConstraint = wordContainer.getNextHorizontalConstraint(previousContainer)
                cell.contentView.addConstraint(horizontalConstraint)
            }
            
            let verticalConstraint = wordContainer.getVerticalConstraint(cell.contentView)
            cell.contentView.addConstraint(verticalConstraint)

            cell.selectionStyle = .None

            previousContainer = wordContainer
        }
        
        return cell
    }
    
    func setNewMessage(message: Message, useCipherText: Bool = false, selfAuthor: Bool = false) {
        self.message = message
        self.useCipherText = useCipherText
        self.selfAuthor = selfAuthor
        createView()
    }
    
    func updateMessage(message: Message) {
        updateMessage(message, tries: nil)
    }
    
    func updateMessage(message: Message, tries: [String]?) {
        if (self.message != nil) {
            self.message = message
            
            if (needUpdate()) {
                updateView()
                audioService.playSound("success")
                animateWarning(tries)
            } else {
                animateError(tries)
            }
            return
        } else {
            self.message = message
            createView()
        }
        
        self.reloadData()
    }
    
    func needUpdate() -> Bool {
        var newWords = message!.getWordsOnly()
        var wordContainers = rows.getAllWordContainers()
        
        for i in 0..<wordContainers.count {
            if (newWords[i].type != wordContainers[i].word.type) {
                return true
            }
        }
        
        return false
    }
    
    func animateWarning(guesses: [String]?) {
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.word.type == WordType.New) {
                if (messageCipherService.wasCloseTry(wordContainer.word, guessWords: guesses)) {
                    wordContainer.animateWarning()
                    wordContainer.word.wasCloseTry = true
                    wordContainer.originalWord.wasCloseTry = true
                }
            }
        }
    }
    
    func animateError(guesses: [String]?) {
        var wasWarning = false
        var wasError = false
        
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.word.type == WordType.New) {
                if (messageCipherService.wasCloseTry(wordContainer.word, guessWords: guesses)) {
                    wordContainer.animateWarning()
                    wordContainer.word.wasCloseTry = true
                    wordContainer.originalWord.wasCloseTry = true
                    wasWarning = true
                } else {
                    wordContainer.animateError()
                    wasError = true
                }
            }
        }
        
        if (wasWarning) {
            audioService.playSound("warning")
        } else if (wasError) {
            audioService.playSound("error")
        }
    }
    
    func createView() {
        rows = WordsField()
        updateViewHelper(rows)
        showContainers(false)
        
        self.reloadData()
    }
    
    func updateView() {
        tempRows = WordsField()
        
        updateViewHelper(tempRows)
        rows.clearFromView()
        rows = tempRows
        tempRows = WordsField()
        showContainers()
        
        self.reloadData()
    }

    private func showContainers(animated: Bool = true) {
        if (animated) {
            alpha = 0

            UIView.animateWithDuration(0.3, delay: 0,
                    options: [], animations: {
                self.alpha = 1
            }, completion: nil)
        }
    }
    
    private func updateViewHelper(targetRows: WordsField) {
        var isNewRow = false
        
        for word in message!.getWordsWithoutSpaces() {
            if (word.type == WordType.LineBreak) {
                isNewRow = true
            } else {
                addWord(word, targetRows: targetRows, isNewRow: isNewRow)
                isNewRow = false
            }
        }
    }
    
    func addWord(word: Word, targetRows: WordsField, isNewRow: Bool = false) {
        let wordContainer = createLabelForWord(word)
        
        if (targetRows.isEmpty() || isNewRow) {
            var row = [WordLabelContainer]()
            row.append(wordContainer)
            targetRows.append(row)
            return
        }
        
        let row = targetRows.getLastRow()
        
        let rowWidth = getRowWidth(row)
        let wordWidth = wordContainer.getWidth()
        
        if (rowWidth + wordWidth <= getMaxWidth()) {
            targetRows.append(wordContainer)
        } else {
            var row = [WordLabelContainer]()
            row.append(wordContainer)
            targetRows.append(row)
        }
    }
    
    func createLabelForWord(word: Word) -> WordLabelContainer {
        let wordContainer = WordLabelContainer(word: word, useCipherText: useCipherText, selfAuthor: selfAuthor, isHidedText: isHidedText, fontSize: fontSize)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WordsViewController.useSuggestion(_:)))
        wordContainer.label.addGestureRecognizer(tap)
        
        return wordContainer
    }
    
    func useSuggestion(sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let wordContainer = label.tagObject as! WordLabelContainer
        
        self.hintComputer?.hintTapped(wordContainer.originalWord)
    }
    
    func getRowWidth(row: [WordLabelContainer]) -> CGFloat {
        var width = CGFloat(0)
        
        for wordContainer in row {
            width += wordContainer.getWidth() + wordContainer.labelHorizontalMargin
        }
        
        return width
    }
    
    var maxWidth = CGFloat(0)
    
    func getMaxWidth() -> CGFloat {
        if (maxWidth == 0) {
            maxWidth = self.bounds.width - CGFloat(16)
        }
        
        return maxWidth
    }
    
    func updateMaxWidth() {
        maxWidth = self.bounds.width
    }
}
