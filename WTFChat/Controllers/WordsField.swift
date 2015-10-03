//
//  WordsField.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 10/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class WordsField {
    var rows = [[WordLabelContainer]]()
    
    func getAllWordContainers() -> [WordLabelContainer] {
        var result = [WordLabelContainer]()
        
        for row in rows {
            for wordContainer in row {
                result.append(wordContainer)
            }
        }
        
        return result
    }
    
    func clearFromView() {
        for row in rows {
            for wordContainer in row {
                wordContainer.label.removeFromSuperview()
            }
        }
        
        rows = [[WordLabelContainer]]()
    }
    
    func isEmpty() -> Bool {
        return rows.isEmpty
    }
    
    func getLastRow() -> [WordLabelContainer] {
        return rows.last!
    }
    
    func getLastContainer() -> WordLabelContainer {
        return rows.last!.last!
    }
    
    func append(row: [WordLabelContainer]) {
        rows.append(row)
    }
    
    func append(wordContainer: WordLabelContainer) {
        rows[rows.count - 1].append(wordContainer)
    }
    
    func showContainers() {
        for row in rows {
            for wordContainer in row {
                wordContainer.show()
            }
        }
    }
    
    func getContainerByIndex(index: Int) -> WordLabelContainer? {
        var i = 0
        
        for row in rows {
            for wordContainer in row {
                if (i == index) {
                    return wordContainer
                } else {
                    i++
                }
            }
        }
        
        return nil
    }
    
    func getRowsCount() -> Int {
        return rows.count
    }
    
    func getContainerCount() -> Int {
        var i = 0
        
        for row in rows {
            i += row.count
        }
        
        return i
    }
    
    func getRow(i: Int) -> [WordLabelContainer] {
        return rows[i]
    }
}