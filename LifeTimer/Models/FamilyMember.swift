import SwiftUI
import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Non-binary / Other"
}

enum PetType: String, Codable, CaseIterable {
    case dog = "Dog"
    case cat = "Cat"
    case rabbit = "Rabbit"
    case bird = "Bird"
    case hamster = "Hamster"
    case guineaPig = "Guinea Pig"
    case fish = "Fish"
    case horse = "Horse"
    case turtle = "Turtle"
    case other = "Other"

    var emoji: String {
        switch self {
        case .dog: return "🐕"
        case .cat: return "🐈"
        case .rabbit: return "🐇"
        case .bird: return "🦜"
        case .hamster: return "🐹"
        case .guineaPig: return "🐾"
        case .fish: return "🐠"
        case .horse: return "🐎"
        case .turtle: return "🐢"
        case .other: return "🐾"
        }
    }

    // Typical median lifespan in years
    var defaultLifeExpectancy: Int {
        switch self {
        case .dog: return 13
        case .cat: return 15
        case .rabbit: return 10
        case .bird: return 15
        case .hamster: return 2
        case .guineaPig: return 5
        case .fish: return 5
        case .horse: return 28
        case .turtle: return 40
        case .other: return 12
        }
    }
}

enum RelationshipType: String, Codable, CaseIterable {
    case myself = "Yourself"
    case child = "Child"
    case parent = "Parent"
    case grandparent = "Grandparent"
    case partner = "Partner"
    case sibling = "Sibling"
    case friend = "Close Friend"
    case pet = "Pet"

    var defaultLifeExpectancy: Int {
        switch self {
        case .grandparent: return 85
        case .pet: return 13
        default: return 80
        }
    }

    var cardColors: [Color] {
        switch self {
        case .myself:
            return [Color(red: 0.36, green: 0.46, blue: 0.90), Color(red: 0.68, green: 0.76, blue: 0.98)]
        case .child:
            return [Color(red: 1.00, green: 0.78, blue: 0.45), Color(red: 1.00, green: 0.92, blue: 0.72)]
        case .parent:
            return [Color(red: 0.50, green: 0.74, blue: 0.96), Color(red: 0.76, green: 0.91, blue: 1.00)]
        case .grandparent:
            return [Color(red: 0.76, green: 0.66, blue: 0.94), Color(red: 0.91, green: 0.84, blue: 0.99)]
        case .partner:
            return [Color(red: 0.96, green: 0.58, blue: 0.70), Color(red: 1.00, green: 0.80, blue: 0.87)]
        case .sibling:
            return [Color(red: 0.45, green: 0.86, blue: 0.74), Color(red: 0.76, green: 0.97, blue: 0.88)]
        case .friend:
            return [Color(red: 0.94, green: 0.86, blue: 0.48), Color(red: 1.00, green: 0.97, blue: 0.76)]
        case .pet:
            return [Color(red: 0.44, green: 0.72, blue: 0.50), Color(red: 0.74, green: 0.92, blue: 0.76)]
        }
    }

    var inspirationalQuote: String {
        switch self {
        case .myself:
            return "You have one life. Make it matter — not perfectly, just fully."
        case .child:
            return "The days are long, but the years are short. Hold them a little tighter today."
        case .parent:
            return "Call them. Visit them. The ordinary moments become the extraordinary memories."
        case .grandparent:
            return "Their stories are your roots. Listen while you still can."
        case .partner:
            return "Be present in the small moments — they add up to a lifetime."
        case .sibling:
            return "No one else will ever know the history you share."
        case .friend:
            return "True friendship is rare. Tend to it often."
        case .pet:
            return "They love you unconditionally and ask for so little. Be present with them."
        }
    }
}

enum VisitFrequency: String, Codable, CaseIterable {
    case livingTogether = "Living Together"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case fewTimesYear = "A Few Times a Year"
    case yearly = "Once a Year"

    var visitsPerYear: Double {
        switch self {
        case .livingTogether: return 52
        case .weekly: return 52
        case .monthly: return 12
        case .fewTimesYear: return 4
        case .yearly: return 1
        }
    }

