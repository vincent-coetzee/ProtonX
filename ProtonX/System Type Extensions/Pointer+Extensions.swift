//
//  Pointer+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 15/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Argon.Pointer
    {
    public static let null:Argon.Pointer? = nil

    public static func +=(lhs:inout Argon.Pointer,rhs:Word)
        {
        let address = Word(bitPattern: lhs) + (rhs * Word(MemoryLayout<Word>.stride))
        assert(address != 0)
        lhs = Argon.Pointer(bitPattern: address)!
        }
        
    public static func +=(lhs:inout Argon.Pointer,rhs:Argon.ByteCount)
        {
        let address = Word(bitPattern: lhs) + Word(rhs)
        assert(address != 0)
        lhs = Argon.Pointer(bitPattern: address)!
        }
        
    public static func +(lhs:Self,rhs:SlotOffset) -> Self
        {
        let address = Word(bitPattern: lhs) + Word(rhs.offset)
        return(Argon.Pointer(bitPattern: address)!)
        }
        
    public static func +(lhs:Argon.Pointer,rhs:SlotIndex) -> Argon.Pointer
        {
        return(lhs + (rhs.index * MemoryLayout<Word>.stride))
        }
        
    public var hexString:String
        {
        return(String(format:"%016lX",UInt64(bitPattern: self)))
        }
        
    public var bitString:String
        {
        return(Word(bitPattern: self).bitString)
        }
        
    public init(_ address:Instruction.Address)
        {
        self.init(bitPattern: UInt(address))!
        }
        
    public init?(bitPattern: Word)
        {
        self.init(bitPattern: UInt(bitPattern))
        }
        
    public init?(bitPattern: Int64)
        {
        self.init(bitPattern: Int(bitPattern))
        }
        
    @inline(__always)
    public func word(at index:SlotIndex) -> Word
        {
        return(wordAtIndexAtPointer(index,self))
        }
        
    @inline(__always)
    public func setWord(_ word:Word,at index:SlotIndex)
        {
        setWordAtIndexAtPointer(word,index,self)
        }
        
    public func dump(wordCount:Int)
        {
        var address = Instruction.Address(bitPattern: self)
        for index in 0..<wordCount
            {
            Log.log("0x\(address.hexString):  \(wordAtIndexAtAddress(SlotIndex(index: index),address))")
            address++
            }
        }
    }

