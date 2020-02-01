//
//  StringPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
public class ImmutableStringPointer:StringPointer
    {
    public class func storageBytesRequired(for string:String) -> Argon.ByteCount
        {
        let sevens = (string.utf8.count + 1) / 7 + 1
        let eights = sevens.aligned(to: MemoryLayout<Word>.stride) * MemoryLayout<Word>.stride
        return(Argon.ByteCount(eights))
        }
        
    public class var kFillerWord:Word
        {
        return(85)
        }
  
    public static func ====(lhs:ImmutableStringPointer,rhs:ValuePointer) -> Bool
        {
        if !(rhs is ImmutableStringPointer)
            {
            return(false)
            }
        return(lhs.string == (rhs as! ImmutableStringPointer).string)
        }
        
    public override var valueStride: Int
        {
        return(MemoryLayout<Word>.stride)
        }
        
    public convenience init(_ contents:String,segment:MemorySegment = .managed)
        {
        self.init(segment.allocateStringConstant(contents,segment: segment))
        }
        
    public required init(_ address:UnsafeMutableRawPointer?)
        {
        super.init(address)
        }
        
    public override init(_ address:Instruction.Address)
        {
        super.init(address)
        }
    }
