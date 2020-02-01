//
//  SlotOffset+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 20/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension SlotOffset
    {
    @discardableResult
    public static postfix func ++(lhs:inout SlotOffset) -> SlotOffset
        {
        let oldValue = lhs
        lhs.offset += MemoryLayout<Word>.stride
        return(oldValue)
        }
        
    public static func +(lhs:SlotOffset,rhs:Int) -> SlotOffset
        {
        return(SlotOffset(Word(lhs.offset) + Word(rhs)))
        }
        
    public init(_ word:Word)
        {
        self.init()
        self.offset = Int(word)
        }
        
    public init(stride:Int,index:SlotIndex)
        {
        self.init()
        self.offset = stride * index.index
        }
    }
