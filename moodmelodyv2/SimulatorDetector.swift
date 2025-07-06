import Foundation

struct SimulatorDetector {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    static var isDevice: Bool {
        return !isSimulator
    }
}