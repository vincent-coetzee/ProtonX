//
//  Proton.Immediate+Extensions.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/21.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Proton.Immediate
    {
    public static let kFrameMask:Word = Word(4294967295) << Word(32)
    public static let kFrameShift:Word = 32
    public static let kIndexMask:Word = Word(4294967295)
    public static let kIndexShift:Word = 0
    
    public var frame:Int
        {
        return(Int((Word(bitPattern: self) & Self.kFrameMask) >> Self.kFrameShift))
        }
        
    public var index:Int
        {
        return(Int((Word(bitPattern: self) & Self.kIndexMask) >> Self.kIndexShift))
        }
        
    public init(from: Word)
        {
        let sign = (from & 2147483648 == 2147483648) ? Int32(-1) : Int32(1)
        let mask:Word = ~2147483648
        let newValue = from & mask
        self.init(Int32(Int(newValue & Word(4294967295))) * sign)
        }
        
    public init(frame:Int,index:Int)
        {
        self = Proton.Immediate(bitPattern: ((Word(frame) << Self.kFrameShift) & Self.kFrameMask) | ((Word(index) << Self.kIndexShift) & Self.kIndexMask))
        }
    }
