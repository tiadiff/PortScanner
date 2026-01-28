import Foundation

enum PortStatus: String, Codable {
    case open = "Open"
    case closed = "Closed"
    case filtered = "Filtered"
    case scanning = "Scanning..."
    
    var color: String {
        switch self {
        case .open: return "green"
        case .closed: return "red"
        case .filtered: return "orange"
        case .scanning: return "blue"
        }
    }
}

struct ScannedPort: Identifiable, Equatable {
    let id = UUID()
    let port: Int
    var status: PortStatus
    var service: String
    var pid: Int?
    var processName: String?
    
    static func == (lhs: ScannedPort, rhs: ScannedPort) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status && lhs.pid == rhs.pid
    }
}

struct CommonServices {
    static let mapping: [Int: String] = [
        21: "FTP",
        22: "SSH",
        23: "Telnet",
        25: "SMTP",
        53: "DNS",
        80: "HTTP",
        110: "POP3",
        143: "IMAP",
        443: "HTTPS",
        445: "SMB",
        548: "AFP",
        631: "IPP",
        993: "IMAPS",
        995: "POP3S",
        3306: "MySQL",
        5432: "PostgreSQL",
        5900: "VNC",
        6379: "Redis",
        8080: "HTTP-Proxy",
        9000: "PHP-FPM"
    ]
    
    static func getService(for port: Int) -> String {
        return mapping[port] ?? "Unknown"
    }
}
