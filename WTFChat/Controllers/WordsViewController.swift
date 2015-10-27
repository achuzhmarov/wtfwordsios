//
//  WordsViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 03/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

protocol SuggestionComputer {
    func suggestionTapped(word: Word)
}

class WordsViewController: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var message: Message?
    var rows = WordsField()
    var tempRows = WordsField()
    
    //for use in viewOnly
    var useCipherText = false
    var selfAuthor = false
    
    var suggestionComputer: SuggestionComputer?
    var isFirstUpdate = true
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.getRowsCount()
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordsRowCell", forIndexPath: indexPath) as UITableViewCell
        
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
                self.addConstraint(horizontalConstraint)
                
                if (wordContainer.getWidth() > getMaxWidth()) {
                    let rightHorizontalConstraint = wordContainer.getFullRowHorizontalConstraint(cell.contentView)
                    self.addConstraint(rightHorizontalConstraint)
                }
            } else {
                let horizontalConstraint = wordContainer.getNextHorizontalConstraint(previousContainer)
                self.addConstraint(horizontalConstraint)
            }
            
            let verticalConstraint = wordContainer.getVerticalConstraint(cell.contentView)
            self.addConstraint(verticalConstraint)
            
            previousContainer = wordContainer
        }
        
        return cell
    }
    
    func setNewMessage(message: Message, useCipherText: Bool = false, selfAuthor: Bool = false) {
        self.message = message
        self.useCipherText = useCipherText
        self.selfAuthor = selfAuthor
        createView()
        isFirstUpdate = false
    }
    
    func updateMessage(message: Message) {
        updateMessage(message, tries: nil)
    }
    
    func updateMessage(message: Message, tries: [String]?) {
        if (self.message != nil) {
            self.message = message
            
            if (needUpdate()) {
                updateView()
                audioHelper.playSound("success")
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
        isFirstUpdate = false
    }
    
    func needUpdate() -> Bool {
        var newWords = message!.getWordsOnly()
        var wordContainers = rows.getAllWordContainers()
        
        for i in 0..<wordContainers.count {
            if (newWords[i].wordType != wordContainers[i].word.wordType) {
                return true
            }
        }
        
        return false
    }
    
    func animateWarning(guesses: [String]?) {
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.word.wordType == WordType.New) {
                if (messageCipher.wasCloseTry(wordContainer.word, guessWords: guesses)) {
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
            if (wordContainer.word.wordType == WordType.New) {
                if (messageCipher.wasCloseTry(wordContainer.word, guessWords: guesses)) {
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
            audioHelper.playSound("warning")
        } else if (wasError) {
            audioHelper.playSound("error")
        }
    }
    
    func createView() {
        rows = WordsField()
        updateViewHelper(rows)
        rows.showContainers()
        
        self.reloadData()
    }
    
    func updateView() {
        tempRows = WordsField()
        
        updateViewHelper(tempRows)
        rows.clearFromView()
        rows = tempRows
        tempRows = WordsField()
        rows.showContainers()
        
        self.reloadData()
    }
    
    private func updateViewHelper(targetRows: WordsField) {
        var isNewRow = false
        
        for word in message!.getWordsWithoutSpaces() {
            if (word.wordType == WordType.LineBreak) {
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
        let wordWidth = WordLabelContainer.getWordWidth(word)
        
        if (rowWidth + wordWidth <= getMaxWidth()) {
            targetRows.append(wordContainer)
        } else {
            var row = [WordLabelContainer]()
            row.append(wordContainer)
            targetRows.append(row)
        }
    }
    
    func createLabelForWord(word: Word) -> WordLabelContainer {
        let wordContainer = WordLabelContainer(word: word, useCipherText: useCipherText, selfAuthor: selfAuthor)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "useSuggestion:")
        wordContainer.label.addGestureRecognizer(tap)
        
        return wordContainer
    }
    
    func useSuggestion(sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let wordContainer = label.container!
        
        self.suggestionComputer?.suggestionTapped(wordContainer.originalWord)
    }
    
    func getRowWidth(row: [WordLabelContainer]) -> CGFloat {
        var width = CGFloat(0)
        
        for wordContainer in row {
            width += wordContainer.getWidth() + wordContainer.labelHorizontalMargin
        }
        
        return width
    }
    
    func getMaxWidth() -> CGFloat {
        if (isFirstUpdate) {
            return self.bounds.width - CGFloat(16)
        } else {
            return self.bounds.width
        }
    }
}
