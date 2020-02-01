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
            return(Int(wordAtIndexAtPointer(Self.kCollectionCountIndex,self.pointer)))
            }
        set
            {
            Log.log("SET Collection Count = \(newValue)")
            Log.log("SET Collection Count Index = \(Self.kCollectionCountIndex)")
            setWordAtIndexAtPointer(Word(newValue),Self.kCollectionCountIndex,self.pointer)
            }
        }
        
    public var elementTypePointer:TypePointer?
        {
        get
            {
            return(TypePointer(untaggedPointerAtIndexAtPointer(Self.kCollectionElementTypeIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kCollectionElementTypeIndex,self.pointer)
            }
        }
        
    public required init(_ address:UnsafeMutableRawPointer?)
        {
        super.init(address)
        }
        
    public override init(_ word:Instruction.Address)
        {
        super.init(word)
        }
    }
