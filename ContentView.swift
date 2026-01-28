import SwiftUI

struct ContentView: View {
    @StateObject private var engine = ScannerEngine()
    @State private var targetIP: String = "127.0.0.1"
    @State private var startPort: String = "1"
    @State private var endPort: String = "1024"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Configuration Bar
            configBar
            
            // Progress Bar (Visible only when scanning)
            if engine.isScanning {
                ProgressView(value: engine.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 2)
            } else {
                Divider()
            }
            
            // Results Table
            resultsList
            
            // Footer
            footerView
        }
        .frame(minWidth: 600, minHeight: 450)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    var headerView: some View {
        HStack {
            Image(systemName: "network")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Port Scanner")
                    .font(.title2.weight(.bold))
                Text("Multi-threaded Network Security Tool")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if engine.isScanning {
                Button(action: { engine.stopScan() }) {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                HStack {
                    if !engine.scannedPorts.isEmpty {
                        Button(action: { engine.scannedPorts = [] }) {
                            Label("Clear", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(action: startScanning) {
                        Label("Start Scan", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
        }
        .padding()
        .background(Material.thin)
    }
    
    var configBar: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Target Address")
                    .font(.caption2.weight(.semibold))
                TextField("127.0.0.1", text: $targetIP)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Port Range")
                    .font(.caption2.weight(.semibold))
                HStack {
                    TextField("1", text: $startPort)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                    Text("-")
                    TextField("1024", text: $endPort)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Ports Found")
                    .font(.caption2.weight(.semibold))
                Text("\(engine.scannedPorts.count)")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    var resultsList: some View {
        List {
            if engine.scannedPorts.isEmpty && !engine.isScanning {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("No ports scanned yet.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                Section(header: resultsHeader) {
                    ForEach(engine.scannedPorts) { item in
                        HStack {
                            Text("\(item.port)")
                                .font(.body.weight(.medium))
                                .frame(width: 80, alignment: .leading)
                            
                            HStack {
                                Circle()
                                    .fill(statusColor(item.status))
                                    .frame(width: 8, height: 8)
                                Text(item.status.rawValue)
                            }
                            .frame(width: 100, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                Text(item.service)
                                    .foregroundColor(.secondary)
                                if let name = item.processName, let pid = item.pid {
                                    Text("\(name) (PID: \(pid))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            if let pid = item.pid {
                                Button(action: { killProcess(pid) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                                .help("Kill Process \(pid)")
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .listStyle(InsetListStyle())
    }
    
    var resultsHeader: some View {
        HStack {
            Text("PORT")
                .frame(width: 80, alignment: .leading)
            Text("STATUS")
                .frame(width: 100, alignment: .leading)
            Text("SERVICE")
            Spacer()
        }
        .font(.caption.weight(.bold))
        .foregroundColor(.secondary)
        .padding(.bottom, 4)
    }
    
    var footerView: some View {
        HStack {
            if engine.isScanning {
                Text("Scanning \(engine.currentTarget)...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Ready")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("SwiftUI + Network Framework")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Material.ultraThin)
    }
    
    private func startScanning() {
        let start = Int(startPort) ?? 1
        let end = Int(endPort) ?? 1024
        let range = start...end
        engine.startScan(target: targetIP, range: range)
    }
    
    private func statusColor(_ status: PortStatus) -> Color {
        switch status {
        case .open: return .green
        case .closed: return .red
        case .filtered: return .orange
        case .scanning: return .blue
        }
    }
    
    private func killProcess(_ pid: Int) {
        Task {
            do {
                try ProcessManager.shared.killProcess(pid: pid)
                // Remove the port from list or mark as closed? 
                // For now, let's just re-scan that single port or manually refresh
                print("Killed process \(pid)")
            } catch {
                print("Failed to kill process: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
