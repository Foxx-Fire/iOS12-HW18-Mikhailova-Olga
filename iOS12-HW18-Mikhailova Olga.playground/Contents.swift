import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
           
        }
        print("Create CHIP")
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        print("sodering CHIP")
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}


class ThreadSafeStorage {

    private var storage: [Chip] = []

    private let queue = DispatchQueue(label: "storage", attributes: .concurrent)

    func push(_ chip: Chip) {
        queue.async(flags: .barrier) {
            self.storage.append(chip)
            print("Save CHIP")
            print("Storage has a \(self.storage.count) elements")
        }
    }

    func pop() -> Chip? {
        var poppedChip: Chip?
        queue.sync {
            if !storage.isEmpty {
                poppedChip = storage.removeLast()
                print("Get from storage CHIP")
            }
        }
        return poppedChip
    }
}

class GeneratingThread: Thread {
    override func main() {
        for _ in 1...10 {
            let newChip = Chip.make()
            storage.push(newChip)
            GeneratingThread.sleep(forTimeInterval: 2)
        }
    }
}

class WorkingThread: Thread {
    override func main() {
        while true {
            if let chip = storage.pop() {
                chip.sodering()
            } else {
                usleep(100)
            }
        }
    }
}

let storage = ThreadSafeStorage()

let generatingThread = GeneratingThread()
let workingThread = WorkingThread()

generatingThread.start()
workingThread.start()
sleep(20)
workingThread.cancel()

