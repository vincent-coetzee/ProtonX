//
//  DictionaryPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class DictionaryPointer:CollectionPointer
    {
    public static let kDictionaryChunkFactorIndex = SlotIndex.four
    public static let kDictionaryBucketsIndex = SlotIndex.five
     
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(6)
        }
        
    public var chunkFactor:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kDictionaryChunkFactorIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kDictionaryChunkFactorIndex,self.address)
            }
        }
        
    public init(chunkFactor:Int,segment:MemorySegment = .managed)
        {
        super.init(segment.allocate(slotCount: Self.totalSlotCount + chunkFactor))
        self.count = 0
        self.chunkFactor = chunkFactor
        Log.log("ALLOCATED DICTIONARY AT \(self.hexString)")
        }
    
    public func setBucketPointerValue(_ value:Word,atIndex:SlotIndex)
        {
        setWordAtIndexAtAddress(value,atIndex,self.address)
        }
        
    public func setValue<K>(_ value:Value?,forKey key:K) where K:Key
        {
        let index = Self.kDictionaryBucketsIndex + Int(key.hashedValue % self.chunkFactor)
        let bucketAddress = wordAtIndexAtAddress(index,self.address)
        let forKey = key is String ? ValueHolder(string: (key as! String)) : ValueHolder(key: key)
        if value == nil && bucketAddress.isNull
            {
            return
            }
        else if value != nil && bucketAddress.isNull
            {
            setWordAtIndexAtAddress(DictionaryBucketNodePointer(key: key, value: value!,previous: self.taggedAddress,segment: self.segment).taggedAddress,index,self.address)
            self.count += 1
            return
            }
        else if value == nil && bucketAddress.isNotNull
            {
            let targetBucketAddress = DictionaryBucketNodePointer(bucketAddress).addressOfBucket(forKey: forKey)
            if targetBucketAddress.isNull
                {
                return
                }
            DictionaryBucketNodePointer(targetBucketAddress).remove(from: self,atIndex:index)
            self.count -= 1
            return
            }
        else if value != nil && bucketAddress.isNotNull
            {
            let targetBucketAddress = DictionaryBucketNodePointer(bucketAddress).addressOfBucket(forKey: forKey)
            if targetBucketAddress.isNull
                {
                setWordAtIndexAtAddress(DictionaryBucketNodePointer(key: key, value: value!,previous: self.taggedAddress,next: bucketAddress,segment: self.segment).taggedAddress,index,self.address)
                self.count += 1
                return
                }
            value?.store(atAddress: targetBucketAddress + DictionaryBucketNodePointer.kDictionaryBucketNodeValueIndex)
            }
        }
        
    public func value<T>(forKey key:T) -> Word? where T:Key
        {
        let index = Self.kDictionaryBucketsIndex + Int(key.hashedValue % self.chunkFactor)
        let bucketAddress = addressAtIndexAtAddress(index,self.address)
        guard bucketAddress.isNotNull else
            {
            return(nil)
            }
        return(DictionaryBucketNodePointer(bucketAddress).value(forKey: ValueHolder(key: key)))
        }
        
    public required init(_ address:Argon.Address)
        {
        super.init(address)
        self.isMarked = true
        }
        
    public func print()
        {
        Log.log("DICTIONARY @ 0x\(self.address.hexString)")
        Log.log("COUNT : \(self.count)")
        for index in 0..<self.chunkFactor
            {
            let entryIndex = Self.kDictionaryBucketsIndex + index
            let bucketAddress = addressAtIndexAtAddress(entryIndex,self.address)
            if bucketAddress != 0
                {
                Log.log("\tINDEX : \(entryIndex.index)")
                var address = bucketAddress
                while address != 0
                    {
                    let bucketNode = DictionaryBucketNodePointer(address)
                    Log.log("\t\tBUCKET NODE @ \(address.hexString)")
                    Log.log("\t\t\tKEY   : \(ValueHolder(word: bucketNode.keyValue).debugString)")
                    Log.log("\t\t\tVALUE : \(ValueHolder(word: bucketNode.valueValue).debugString)")
                    address = bucketNode.nextNodeValue
                    }
                }
            }
        }
    }
