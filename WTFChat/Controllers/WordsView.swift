//
//  WordsView.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 09/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

protocol SuggestionComputer {
    func suggestionTapped(word: Word)
}

class WordsView: UIView {
    var message: Message?
    var rows = WordsField()
    var tempRows = WordsField()
    
    var suggestionComputer: SuggestionComputer?
    
    func updateMessage(message: Message) {
        updateMessage(message, tries: nil)
    }
    
    func updateMessage(message: Message, tries: [String]?) {
        if (self.message != nil) {
            self.message = message
            
            if (needUpdate()) {
                updateView()
                audioHelper.playSound("success")
            } else {
                animateError(tries)
            }
            return
        } else {
            self.message = message
            createView()
        }
    }
    
    func needUpdate() -> Bool {
        var newWords = message!.getWordsWithoutDelimiters()
        var wordContainers = rows.getAllWordContainers()
        
        for i in 0..<wordContainers.count {
            if (newWords[i].wordType != wordContainers[i].word.wordType) {
                return true
            }
        }
        
        return false
    }
    
    func animateError(tries: [String]?) {
        var wasWarning = false
        var wasError = false
        
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.word.wordType == WordType.New) {
                if (wasCloseTry(wordContainer.word, tries: tries)) {
                    wordContainer.animateWarning()
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
    
    func wasCloseTry(word: Word, tries: [String]?) -> Bool {
        if (tries != nil) {
            for curTry in tries! {
                if Tools.calcStringDistance(word.text.uppercaseString, bStr: curTry.uppercaseString) == 1 {
                    return true
                }
            }
        }
        
        return false
    }
    
    func createView() {
        for word in message!.getWordsWithoutDelimiters() {
            addWord(word, targetRows: rows)
        }
        
        rows.showContainers()
    }
    
    func updateView() {
        tempRows = WordsField()
            
        for word in message!.getWordsWithoutDelimiters() {
            addWord(word, targetRows: tempRows)
        }
            
        rows.clearFromView()
        rows = tempRows
        tempRows = WordsField()
        rows.showContainers()
    }
    
    func addWord(word: Word, targetRows: WordsField) {
        if (targetRows.isEmpty()) {
            return addWordToNewRow(word, targetRows: targetRows)
        }
        
        let row = targetRows.getLastRow()

        let rowWidth = getRowWidth(row)
        let wordWidth = WordLabelContainer.getWordWidth(word)
        
        if (rowWidth + wordWidth <= getMaxWidth()) {
            addWordToLastRow(word, targetRows: targetRows)
        } else {
            addWordToNewRow(word, targetRows: targetRows)
        }
    }
    
    func createLabelForWord(word: Word) -> WordLabelContainer {
        let wordContainer = WordLabelContainer(word: word)
        self.addSubview(wordContainer.label)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "useSuggestion:")
        wordContainer.label.addGestureRecognizer(tap)
        
        return wordContainer
    }
    
    func useSuggestion(sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let wordContainer = label.container!
        
        self.suggestionComputer?.suggestionTapped(wordContainer.originalWord)
    }
    
    func addWordToNewRow(word: Word, targetRows: WordsField) {
        let wordContainer = createLabelForWord(word)
        
        let horizontalConstraint = wordContainer.getFirstRowHorizontalConstraint(self)
        self.addConstraint(horizontalConstraint)
        
        if (targetRows.isEmpty()) {
            let verticalConstraint = wordContainer.getFirstRowVerticalConstraint(self)
            self.addConstraint(verticalConstraint)
        } else {
            let verticalConstraint = wordContainer.getNextRowVerticalConstraint(targetRows.getLastContainer())
            self.addConstraint(verticalConstraint)
        }
        
        if (wordContainer.getWidth() > getMaxWidth()) {
            let rightHorizontalConstraint = wordContainer.getFullRowHorizontalConstraint(self)
            self.addConstraint(rightHorizontalConstraint)
        }
        
        var row = [WordLabelContainer]()
        row.append(wordContainer)
        targetRows.append(row)
    }
    
    func addWordToLastRow(word: Word, targetRows: WordsField) {
        let wordContainer = createLabelForWord(word)
        
        let horizontalConstraint = wordContainer.getNextLabelHorizontalConstraint(targetRows.getLastContainer())
        self.addConstraint(horizontalConstraint)
        
        let verticalConstraint = wordContainer.getNextLabelVerticalConstraint(targetRows.getLastContainer())
        self.addConstraint(verticalConstraint)
        
        targetRows.append(wordContainer)
    }
    
    func getRowWidth(row: [WordLabelContainer]) -> CGFloat {
        var width = CGFloat(0)
        
        for wordContainer in row {
            width += wordContainer.getWidth()
        }
        
        return width
    }
    
    func getMaxWidth() -> CGFloat {
        return self.bounds.width - CGFloat(16)
    }

}
