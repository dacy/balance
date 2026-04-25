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

    init(existingMember: FamilyMember? = nil, initialRelationship: RelationshipType = .parent) {
        self.existingMember = existingMember
        let rel = existingMember?.relationship ?? initialRelationship
        _relationship = State(initialValue: rel)
        let defaultAge = rel == .myself ? -35 : -40
        _birthDate = State(initialValue: Calendar.current.date(byAdding: .year, value: defaultAge, to: Date()) ?? Date())
        _name = State(initialValue: "")
        _gender = State(initialValue: existingMember?.gender ?? .other)
    }

    var isEditing: Bool { existingMember != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(relationship == .myself ? "About you" : "About them") {
                    TextField(relationship == .myself ? "Your name" : "Name", text: $name)
                    DatePicker("Birthday", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    if relationship != .myself {
                        Picker("Relationship", selection: $relationship) {
                            ForEach(RelationshipType.allCases.filter { $0 != .myself }, id: \.self) { rel in
                                Text(rel.rawValue).tag(rel)
                            }
                        }
                        Picker("Gender", selection: $gender) {
                            ForEach(Gender.allCases, id: \.self) { g in
                                Text(g.rawValue).tag(g)
                            }
                        }
                    }
                }

                if relationship != .myself {
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

                if relationship == .child {
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

                Section {
                    Stepper("Life expectancy: \(lifeExpectancy) years", value: $lifeExpectancy, in: 50...120)
                } header: {
                    Text("Expected lifespan")
                } footer: {
                    Text("Adjust this as you see fit — it's only used to estimate time.")
                }

                Section("A note (optional)") {
                    TextField("Something to remember about them…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit" : "Add Person")
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
                lifeExpectancy = newValue.defaultLifeExpectancy
                if newValue == .child {
                    visitFrequency = .livingTogether
                    includeLeavesHomeAge = true
                } else if newValue == .myself {
                    visitFrequency = .livingTogether
                }
            }
        }
    }

    private func populateIfEditing() {
        guard let member = existingMember else { return }
        name = member.name
        birthDate = member.birthDate
        relationship = member.relationship
        visitFrequency = member.visitFrequency
        lifeExpectancy = member.lifeExpectancy
        note = member.note
        if let leavesAt = member.leavesHomeAtAge {
            leavesHomeAtAge = leavesAt
            includeLeavesHomeAge = true
        }
        gender = member.gender
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let leavesAt: Int? = (relationship == .child && includeLeavesHomeAge) ? leavesHomeAtAge : nil

        if var member = existingMember {
            member.name = trimmed
            member.birthDate = birthDate
            member.relationship = relationship
            member.visitFrequency = visitFrequency
            member.lifeExpectancy = lifeExpectancy
            member.leavesHomeAtAge = leavesAt
            member.note = note
            member.gender = gender
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
                gender: gender
            ))
        }
        dismiss()
    }
}
