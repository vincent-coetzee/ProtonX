//
//  DataSegment.swift
//  argon
//
//  Created by Vincent Coetzee on 26/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation

public class DataSegment:MemorySegment
    {
    public override var identifier:Identifier
        {
        return(.data)
        }
    }
