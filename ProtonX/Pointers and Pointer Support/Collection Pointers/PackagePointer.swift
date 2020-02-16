//
//  PackagePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 18/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class PackagePointer:TypePointer
    {
    public static let kPackageContentDictionaryIndex = SlotIndex.ten + .one
    public static let kPackageParentPackageIndex = SlotIndex.ten + .two
    
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(13)
        }
        
    public var contentDictionaryPointer:DictionaryPointer
        {
        get
            {
            return(DictionaryPointer(addressAtIndexAtAddress(Self.kPackageContentDictionaryIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(newValue.taggedAddress,Self.kPackageContentDictionaryIndex,self.address)
            }
        }
        
    public override var fullName:String
        {
        let package = self.packagePointer
        return(package == nil ? self.name : package!.fullName + "::" + self.name)
        }
        
    public func append<O>(_ object:O) where O:NamedPointer,O:Value
        {
        self.contentDictionaryPointer.setValue(object,forKey: object.name)
        }
        
    public func resolve(name:String) -> Word?
        {
        return(self.contentDictionaryPointer.value(forKey: name))
        }
    }

public class PackageImportElementPointer:TypePointer
    {
    }
