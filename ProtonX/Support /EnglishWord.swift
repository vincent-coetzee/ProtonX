//
//  Word.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public typealias EnglishWordSet = Set<String>
public typealias IntSet = Set<Int>

extension EnglishWordSet
    {
    public static func indexSet(withCount count:Int) -> IntSet
        {
        let totalWords = EnglishWord.allWords.count
        let delta = totalWords / count
        var indexSet = IntSet()
        for index in stride(from:0,to: totalWords,by:delta)
            {
            indexSet.insert(index)
            }
        return(indexSet)
        }
        
    public func randomWord() -> String
        {
        let maximum = self.count
        let random = Int.random(in: 0..<maximum)
        var index = self.startIndex
        for _ in 0..<random
            {
            index = self.index(after: index)
            }
        return(self[index])
        }
    
    public func word(at count:Int) -> String?
        {
        var index = self.startIndex
        for _ in 0..<count
            {
            index = self.index(after: index)
            }
        if index <= self.endIndex
            {
            return(self[index])
            }
        return(nil)
        }
    }
    
public struct EnglishWord
    {
    private static var wordList:[String] = []
    
    public static func random() -> String
        {
        let count = Self.allWords.count
        let index = Int.random(in: 0..<count)
        return(Self.allWords[index])
        }
        
    public static let allWords:[String] =
        {
        if Self.wordList.isEmpty
            {
            Self.loadEnglishWords()
            }
        return(Self.wordList)
        }()
        
    public static func wordsAtIndices(inSet:IntSet) -> EnglishWordSet
        {
        let allWords = Self.allWords
        var words = Set<String>()
        for index in inSet
            {
            words.insert(allWords[index])
            }
        return(words)
        }
        
    private static func loadEnglishWords()
        {
        guard let path = Bundle.main.path(forResource: "Words", ofType: "text") else
            {
            return
            }
        let line = try? String(contentsOfFile: path)
        guard let lines = line?.components(separatedBy: "\r\n") else
            {
            return
            }
        Self.wordList = lines
        }
        
    public static func randomWordSet(countIn range: Range<Int>) -> EnglishWordSet
        {
        let indices = Array<String>.randomIndices(countIn: range,indexIn: 0..<Self.allWords.count)
        let words = Self.allWords[indices]
        return(EnglishWordSet(words))
        }
    }
