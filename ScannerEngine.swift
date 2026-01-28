import Foundation
import Network

@MainActor
class ScannerEngine: ObservableObject {
    @Published var scannedPorts: [ScannedPort] = []
    @Published var isScanning: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentTarget: String = "127.0.0.1"
    
    private var scanTask: Task<Void, Never>?
    
    func startScan(target: String, range: ClosedRange<Int>, concurrency: Int = 100) {
        stopScan()
        scannedPorts = []
        isScanning = true
        progress = 0.0
        currentTarget = target
        
        scanTask = Task {
            let total = Double(range.upperBound - range.lowerBound + 1)
            var completed = 0
            
            await withTaskGroup(of: ScannedPort?.self) { group in
                // We process in chunks to control concurrency
                let ports = Array(range)
                for i in stride(from: 0, to: ports.count, by: concurrency) {
                    let end = min(i + concurrency, ports.count)
                    let chunk = ports[i..<end]
                    
                    for port in chunk {
                        group.addTask {
                            return await self.checkPort(host: target, port: port)
                        }
                    }
                    
                    for await result in group {
                        if let res = result {
                            self.scannedPorts.append(res)
                            self.scannedPorts.sort { $0.port < $1.port }
                        }
                        completed += 1
                        self.progress = Double(completed) / total
                    }
                    
                    if Task.isCancelled { break }
                }
            }
            
            isScanning = false
        }
    }
    
    func stopScan() {
        scanTask?.cancel()
        isScanning = false
    }
    
    private func checkPort(host: String, port: Int) async -> ScannedPort? {
        let timeout: TimeInterval = 0.5
        
        return await withCheckedContinuation { continuation in
            let connection = NWConnection(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(integerLiteral: UInt16(port)),
                using: .tcp
            )
            
            let isFinished = LockedBool()
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if !isFinished.getAndSetTrue() {
                        connection.cancel()
                        
                        var result = ScannedPort(port: port, status: .open, service: CommonServices.getService(for: port))
                        
                        // Try to resolve process info on the main actor
                        Task { @MainActor in
                            if let info = ProcessManager.shared.getProcessInfo(for: port) {
                                result.pid = info.pid
                                result.processName = info.name
                            }
                            continuation.resume(returning: result)
                        }
                    }
                case .failed(_):
                    if !isFinished.getAndSetTrue() {
                        connection.cancel()
                        continuation.resume(returning: nil)
                    }
                case .waiting(_):
                    break
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            // Safety timeout
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if !isFinished.getAndSetTrue() {
                    connection.cancel()
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

class LockedBool {
    private var value = false
    private let lock = NSLock()
    
    func getAndSetTrue() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let oldValue = value
        value = true
        return oldValue
    }
}
