import Foundation
import Combine
import WidgetKit

private let appGroupID = "group.com.stageX.balance"

class FamilyStore: ObservableObject {
    @Published var members: [FamilyMember] = []

    private let saveKey = "family_members_v1"
    private var sharedDefaults: UserDefaults { UserDefaults(suiteName: appGroupID) ?? .standard }

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

    func reorderFamilyMembers(fromOffsets source: IndexSet, toOffset destination: Int) {
        let myself = members.filter { $0.relationship == .myself }
        var family = members.filter { $0.relationship != .myself }
        family.move(fromOffsets: source, toOffset: destination)
        members = myself + family
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(members) else { return }
        sharedDefaults.set(data, forKey: saveKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func load() {
        // Migrate from standard UserDefaults to shared App Group defaults if needed
        if let old = UserDefaults.standard.data(forKey: saveKey),
           sharedDefaults.data(forKey: saveKey) == nil {
            sharedDefaults.set(old, forKey: saveKey)
        }
        guard let data = sharedDefaults.data(forKey: saveKey),
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
            note: "Loves painting and stories before bed.",
            gender: .female
        )

        let parentBirth = calendar.date(byAdding: .year, value: -65, to: Date()) ?? Date()
        let parent = FamilyMember(
            name: "Mom",
            birthDate: parentBirth,
            relationship: .parent,
            visitFrequency: .monthly,
            note: "Sunday calls and holiday visits mean the world.",
            gender: .female
        )

        members = [child, parent]
        save()
    }
}
