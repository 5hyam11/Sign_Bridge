import Foundation

struct PhraseCandidate: Identifiable {
    let id = UUID()
    let text: String
    let score: Double
}

class PhraseDatabase {
    static let shared = PhraseDatabase()

    private let rules: [([GestureToken], String, Double)] = [
        // Single tokens
        ([.hello],    "Hello! Nice to meet you.",        1.0),
        ([.help],     "I need help please.",             1.0),
        ([.yes],      "Yes, that is correct.",           1.0),
        ([.no],       "No, that is not right.",          1.0),
        ([.thankYou], "Thank you so much.",              1.0),
        ([.please],   "Please help me.",                 0.9),
        ([.more],     "I need more time.",               0.9),
        ([.stop],     "Please stop.",                    1.0),

        // Two tokens
        ([.hello, .help],     "Hello, I need some help right now.", 1.1),
        ([.hello, .thankYou], "Hello! Thank you for being here.",   1.1),
        ([.help, .please],    "Can you help me please?",            1.1),
        ([.no, .stop],        "No, please stop that.",              1.1),
        ([.yes, .please],     "Yes please, that would be great.",   1.1),
        ([.more, .please],    "Could I have more please?",          1.1),
        ([.help, .more],      "I need more help.",                  1.0),

        // Three tokens
        ([.hello, .help, .please], "Hello! Could you please help me?", 1.2),
        ([.yes, .more, .please],   "Yes, more of that please.",         1.2),
        ([.no, .help, .please],    "No, I don't need help right now.",  1.2),
    ]

    func lookup(tokens: [GestureToken]) -> [PhraseCandidate] {
        guard !tokens.isEmpty else { return [] }
        var scored: [(String, Double)] = []

        for (pattern, phrase, priority) in rules {
            let patternSet = Set(pattern)
            let querySet = Set(tokens)
            guard patternSet.isSubset(of: querySet) else { continue }
            let lengthBonus = Double(pattern.count) / Double(max(tokens.count, 1))
            let score = priority * (0.5 + 0.5 * lengthBonus)
            scored.append((phrase, score))
        }

        return scored
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { PhraseCandidate(text: $0.0, score: $0.1) }
    }
}
