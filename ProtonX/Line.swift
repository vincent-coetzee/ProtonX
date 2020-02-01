//
//  Line.swift
//  argon
//
//  Created by Vincent Coetzee on 17/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public struct Line
    {
    public enum Element
        {
        public var string:String
            {
            switch(self)
                {
                case .index(let name,let value,let size):
                    let index = "\(value)"
                    let indexValue = String(repeating:" ",count:size - index.count) + index
                    return("\(name)[\(indexValue)]")
                case .natural(let value):
                    return(value)
                case .space(let size):
                    return(String(repeating: " ",count: size))
                case .left(let value,let size):
                    let count = value.count
                    if count < size
                        {
                        return(value + String(repeating: " ",count: size - count))
                        }
                    return(String(value.prefix(size)))
                case .right(let value,let size):
                    let count = value.count
                    if count < size
                        {
                        return(String(repeating: " ",count: size - count) + value)
                        }
                    return(String(value.prefix(size)))
                case .rightInteger(let number,let size):
                    let value = String(format:"%ld",number)
                    let count = value.count
                    if count < size
                        {
                        return(String(repeating: " ",count: size - count) + value)
                        }
                    return(String(value.prefix(size)))
                case .centre(let value,let size):
                    let count = value.count
                    if count < size
                        {
                        let left = (size - count) / 2
                        let right = left * 2 != size ? left + 1 : left
                        return(String(repeating: " ",count: left) + value + String(repeating: " ",count: right))
                        }
                    return(String(value.prefix(size)))
                }
            }
            
        case left(String,Int)
        case centre(String,Int)
        case right(String,Int)
        case rightInteger(Int,Int)
        case natural(String)
        case space(Int)
        case index(String,Int,Int)
        }

    public var string:String
        {
        var string = ""
        for element in self.elements
            {
            string += element.string
            }
        return(string)
        }
        
    private var elements:[Element] = []
    
    public init(_ elements:Element...)
        {
        self.elements = elements
        }
        
    public init(_ elements:[Element])
        {
        self.elements = elements
        }
    }
