//
//  CollectionPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class CollectionPointer:ObjectPointer
    {
    public static let kCollectionCountIndex = SlotIndex.two
    public static let kCollectionElementTypeIndex = SlotIndex.three
    
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(4)
        }
        
    public var count:Int
        {
        get
            {
            Log.log("GET Collection Count Index = \(Self.kCollectionCountIndex)")
            return(Int(wordAtIndexAtAddress(Self.kCollectionCountIndex,self.address)))
            }
        set
            {
            Log.log("SET Collection Count = \(newValue)")
            Log.log("SET Collection Count Index = \(Self.kCollectionCountIndex)")
            setWordAtIndexAtAddress(Word(newValue),Self.kCollectionCountIndex,self.address)
            }
        }
        
    public var elementTypePointer:TypePointer?
        {
        get
            {
            return(TypePointer(addressAtIndexAtAddress(Self.kCollectionElementTypeIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kCollectionElementTypeIndex,self.address)
            }
        }
        
    public required init(_ word:Argon.Address)
        {
        super.init(word)
        }
    }
