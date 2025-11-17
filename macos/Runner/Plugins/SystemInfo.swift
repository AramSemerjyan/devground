import Foundation
import Darwin
import FlutterMacOS

class SystemInfo {
    static func setUpChannel(binnaryMessagner: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
          name: "system_monitor",
          binaryMessenger: binnaryMessagner
        )
        
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "cpu":
                result([
                  "cpu": getCPUUsage()
                ])
            case "memory":
                let memory = memoryUsage()
                
                result([
                  "used": memory.used,
                  "free": memory.free
                ])
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    static func getCPUUsage() -> Double {
        var threads: thread_array_t? = nil
        var threadCount: mach_msg_type_number_t = 0
        let kr = task_threads(mach_task_self_, &threads, &threadCount)
        if kr != KERN_SUCCESS {
            return -1
        }

        var totalUsage: Double = 0
        if let threads = threads {
            for i in 0..<Int(threadCount) {
                var info = thread_basic_info()
                var count = mach_msg_type_number_t(THREAD_INFO_MAX)
                let kr = withUnsafeMutablePointer(to: &info) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                        thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                    }
                }
                if kr == KERN_SUCCESS {
                    totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100
                }
            }
        }
        
        return totalUsage
    }

    static func memoryUsage() -> (used: Double, free: Double) {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &stats) { statsPtr in
            statsPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, 0)
        }

        let pageSize = UInt64(vm_kernel_page_size)

        let free = UInt64(stats.free_count) * pageSize
        let used = (UInt64(stats.active_count)
                   + UInt64(stats.inactive_count)
                   + UInt64(stats.wire_count)) * pageSize

        return (Double(used) / 1024 / 1024 / 1024, Double(free) / 1024 / 1024 / 1024)
    }
}