    var momentLabel: String {
        switch self {
        case .livingTogether, .weekly: return "weekends"
        case .monthly, .fewTimesYear, .yearly: return "visits"
        }
    }
}

struct FamilyMember: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var birthDate: Date
    var relationship: RelationshipType
    var visitFrequency: VisitFrequency
    var lifeExpectancy: Int
    var leavesHomeAtAge: Int?
    var note: String
    var gender: Gender
    var petType: PetType?

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        relationship: RelationshipType,
        visitFrequency: VisitFrequency = .monthly,
        lifeExpectancy: Int? = nil,
        leavesHomeAtAge: Int? = nil,
        note: String = "",
        gender: Gender = .other,
        petType: PetType? = nil
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.relationship = relationship
        self.visitFrequency = visitFrequency
        self.lifeExpectancy = lifeExpectancy ?? (petType?.defaultLifeExpectancy ?? relationship.defaultLifeExpectancy)
        self.leavesHomeAtAge = leavesHomeAtAge
        self.note = note
        self.gender = gender
        self.petType = petType
    }

    // Custom decoder for backward compatibility
    enum CodingKeys: CodingKey {
        case id, name, birthDate, relationship, visitFrequency, lifeExpectancy, leavesHomeAtAge, note, gender, petType
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        birthDate = try c.decode(Date.self, forKey: .birthDate)
        relationship = try c.decode(RelationshipType.self, forKey: .relationship)
        visitFrequency = try c.decode(VisitFrequency.self, forKey: .visitFrequency)
        lifeExpectancy = try c.decode(Int.self, forKey: .lifeExpectancy)
        leavesHomeAtAge = try c.decodeIfPresent(Int.self, forKey: .leavesHomeAtAge)
        note = try c.decode(String.self, forKey: .note)
        gender = try c.decodeIfPresent(Gender.self, forKey: .gender) ?? .other
        petType = try c.decodeIfPresent(PetType.self, forKey: .petType)
    }

    var emoji: String {
        switch relationship {
        case .myself: return "⏳"
        case .pet: return petType?.emoji ?? "🐾"
        case .child:
            switch gender {
            case .male: return "👦"
            case .female: return "👧"
            case .other: return "🧒"
            }
        case .parent:
            switch gender {
            case .male: return "👨"
            case .female: return "👩"
            case .other: return "🧑"
            }
        case .grandparent:
            switch gender {
            case .male: return "👴"
            case .female: return "👵"
            case .other: return "🧓"
            }
        case .partner:
            return "💞"
        case .sibling:
            switch gender {
            case .male: return "👦"
            case .female: return "👧"
            case .other: return "🤝"
            }
        case .friend:
            return "🫂"
        }
    }

    var ageInYears: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var ageInYearsDouble: Double {
        let days = Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
        return Double(days) / 365.25
    }

    var remainingYears: Double {
        max(0, Double(lifeExpectancy) - ageInYearsDouble)
    }

    var weeksLived: Int { Int(ageInYearsDouble * 52) }
    var weeksRemaining: Int { max(0, lifeExpectancy * 52 - weeksLived) }

    var remainingMoments: Int {
        switch relationship {
        case .myself, .pet:
            return weeksRemaining
        case .child:
            if let leavesAt = leavesHomeAtAge {
                let yearsAtHome = max(0.0, Double(leavesAt) - ageInYearsDouble)
                return Int(yearsAtHome * 52)
            }
            return Int(remainingYears * visitFrequency.visitsPerYear)
        default:
            return Int(remainingYears * visitFrequency.visitsPerYear)
        }
    }

    var remainingMomentsLabel: String {
        switch relationship {
        case .myself: return "weeks remaining in your life"
        case .pet: return "weeks together estimated"
        case .child where leavesHomeAtAge != nil: return "weekends left at home"
        default: return visitFrequency.momentLabel + " remaining"
        }
    }

    var lifeFractionElapsed: Double {
        min(1.0, max(0.0, ageInYearsDouble / Double(lifeExpectancy)))
    }
}
