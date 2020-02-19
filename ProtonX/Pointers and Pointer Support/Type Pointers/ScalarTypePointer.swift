//
//  ScalarTypePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 02/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ScalarTypePointer:TypePointer
    {
    public static let kScalarTypeIndex = SlotIndex.ten + .one
        
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(12)
        }
        
    public var scalarType:Proton.ScalarType
        {
        get
            {
            return(Proton.ScalarType(rawValue: wordAtIndexAtAddress(Self.kScalarTypeIndex,self.address))!)
            }
        set
            {
            setWordAtIndexAtAddress(newValue.rawValue,Self.kScalarTypeIndex,self.address)
            }
        }
        
    public func makeInstance() -> Proton.Address
        {
        switch(self.scalarType)
            {
            case .bits:
                return(taggedBits(0))
            case .integer:
                return(taggedInteger(0))
            case .uinteger:
                return(taggedUInteger(0))
            case .boolean:
                return(taggedBoolean(false))
            case .byte:
                return(taggedByte(0))
            case .none:
                return(0)
            case .float32:
                return(taggedFloat32(0.0))
            case .float64:
                fatalError("You need to think this through")
            }
        }
        
    public override func typedValue(of word:Word) -> Value?
        {
        switch(self.scalarType)
            {
            case .bits:
                return(word)
            case .integer:
                return(Proton.Integer(taggedBits: word))
            case .uinteger:
                return(Proton.UInteger(word))
            case .boolean:
                return(Proton.Boolean(word))
            case .byte:
                return(Proton.Byte(word))
            case .none:
                return(nil)
            case .float32:
                return(Proton.Float32(taggedBits:word))
            case .float64:
                fatalError("You need to think this through")
            }
        }
    }


    
