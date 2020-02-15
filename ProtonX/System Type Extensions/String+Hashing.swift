//
//  String+Hashing.swift
//  argon
//
//  Created by Vincent Coetzee on 15/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension String:HashableValue,Key
    {
    public static func run(of:String,length:Int) -> String
        {
        var ones = ""
        for _ in 0..<length
            {
            ones += of
            }
        return(ones)
        }
        
    public static func ==(aString:String,aStringPointer:StringPointer) -> Bool
        {
        if aString.count != aStringPointer.count
            {
            return(false)
            }
        guard let charPointer = charPointerToIndexAtAddress(StringPointer.kStringBytesIndex,aStringPointer.address) else
            {
            return(false)
            }
        var index = 0
        let view = aString.utf8
        var stringIndex = view.startIndex
        for _ in 0..<aString.count
            {
            if (index + 1) % 8 == 0
                {
                index += 1
                }
            if Int8(charPointer[index]) != Int8(bitPattern: view[stringIndex])
                {
                return(false)
                }
            stringIndex = view.index(after: stringIndex)
            index += 1
            }
        return(true)
        }
        
    public static func <(aString:String,aStringPointer:StringPointer) -> Bool
        {
        return(aString < aStringPointer.string)
        }

    public func asWord() -> Word
        {
        return(unsafeBitCast(self,to: Word.self))
        }
    
    public enum Alignment
        {
        case centre
        case left
        case right
        }
        
    public static var objectSizeInBytes:Int
        {
        return(MemoryLayout<Word>.stride)
        }
        
    public func store(atAddress:Argon.Address)
        {
        let address = ImmutableStringPointer(self).address
        setAddressAtIndexAtAddress(address,.zero,atAddress)
        }
        
    public init(atAddress:Argon.Address)
        {
        self.init(ImmutableStringPointer(atAddress).string)
        }
    
    public var hashedValue:Int
        {
        return(self.multiplierHash)
        }
    
    public var multiplierHash:Int
        {
        let multiplier:Int = 97
        var hashValue:Int = 0
        let newString = String(self)
        for char in newString.utf8CString
            {
            hashValue = hashValue &* multiplier &+ Int(char)
            }
        return(hashValue.withTagAndSignBitsCleared())
        }
        
    public var hashedValueIndex: SlotIndex
        {
        return(SlotIndex(index: self.linkingHash))
        }
    
    public var taggedAddress: Argon.Address
        {
        let stringPointer = ImmutableStringPointer(self)
        return(stringPointer.taggedAddress)
        }
    
//    public var typePointer: TypePointer?
//        {
//        return(Memory.kTypeString)
//        }
//
//    public var valueStride: Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
    
    public var linkingHash:Int
        {
        var hashValue:Int = 0
        
        for char in self.utf8CString
            {
            hashValue = hashValue << 4 + Int(char)
            let check = hashValue & 0xF0000000
            if check != 0
                {
                hashValue ^= check >> 24
                }
            hashValue &= ~check
            }
        return(hashValue)
        }
        
    public func aligned(_ alignment:Alignment,in width:Int,with padder:String = " ") -> String
        {
        if self.count >= width
            {
            return(String(self.prefix(width)))
            }
        switch(alignment)
            {
            case .left:
                let delta = width - self.count
                let padding = String(repeating: padder,count: delta)
                return(self + padding)
            case .centre:
                let leftCount = (width - self.count) / 2
                let rightCount = leftCount + (width - leftCount * 2)
                let leftPad = String(repeating: padder,count: leftCount)
                let rightPad = String(repeating: padder,count: rightCount)
                return(leftPad + self + rightPad)
            case .right:
                let delta = width - self.count
                let padding = String(repeating: padder,count: delta)
                return(padding + self)
            }
        }
        
        
    public func equals(_ value:Value) -> Bool
        {
        if value is String
            {
            return(self == (value as! String))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is String
            {
            return(self < (value as! String))
            }
        return(false)
        }
    }
