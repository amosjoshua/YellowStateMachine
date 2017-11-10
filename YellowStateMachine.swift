/*
 * Copyright 2017 IBM Corp.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

typealias YellowStateCallback = () -> Void

class YellowStateMachine<StateType:Hashable> {
    let states:[StateType]
    
    var stateHistory:[StateType] = []
    var stateHistorySize = 3
    
    fileprivate var currentState:StateType
    fileprivate var statesToEntries:[StateType:[(key:NSObject, callback:YellowStateCallback)]] = [:]
    
    var state:StateType {
        set {
            stateChanged(currentState, newState: newValue)
            currentState = newValue
            stateHistory.insert(newValue, at: 0)
            if stateHistory.count > stateHistorySize {
                stateHistory.removeLast()
            }
        }
        get {
            return currentState
        }
    }
    
    init(machineStates:[StateType], startingState:StateType) {
        states = machineStates
        currentState = startingState
        stateHistory.append(startingState)
    }
    
    func on(_ key:NSObject, _ state:StateType, callback:@escaping YellowStateCallback) {
        statesToEntries[state] = statesToEntries[state] ?? []
        statesToEntries[state]?.append((key, callback))
    }
    
    func on(_ key: NSObject, states stateCallbacks:[StateType:YellowStateCallback]) {
        for state in stateCallbacks.keys {
            statesToEntries[state] = statesToEntries[state] ?? []
            statesToEntries[state]?.append((key, stateCallbacks[state]!))
        }
    }

    func trigger() {
        stateChanged(state, newState: state)
    }
    
    func removeCallback(forState state:StateType, key:NSObject) {
        guard let entries = statesToEntries[state] else {
            return
        }
        var newEntries:[(key:NSObject, callback:YellowStateCallback)] = []
        for entry in entries {
            if entry.key != key {
                newEntries.append(entry)
            }
        }
        statesToEntries[state] = newEntries
    }
    
    func removeCallbacks(forKey key:NSObject) {
        for (state, _) in statesToEntries {
            removeCallback(forState:state, key: key)
        }
    }
    
    fileprivate func stateChanged(_ oldState: StateType, newState: StateType) {
        let stateCallbacks = statesToEntries[newState] ?? []
        for (_, callback) in stateCallbacks {
            callback()
        }
    }
}
