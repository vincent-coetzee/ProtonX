//
//  RecursiveLock.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/15.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public struct RecursiveLock
    {
    var monitor:pthread_mutex_t
    var owner:pthread_t
    var busyCount = 0
    var notBusyCondition:pthread_cond_t
    
    public init()
        {
        self.monitor = pthread_mutex_t()
        pthread_mutex_init(&self.monitor,nil)
        self.notBusyCondition = pthread_cond_t()
        pthread_cond_init(&self.notBusyCondition,nil)
        self.owner = pthread_self()
        }
        
    public mutating func lock()
        {
        pthread_mutex_lock(&self.monitor)
        if self.busyCount != 0
            {
            if self.owner != pthread_self()
                {
                repeat
                    {
                    pthread_cond_wait(&self.notBusyCondition,&self.monitor)
                    }
                while self.busyCount != 0
                }
            }
        self.owner = pthread_self()
        self.busyCount += 1
        pthread_mutex_unlock(&self.monitor)
        }
        
    public mutating func unlock()
        {
        pthread_mutex_lock(&self.monitor)
        self.busyCount -= 1
        let ownershipCount = self.busyCount
        pthread_mutex_unlock(&self.monitor)
        if ownershipCount == 0
            {
            pthread_cond_signal(&self.notBusyCondition)
            }
        }
    }
