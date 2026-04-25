import Foundation
import Combine

class FamilyStore: ObservableObject {
    @Published var members: [FamilyMember] = []

    private let saveKey = "family_members_v1"

    init() {
        load()
        if members.isEmpty {
            seedSampleData()
        }
    }

    func add(_ member: FamilyMember) {
        members.append(member)
        save()
    }

    func update(_ member: FamilyMember) {
        guard let index = members.firstIndex(where: { $0.id == member.id }) else { return }
        members[index] = member
        save()
    }

    func delete(at offsets: IndexSet) {
        members.remove(atOffsets: offsets)
        save()
    }

    func delete(_ member: FamilyMember) {
        members.removeAll { $0.id == member.id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(members) else { return }
        UserDefaults.standard.set(data, forKey: saveKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let saved = try? JSONDecoder().decode([FamilyMember].self, from: data)
        else { return }
        members = saved
    }

    private func seedSampleData() {
        let calendar = Calendar.current

        let childBirth = calendar.date(byAdding: .year, value: -8, to: Date()) ?? Date()
        let child = FamilyMember(
            name: "Emma",
            birthDate: childBirth,
            relationship: .child,
            visitFrequency: .livingTogether,
            leavesHomeAtAge: 18,
            note: "Loves painting and stories before bed."
        )

        let parentBirth = calendar.date(byAdding: .year, value: -65, to: Date()) ?? Date()
        let parent = FamilyMember(
            name: "Mom",
            birthDate: parentBirth,
            relationship: .parent,
            visitFrequency: .monthly,
            note: "Sunday calls and holiday visits mean the world."
        )

        members = [child, parent]
        save()
    }
}
