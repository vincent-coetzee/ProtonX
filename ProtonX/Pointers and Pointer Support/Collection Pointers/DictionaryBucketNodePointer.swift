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
            return(DictionaryBucketNodePointer(addressAtIndexAtAddress(Self.kDictionaryBucketNodeNextNodeIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kDictionaryBucketNodeNextNodeIndex,self.address)
            }
        }
        
    public var nextNodeValue:Word
        {
        get
            {
            return(addressAtIndexAtAddress(Self.kDictionaryBucketNodeNextNodeIndex,self.address))
            }
        set
            {
            return(setWordAtIndexAtAddress(newValue,Self.kDictionaryBucketNodeNextNodeIndex,self.address))
            }
        }
        
    public var previousNodeValue:Word
        {
        get
            {
            return(addressAtIndexAtAddress(Self.kDictionaryBucketNodePreviousNodeIndex,self.address))
            }
        set
            {
            return(setWordAtIndexAtAddress(newValue,Self.kDictionaryBucketNodePreviousNodeIndex,self.address))
            }
        }
        
    public var previousNodePointer:DictionaryBucketNodePointer?
        {
        get
            {
            return(DictionaryBucketNodePointer(addressAtIndexAtAddress(Self.kDictionaryBucketNodePreviousNodeIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kDictionaryBucketNodePreviousNodeIndex,self.address)
            }
        }
        
    public var keyValue:Word
        {
        get
            {
            return(wordAtIndexAtAddress(Self.kDictionaryBucketNodeKeyIndex,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,Self.kDictionaryBucketNodeKeyIndex,self.address)
            }
        }
        
    public var valueValue:Word
        {
        get
            {
            return(wordAtIndexAtAddress(Self.kDictionaryBucketNodeValueIndex,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,Self.kDictionaryBucketNodeValueIndex,self.address)
            }
        }
        
    public init<K>(key:K,value:Value,previous:Argon.Address = 0,next:Argon.Address = 0,segment:MemorySegment = .managed) where K:Key
        {
        super.init(segment.allocate(slotCount: Self.totalSlotCount))
        key.store(atAddress: self.address + DictionaryBucketNodePointer.kDictionaryBucketNodeKeyIndex)
        value.store(atAddress: self.address + DictionaryBucketNodePointer.kDictionaryBucketNodeValueIndex)
        self.nextNodeValue = next
        self.previousNodeValue = previous
        Log.log("ALLOCATED DICTIONARY BUCKET NODE AT \(self.hexString)")
        }
        
    public func remove(from dictionaryPointer: DictionaryPointer,atIndex index:SlotIndex)
        {
        if let node = self.previousNodePointer,node == dictionaryPointer
            {
            setWordAtIndexAtAddress(self.nextNodeValue,index,dictionaryPointer.address)
            return
            }
        self.nextNodePointer?.previousNodeValue = self.previousNodeValue
        self.previousNodePointer?.nextNodeValue = self.nextNodeValue
        }
        
    public func addressOfBucket(forKey:ValueHolder) -> Argon.Address
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
    
    public required init(_ address: Argon.Address)
        {
        super.init(address)
        }
        
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        fatalError("init(_:) has not been implemented")
        }
    }
