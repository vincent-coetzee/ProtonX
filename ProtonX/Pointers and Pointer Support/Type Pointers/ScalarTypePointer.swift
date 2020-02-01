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
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(12)
        }
        
    public var scalarType:Argon.ScalarType
        {
        get
            {
            return(Argon.ScalarType(rawValue: wordAtIndexAtPointer(Self.kScalarTypeIndex,self.pointer))!)
            }
        set
            {
            setWordAtIndexAtPointer(newValue.rawValue,Self.kScalarTypeIndex,self.pointer)
            }
        }
        
    public func makeInstance() -> Argon.Pointer?
        {
        switch(self.scalarType)
            {
            case .bits:
                return(Argon.Pointer(taggedBits(0)))
            case .integer:
                return(Argon.Pointer(taggedInteger(0)))
            case .uinteger:
                return(Argon.Pointer(taggedUInteger(0)))
            case .boolean:
                return(Argon.Pointer(taggedBoolean(false)))
            case .byte:
                return(Argon.Pointer(taggedByte(0)))
            case .none:
                return(Argon.Pointer.null)
            case .float32:
                return(Argon.Pointer(taggedFloat32(0.0)))
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
                return(Argon.Integer(bitPattern: word))
            case .uinteger:
                return(Argon.UInteger(word))
            case .boolean:
                return(Argon.Boolean(word))
            case .byte:
                return(Argon.Byte(word))
            case .none:
                return(nil)
            case .float32:
                return(Argon.Float32(bitPattern: word))
            case .float64:
                fatalError("You need to think this through")
            }
        }
    }


    
