import SwiftUI

enum GestureToken: String, CaseIterable, Hashable {
    case hello    = "HELLO"
    case help     = "HELP"
    case yes      = "YES"
    case no       = "NO"
    case thankYou = "THANK YOU"
    case please   = "PLEASE"
    case more     = "MORE"
    case stop     = "STOP"

    var emoji: String {
        switch self {
        case .hello:    return "👋"
        case .help:     return "🆘"
        case .yes:      return "✅"
        case .no:       return "❌"
        case .thankYou: return "🙏"
        case .please:   return "🤲"
        case .more:     return "➕"
        case .stop:     return "✋"
        }
    }

    var color: Color {
        switch self {
        case .hello, .thankYou: return .blue
        case .help, .stop:      return .red
        case .yes, .please:     return .green
        case .no:               return .orange
        case .more:             return .purple
        }
    }
}
