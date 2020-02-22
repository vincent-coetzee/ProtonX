//
//  COERCUFInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/18.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class COERCEUINTInstruction:CoercionInstruction
    {
    public init(register1:Register,register2:Register)
        {
        super.init(operation:.COERCEUINT,register1:register1,register2:register2)
        }
        
    public init(immediate:Proton.Immediate,register1:Register)
        {
        super.init(operation:.COERCEUINT,immediate:immediate,register1:register1)
        }
        
    public init(referenceAddress:Proton.Address,register1:Register)
        {
        super.init(operation:. COERCEUINT,referenceAddress:referenceAddress,register1: register1)
        }
        
    public init(register1:Register,referenceAddress:Proton.Address)
        {
        super.init(operation:.COERCEUINT,register1:register1,referenceAddress:referenceAddress)
        }
    }
