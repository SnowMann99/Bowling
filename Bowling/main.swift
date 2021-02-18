//
//  main.swift
//  Bowling
//
//  Created by Egor Salnikov on 15.01.2021.
//

import Foundation

// MARK: - Constants

let maxPinCount = 10
let numberOfRounds = 10

// MARK: - Runtime Variables

var isExtendedLastRound = false

// MARK: - Object Declarations

struct Round {
    
    private(set) var rolls: [Int] = []
    
    var isSpare: Bool {
        return rolls.count == 2 && brokenPins == maxPinCount
    }
    
    var isStrike: Bool {
        return rolls.count == 1 && rolls.first == maxPinCount
    }
    
    var isLastRound: Bool {
        return history.count == numberOfRounds - 1
    }
    
    var brokenPins: Int {
        return rolls.reduce(0, +)
    }
    
    var remainingPins: Int {
        return maxPinCount - brokenPins
    }
    
    var isFinished: Bool {
        if isLastRound && (isSpare || isStrike) {
            isExtendedLastRound = true
        }
        
        if isExtendedLastRound {
            return rolls.count == 3
        } else {
            return rolls.count == 2 || isStrike
        }
    }
    
    mutating func considerRoll(_ downedPins: Int) -> Bool {
        let supportedCounts: ClosedRange<Int> = 0 ... maxPinCount
        
        if supportedCounts.contains(downedPins) && (downedPins <= remainingPins || isExtendedLastRound) {
            rolls += downedPins
            
            if isStrike {
                print("Страйк!")
            } else {
                if isSpare {
                    print("Спэр!")
                }
            }
            
            return true
        } else {
            let maxCount = min(supportedCounts.upperBound, isExtendedLastRound ? maxPinCount : remainingPins)
            print("Количество сбитых кегель должно быть от \(supportedCounts.lowerBound) до \(maxCount), повторите ввод")
        }
        
        return false
    }
    
}

// MARK: - Main Logic

print("Добро пожаловать! Я Ваш личный боулинг-менеджер. Введите число сбитых вами кегель.")

var history: [Round] = []
var totalResult = 0

var currentRound = Round()

func startGame() {
    while history.count < numberOfRounds {
        guard let input = readLine(), let downedPins = Int(input) else {
            print("Введите корректное число сбитых кегель")
            continue
        }
        
        if currentRound.considerRoll(downedPins) {
            if let previousRound = history.last {
                let isFirstRollNow = currentRound.rolls.count == 1
                let isPlainRoll = currentRound.rolls.count < 3
                
                if previousRound.isStrike && isPlainRoll {
                    if history.penultimate?.isStrike == true && isFirstRollNow {
                        totalResult += downedPins
                    }
                } else {
                    if previousRound.isSpare, isFirstRollNow {
                        totalResult += downedPins
                    }
                }
            }
            
            if currentRound.isFinished {
                totalResult += currentRound.brokenPins
                startNextRound()
            } else {
                print("Сделайте ещё один бросок")
            }
        }
    }
}

func startNextRound() {
    history += currentRound
    currentRound = Round()
    
    outputResult()
}

typealias WordForms = (one: String, three: String, many: String)

func outputResult() {
    let wordForms = WordForms(one: "очко", three: "очка", many: "очков")
    
    guard let count = String(count: totalResult, wordForms: wordForms) else {
        return
    }
    
    if history.count == numberOfRounds {
        print("Игра закончена! Поздравляем, вы набрали \(count).")
    } else {
        print("Следующий раунд! Ваш бросок...")
    }
}

startGame()

// MARK: -

extension String {
    
    init?(count: Int, wordForms: WordForms) {
        var suitableForm = wordForms.many
        
        if count.getDigit(ofRank: 10) != 1 {
            switch count.getDigit(ofRank: 1) {
                case 1:
                    suitableForm = wordForms.one
                case 2, 3, 4:
                    suitableForm = wordForms.three
                
                default:
                    break
            }
        }
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        
        formatter.groupingSize = 3
        formatter.groupingSeparator = "\u{202F}"
        
        guard let digits = formatter.string(for: count) else {
            return nil
        }
        
        self = "\(digits)\u{00A0}\(suitableForm)"
    }
    
}

extension Int {
    
    func getDigit(ofRank rank: Int) -> Int? {
        guard rank > 0 && rank <= self && (rank.isMultiple(of: 10) || rank == 1) else {
            return nil
        }
        
        let multiplier = rank * 10
        return Int(self / rank) - Int(self / multiplier) * 10
    }
    
}

extension Array {
    
    var penultimate: Element? {
        guard count >= 2 else {
            return nil
        }
        
        return self[count - 2]
    }
    
    static func += (left: inout Self, right: Element) {
        left.append(right)
    }
    
}
