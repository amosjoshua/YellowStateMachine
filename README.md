
## YellowStateMachine

A simple state machine in swift with callbacks on state changes

### Sample

    enum CakeStates : Int {
        case baking
        case done
        case burned
    }
    
    let cake = YellowStateMachine<CakeStates>(
            machineStates: [.baking, .done, .burned],
            startingState: .baking)
    
    cake.on(self, .done) {
        print("It's cake time")
    }
    
    cake.on(self, .burned) {
        print("Oh no, it's a charred lump")
    }
    
    cake.state = .done
    cake.state = .burned

## License

The code is released under the MIT license, please see LICENSE for
more information. Written by Amos Joshua, copyright © 2017 IBM Corp. 

