import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: FamilyStore
    @State private var showingAddMember = false
    @State private var selectedMember: FamilyMember?

    var body: some View {
        NavigationStack {
            ZStack {
                pageBackground
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                        if store.members.isEmpty {
                            emptyState
                        } else {
                            membersList
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMember) {
                AddFamilyMemberView()
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
        .padding(.bottom, 28)
    }

    private var membersList: some View {
        LazyVStack(spacing: 18) {
            ForEach(store.members) { member in
                FamilyMemberCard(member: member)
                    .onTapGesture { selectedMember = member }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 80)
            Text("🌟")
                .font(.system(size: 64))
            Text("Add your loved ones")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
            Text("See how many precious moments\nyou have left to share together.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showingAddMember = true
            } label: {
                Text("Add a Family Member")
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
            Spacer(minLength: 80)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
}
