//
//  StringPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 30/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class StringPointer:ObjectPointer
    {
    public static let kStringCountIndex = SlotIndex.two
    public static let kStringMaximumCountIndex = SlotIndex.three
    public static let kStringBytesIndex = SlotIndex.four
    
    public static func ==(aStringPointer:StringPointer,aString:String) -> Bool
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
        
    public static func <(aStringPointer:StringPointer,aString:String) -> Bool
        {
        return(aStringPointer.string < aString)
        }
        
    public static func <(aStringPointer1:StringPointer,aStringPointer2:StringPointer) -> Bool
        {
        return(aStringPointer1.string < aStringPointer2.string)
        }
        
    public static func ==(lhs:StringPointer,rhs:StringPointer) -> Bool
        {
        guard lhs.count == rhs.count else
            {
            return(false)
            }
        guard let lhsPointer = charPointerToIndexAtAddress(Self.kStringBytesIndex,lhs.address),let rhsPointer = charPointerToIndexAtAddress(Self.kStringBytesIndex,rhs.address) else
            {
            return(false)
            }
        var index = 0
        for _ in 0..<lhs.count
            {
            if (index + 1) % 8 == 0 && index != 0
                {
                index += 1
                }
            if lhsPointer[index] != rhsPointer[index]
                {
                return(false)
                }
            index += 1
            }
        return(true)
        }
        
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(5)
        }
        
    public override var valueStride: Int
        {
        return(MemoryLayout<Word>.stride)
        }
        
    public var string:String
        {
        get
            {
            guard let charPointer = charPointerToIndexAtAddress(Self.kStringBytesIndex,self.address) else
                {
                return("")
                }
            var string = ""
            var stringIndex = string.startIndex
            var index = 0
            for _ in 0..<self.count
                {
                if (index + 1) % 8 == 0
                    {
                    index += 1
                    }
                string.insert(Character(Unicode.Scalar(UInt8(charPointer[index]))), at: stringIndex)
                stringIndex = string.index(after: stringIndex)
                index += 1
                }
            return(string)
            }
        set
            {
            guard let charPointer = charPointerToIndexAtAddress(Self.kStringBytesIndex,self.address) else
                {
                return
                }
            Log.log("IN STRING ASSIGN SELF POINTER = \(self.address.hexString) STRING BYTES INDEX = \(Self.kStringBytesIndex) CHAR POINTER = \(Word(bitPattern: Int64(Int(bitPattern: charPointer))).hexString)")
            let stringCount = newValue.utf8.count
            let view = newValue.utf8
            var stringIndex = view.startIndex
            var index = 0
            let flag = Int8(Proton.kTagBitsMask) << Int8(4)
            for _ in 0..<stringCount
                {
                if (index + 1) % 8 == 0 && index != 0
                    {
                    index += 1
                    }
                charPointer[index] = Int8(bitPattern: view[stringIndex])
                Log.log("STORING [\(index)] '\(Character(Unicode.Scalar(view[stringIndex])))'")
                stringIndex = view.index(after: stringIndex)
                index += 1
                }
            charPointer[index] = 0
            for endIndex in Swift.stride(from: 7, to: index + 7, by: 8)
                {
                charPointer[endIndex] = flag
                Log.log("STORING [\(endIndex)] MARKER")
                }
            self.count = stringCount
            self.maximumCount = stringCount
//            mprotect(self.pointer, self.headerSlotCount * MemoryLayout<Word>.size, PROT_READ)
            }
        }
            
    public private(set) var count:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kStringCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kStringCountIndex,self.address)
            }
        }
        
    public private(set) var maximumCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kStringMaximumCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kStringMaximumCountIndex,self.address)
            }
        }
        
    private var _hashedValue:Int?
    
    public var hashValue:Int
        {
        guard let hash = self._hashedValue else
            {
            self._hashedValue = self.calculateHashedValue()
            return(self._hashedValue!)
            }
        return(hash)
        }
        
    public func calculateHashedValue() -> Int
        {
        let multiplier = 97
        var hashValue:Int = 0
        for char in self.string.utf8CString
            {
            hashValue = hashValue * multiplier + Int(char)
            }
        return(hashValue.withTagAndSignBitsCleared())
        }
        
    private func oldcalculateHashedValue() -> Int
        {
        var hashValue:Int = 0
        
        for char in self.string.utf8CString
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
        
    }
