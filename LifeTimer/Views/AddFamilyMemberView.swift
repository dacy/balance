import SwiftUI

struct AddFamilyMemberView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: FamilyStore

    let existingMember: FamilyMember?

    @State private var name: String
    @State private var birthDate: Date
    @State private var relationship: RelationshipType
    @State private var visitFrequency: VisitFrequency = .monthly
    @State private var lifeExpectancy: Int = 80
    @State private var leavesHomeAtAge: Int = 18
    @State private var includeLeavesHomeAge: Bool = false
    @State private var note: String = ""
    @State private var gender: Gender = .other
    @State private var petType: PetType = .dog

    init(existingMember: FamilyMember? = nil, initialRelationship: RelationshipType = .parent) {
        self.existingMember = existingMember
        let rel = existingMember?.relationship ?? initialRelationship
        _relationship = State(initialValue: rel)
        let defaultAge = rel == .myself ? -35 : (rel == .pet ? -3 : -40)
        _birthDate = State(initialValue: Calendar.current.date(byAdding: .year, value: defaultAge, to: Date()) ?? Date())
        _name = State(initialValue: "")
        _gender = State(initialValue: existingMember?.gender ?? .other)
        _petType = State(initialValue: existingMember?.petType ?? .dog)
        _lifeExpectancy = State(initialValue: existingMember?.lifeExpectancy ?? rel.defaultLifeExpectancy)
    }

    var isEditing: Bool { existingMember != nil }

    private var isPet: Bool { relationship == .pet }
    private var isSelf: Bool { relationship == .myself }

    var body: some View {
        NavigationStack {
            Form {
                aboutSection
                if isPet { petTypeSection }
                if !isSelf && !isPet { visitFrequencySection }
                if relationship == .child { childSection }
                lifeExpectancySection
                noteSection
            }
            .navigationTitle(formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populateIfEditing() }
            .onChange(of: relationship) { newValue in
                lifeExpectancy = newValue == .pet ? petType.defaultLifeExpectancy : newValue.defaultLifeExpectancy
                if newValue == .child {
                    visitFrequency = .livingTogether
                    includeLeavesHomeAge = true
                } else if newValue == .myself || newValue == .pet {
                    visitFrequency = .livingTogether
                }
            }
            .onChange(of: petType) { newPetType in
                lifeExpectancy = newPetType.defaultLifeExpectancy
            }
        }
    }

    private var formTitle: String {
        if isEditing { return "Edit" }
        if isSelf { return "Your Timer" }
        if isPet { return "Add a Pet" }
        return "Add Person"
    }

    // MARK: – Form sections

    private var aboutSection: some View {
        Section(isSelf ? "About you" : (isPet ? "About your pet" : "About them")) {
            TextField(isSelf ? "Your name" : (isPet ? "Pet's name" : "Name"), text: $name)
            DatePicker("Birthday", selection: $birthDate, in: ...Date(), displayedComponents: .date)
            if !isSelf {
                Picker("Relationship", selection: $relationship) {
                    ForEach(RelationshipType.allCases.filter { $0 != .myself }, id: \.self) { rel in
                        Text(rel.rawValue).tag(rel)
                    }
                }
            }
            if !isSelf && !isPet {
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { g in
                        Text(g.rawValue).tag(g)
                    }
                }
            }
        }
    }

    private var petTypeSection: some View {
        Section("Type of pet") {
            Picker("Species", selection: $petType) {
                ForEach(PetType.allCases, id: \.self) { pt in
                    Label(pt.rawValue, title: { Text(pt.rawValue) })
                        .tag(pt)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    private var visitFrequencySection: some View {
        Section("How often do you see them?") {
            Picker("Frequency", selection: $visitFrequency) {
                ForEach(VisitFrequency.allCases, id: \.self) { freq in
                    Text(freq.rawValue).tag(freq)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    private var childSection: some View {
        Section {
            Toggle("They'll leave home someday", isOn: $includeLeavesHomeAge)
            if includeLeavesHomeAge {
                Stepper("Leaves home at age \(leavesHomeAtAge)", value: $leavesHomeAtAge, in: 16...30)
            }
        } header: {
            Text("Growing up")
        } footer: {
            Text("We'll count weekends at home until that age.")
        }
    }

    private var lifeExpectancySection: some View {
        Section {
            if isPet {
                Stepper("Life expectancy: \(lifeExpectancy) years", value: $lifeExpectancy, in: 1...50)
            } else {
                Stepper("Life expectancy: \(lifeExpectancy) years", value: $lifeExpectancy, in: 50...120)
            }
        } header: {
            Text(isPet ? "Expected lifespan" : "Expected lifespan")
        } footer: {
            Text(isPet
                 ? "Pre-filled from typical \(petType.rawValue.lowercased()) lifespan. Adjust for your pet."
                 : "Adjust this as you see fit — it's only used to estimate time.")
        }
    }

    private var noteSection: some View {
        Section(isPet ? "A note (optional)" : "A note (optional)") {
            TextField(
                isPet ? "Something to remember about them…" : "Something to remember about them…",
                text: $note,
                axis: .vertical
            )
            .lineLimit(3...6)
        }
    }

    // MARK: – Data

    private func populateIfEditing() {
        guard let member = existingMember else { return }
        name = member.name
        birthDate = member.birthDate
        relationship = member.relationship
        visitFrequency = member.visitFrequency
        lifeExpectancy = member.lifeExpectancy
        note = member.note
        gender = member.gender
        petType = member.petType ?? .dog
        if let leavesAt = member.leavesHomeAtAge {
            leavesHomeAtAge = leavesAt
            includeLeavesHomeAge = true
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let leavesAt: Int? = (relationship == .child && includeLeavesHomeAge) ? leavesHomeAtAge : nil
        let resolvedPetType: PetType? = isPet ? petType : nil

        if var member = existingMember {
            member.name = trimmed
            member.birthDate = birthDate
            member.relationship = relationship
            member.visitFrequency = visitFrequency
            member.lifeExpectancy = lifeExpectancy
            member.leavesHomeAtAge = leavesAt
            member.note = note
            member.gender = gender
            member.petType = resolvedPetType
            store.update(member)
        } else {
            store.add(FamilyMember(
                name: trimmed,
                birthDate: birthDate,
                relationship: relationship,
                visitFrequency: visitFrequency,
                lifeExpectancy: lifeExpectancy,
                leavesHomeAtAge: leavesAt,
                note: note,
                gender: gender,
                petType: resolvedPetType
            ))
        }
        dismiss()
    }
}
