//
//  DictionaryBucketPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 27/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class DictionaryBucketNodePointer:ObjectPointer
    {
    public class var kDictionaryBucketNodeKeyIndex:SlotIndex
        {
        return(SlotIndex.two)
        }
        
    public class var kDictionaryBucketNodeValueIndex:SlotIndex
        {
        return(SlotIndex.three)
        }
        
    public class var kDictionaryBucketNodeNextNodeIndex:SlotIndex
        {
        return(SlotIndex.four)
        }
        
    public class var kDictionaryBucketNodePreviousNodeIndex:SlotIndex
        {
        return(SlotIndex.five)
        }
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(6)
        }
        
    public var nextNodePointer:DictionaryBucketNodePointer?
        {
        get
            {
            return(DictionaryBucketNodePointer(untaggedPointerAtIndexAtPointer(Self.kDictionaryBucketNodeNextNodeIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kDictionaryBucketNodeNextNodeIndex,self.pointer)
            }
        }
        
    public var nextNodeValue:Word
        {
        get
            {
            return(untaggedAddressAtIndexAtPointer(Self.kDictionaryBucketNodeNextNodeIndex,self.pointer))
            }
        set
            {
            return(setWordAtIndexAtPointer(newValue,Self.kDictionaryBucketNodeNextNodeIndex,self.pointer))
            }
        }
        
    public var previousNodeValue:Word
        {
        get
            {
            return(untaggedAddressAtIndexAtPointer(Self.kDictionaryBucketNodePreviousNodeIndex,self.pointer))
            }
        set
            {
            return(setWordAtIndexAtPointer(newValue,Self.kDictionaryBucketNodePreviousNodeIndex,self.pointer))
            }
        }
        
    public var previousNodePointer:DictionaryBucketNodePointer?
        {
        get
            {
            return(DictionaryBucketNodePointer(untaggedPointerAtIndexAtPointer(Self.kDictionaryBucketNodePreviousNodeIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kDictionaryBucketNodePreviousNodeIndex,self.pointer)
            }
        }
        
    public var keyValue:Word
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kDictionaryBucketNodeKeyIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kDictionaryBucketNodeKeyIndex,self.pointer)
            }
        }
        
    public var valueValue:Word
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kDictionaryBucketNodeValueIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kDictionaryBucketNodeValueIndex,self.pointer)
            }
        }
        
    public init<K>(key:K,value:Value,previous:Instruction.Address = 0,next:Instruction.Address = 0,segment:MemorySegment = .managed) where K:Key
        {
        super.init(segment.allocate(slotCount: Self.totalSlotCount))
        key.store(atPointer: self.pointer! + DictionaryBucketNodePointer.kDictionaryBucketNodeKeyIndex)
        value.store(atPointer: self.pointer! + DictionaryBucketNodePointer.kDictionaryBucketNodeValueIndex)
        self.nextNodeValue = next
        self.previousNodeValue = previous
        Log.log("ALLOCATED DICTIONARY BUCKET NODE AT \(self.hexString)")
        }
        
    public func remove(from dictionaryPointer: DictionaryPointer,atIndex index:SlotIndex)
        {
        if let node = self.previousNodePointer,node == dictionaryPointer
            {
            setWordAtIndexAtPointer(self.nextNodeValue,index,dictionaryPointer.pointer)
            return
            }
        self.nextNodePointer?.previousNodeValue = self.previousNodeValue
        self.previousNodePointer?.nextNodeValue = self.nextNodeValue
        }
        
    public func addressOfBucket(forKey:ValueHolder) -> Instruction.Address
        {
        if forKey == ValueHolder(word: self.keyValue)
            {
            return(self.untaggedAddress)
            }
        let nextNode = self.nextNodeValue
        guard nextNode.isNotNull else
            {
            return(0)
            }
        return(DictionaryBucketNodePointer(nextNode).addressOfBucket(forKey: forKey))
        }
        
    public func value(forKey:ValueHolder) -> Word?
        {
        if forKey == ValueHolder(string: "000000002710")
            {
            print("self.halt")
            }
        let keyHolder = ValueHolder(word: self.keyValue)
        if keyHolder == forKey
            {
            return(self.valueValue)
            }
        else
            {
            let nextNodeAddress = self.nextNodeValue
            guard nextNodeAddress.isNotNull else
                {
                return(nil)
                }
            return(DictionaryBucketNodePointer(nextNodeAddress).value(forKey: forKey))
            }
        }
    
    public override init(_ address: Instruction.Address)
        {
        super.init(address)
        }
        
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        fatalError("init(_:) has not been implemented")
        }
    }
