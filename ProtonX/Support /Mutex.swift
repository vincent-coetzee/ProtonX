//
//  Mutex.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 09/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public class Mutex
    {
    private var mutex:pthread_mutex_t
    
    public init()
        {
        self.mutex = pthread_mutex_t()
        pthread_mutex_init(&self.mutex,nil)
        }
        
    deinit
        {
        pthread_mutex_destroy(&self.mutex)
        }
        
    public func lock()
        {
        pthread_mutex_lock(&self.mutex)
        }
        
    public func unlock()
        {
        pthread_mutex_unlock(&self.mutex)
        }
    }
