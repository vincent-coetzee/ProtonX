//
//  COERCIFInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/18.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class COERCEINTInstruction:CoercionInstruction
    {
    public init(register1:Register,register2:Register)
        {
        super.init(operation:.COERCEINT,register1:register1,register2:register2)
        }
        
    public init(immediate:Proton.Immediate,register1:Register)
        {
        super.init(operation:.COERCEINT,immediate:immediate,register1:register1)
        }
        
    public init(referenceAddress:Proton.Address,register1:Register)
        {
        super.init(operation:. COERCEINT,referenceAddress:referenceAddress,register1: register1)
        }
        
    public init(register1:Register,referenceAddress:Proton.Address)
        {
        super.init(operation:.COERCEINT,register1:register1,referenceAddress:referenceAddress)
        }
    }
