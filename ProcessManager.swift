import Foundation

@MainActor
class ProcessManager {
    static let shared = ProcessManager()
    
    private init() {}
    
    func getProcessInfo(for port: Int) -> (pid: Int, name: String)? {
        let task = Process()
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = ["-i", "TCP:\(port)", "-sTCP:LISTEN", "-F", "pc"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe() // Suppress errors
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return parseLsofOutput(output)
            }
        } catch {
            print("Failed to run lsof: \(error)")
        }
        
        return nil
    }
    
    func killProcess(pid: Int) throws {
        let task = Process()
        task.launchPath = "/bin/kill"
        task.arguments = ["-9", "\(pid)"]
        try task.run()
    }
    
    private func parseLsofOutput(_ output: String) -> (pid: Int, name: String)? {
        // Output format example:
        // p1234
        // cpython
        
        var pid: Int?
        var name: String?
        
        let lines = output.split(separator: "\n")
        
        for line in lines {
            if line.hasPrefix("p") {
                let pidString = line.dropFirst()
                pid = Int(pidString)
            } else if line.hasPrefix("c") {
                name = String(line.dropFirst())
            }
        }
        
        if let p = pid, let n = name {
            return (p, n)
        }
        
        return nil
    }
}
