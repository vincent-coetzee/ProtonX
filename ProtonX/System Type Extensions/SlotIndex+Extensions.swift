//
//  SlotIndex+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 20/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension SlotIndex:Equatable,ExpressibleByIntegerLiteral
    {
    public init(integerLiteral value: Int)
        {
        self.init()
        self.index = value
        }
    
    public typealias IntegerLiteralType = Int
    
    public static func ==(lhs:SlotIndex,rhs:SlotIndex) -> Bool
        {
        return(lhs.index == rhs.index)
        }
        
    public static var header:SlotIndex
        {
        return(0)
        }
        
    public static var type:SlotIndex
        {
        return(1)
        }
        
    public static var object:SlotIndex
        {
        return(2)
        }
        
    public static var zero:SlotIndex
        {
        return(SlotIndex(index:0))
        }
        
    public static var one:SlotIndex
        {
        return(SlotIndex(index:1))
        }
        
    public static var two:SlotIndex
        {
        return(SlotIndex(index:2))
        }
        
    public static var three:SlotIndex
        {
        return(SlotIndex(index:3))
        }
        
    public static var four:SlotIndex
        {
        return(SlotIndex(index:4))
        }
        
    public static var five:SlotIndex
        {
        return(SlotIndex(index:5))
        }
        
    public static var six:SlotIndex
        {
        return(SlotIndex(index:6))
        }
        
    public static var seven:SlotIndex
        {
        return(SlotIndex(index:7))
        }
        
    public static var eight:SlotIndex
        {
        return(SlotIndex(index:8))
        }
        
    public static var nine:SlotIndex
        {
        return(SlotIndex(index:9))
        }
        
    public static var ten:SlotIndex
        {
        return(SlotIndex(index:10))
        }
        
    public static var twenty:SlotIndex
        {
        return(SlotIndex(index:20))
        }
        
    public static func +=(lhs:inout SlotIndex,rhs:Int)
        {
        lhs.index += rhs
        }
        
    @discardableResult
    public static postfix func ++(lhs:inout SlotIndex) -> SlotIndex
        {
        let before = lhs
        lhs.index += 1
        return(before)
        }
        
    public static func +(lhs:SlotIndex,rhs:Int) -> SlotIndex
        {
        var newIndex = SlotIndex()
        newIndex.index = lhs.index + rhs
        return(newIndex)
        }
        
    public static func -(lhs:SlotIndex,rhs:Int) -> SlotIndex
        {
        var newIndex = SlotIndex()
        newIndex.index = lhs.index - rhs
        return(newIndex)
        }
        
    public static func +(lhs:SlotIndex,rhs:SlotIndex) -> SlotIndex
        {
        var newIndex = SlotIndex()
        newIndex.index = lhs.index + rhs.index
        return(newIndex)
        }
        
    public static func +(lhs:SlotIndex,rhs:Argon.SlotCount) -> SlotIndex
        {
        var newIndex = SlotIndex()
        newIndex.index = lhs.index + rhs.count
        return(newIndex)
        }
        
    public static func *(lhs:SlotIndex,rhs:Argon.ByteCount) -> SlotIndex
        {
        var newIndex = SlotIndex()
        newIndex.index = lhs.index * rhs.count
        return(newIndex)
        }
        
    public static func *(lhs:SlotIndex,rhs:Int) -> SlotIndex
        {
        var newIndex = SlotIndex()
        newIndex.index = lhs.index * rhs
        return(newIndex)
        }
        
    public init(index:Int)
        {
        self.init()
        self.index = index
        }

    }
