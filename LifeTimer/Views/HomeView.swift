import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: FamilyStore
    @State private var showingAddMember = false
    @State private var showingAddSelf = false
    @State private var selectedMember: FamilyMember?

    private var selfMember: FamilyMember? {
        store.members.first { $0.relationship == .myself }
    }
    private var familyMembers: [FamilyMember] {
        store.members.filter { $0.relationship != .myself }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                pageBackground
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                        selfSection
                        if !familyMembers.isEmpty {
                            familySection
                        } else if selfMember != nil {
                            addFamilyPrompt
                        }
                        if store.members.isEmpty {
                            emptyState
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMember) {
                AddFamilyMemberView()
            }
            .sheet(isPresented: $showingAddSelf) {
                AddFamilyMemberView(initialRelationship: .myself)
            }
            .sheet(item: $selectedMember) { member in
                FamilyMemberDetailView(initialMember: member)
            }
        }
    }

    private var pageBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.99, green: 0.96, blue: 0.91), Color(red: 1.0, green: 0.99, blue: 0.96)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Time With")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.80, green: 0.38, blue: 0.18), Color(red: 0.95, green: 0.62, blue: 0.28)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                Text("Cherish every moment")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                showingAddMember = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.80, green: 0.38, blue: 0.18), Color(red: 0.95, green: 0.62, blue: 0.28)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }

    private var selfSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR TIMER")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            if let self_ = selfMember {
                FamilyMemberCard(member: self_)
                    .padding(.horizontal, 20)
                    .onTapGesture { selectedMember = self_ }
            } else {
                addSelfCard
                    .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }

    private var addSelfCard: some View {
        let selfColors: [Color] = [Color(red: 0.36, green: 0.46, blue: 0.90), Color(red: 0.68, green: 0.76, blue: 0.98)]
        return Button { showingAddSelf = true } label: {
            HStack(spacing: 16) {
                Text("⏳")
                    .font(.system(size: 36))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add your own timer")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("See your life in weeks")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.system(size: 22))
                    .foregroundColor(selfColors[0].opacity(0.7))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selfColors[1].opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(colors: selfColors.map { $0.opacity(0.5) }, startPoint: .leading, endPoint: .trailing),
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var familySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR PEOPLE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            LazyVStack(spacing: 18) {
                ForEach(familyMembers) { member in
                    FamilyMemberCard(member: member)
                        .onTapGesture { selectedMember = member }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }

    private var addFamilyPrompt: some View {
        Button { showingAddMember = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary)
                Text("Add a family member or friend")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)
            Text("🌟")
                .font(.system(size: 64))
            Text("Add your loved ones")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
            Text("See how many precious moments\nyou have left to share together.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button { showingAddMember = true } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.80, green: 0.38, blue: 0.18), Color(red: 0.95, green: 0.62, blue: 0.28)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}
