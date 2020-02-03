//
//  VisibilityModifier.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public enum VisibilityModifier:Word
    {
    case `public`
    case `private`
    case progeny
    }
