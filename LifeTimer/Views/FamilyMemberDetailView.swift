import SwiftUI

struct FamilyMemberDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: FamilyStore
    let initialMember: FamilyMember
    @State private var showingEdit = false
    @State private var showingLifeInWeeks = false

    private var member: FamilyMember {
        store.members.first(where: { $0.id == initialMember.id }) ?? initialMember
    }
    private var colors: [Color] { member.relationship.cardColors }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                statsSection
                    .padding(20)
                    .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showingEdit) {
            AddFamilyMemberView(existingMember: member)
        }
        .sheet(isPresented: $showingLifeInWeeks) {
            LifeInWeeksView(member: member)
        }
    }

    private var heroHeader: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.primary.opacity(0.45))
                    }
                    Spacer()
                    Button("Edit") { showingEdit = true }
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(Color.primary.opacity(0.65))
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                VStack(spacing: 10) {
                    Text(member.relationship.emoji)
                        .font(.system(size: 72))
                    Text(member.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text(member.relationship.rawValue)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("Age \(member.ageInYears)")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Life so far")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(member.lifeFractionElapsed * 100))% of expected lifespan")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    LifeProgressBar(fraction: member.lifeFractionElapsed, colors: colors)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            mainStatCard
            lifeInWeeksButton
            secondaryStatsGrid
            if !member.note.isEmpty { noteCard }
            quoteCard
            deleteButton
        }
    }

    private var mainStatCard: some View {
        VStack(spacing: 8) {
            Text("\(member.remainingMoments)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                )
            Text("estimated \(member.remainingMomentsLabel)")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(RoundedRectangle(cornerRadius: 18).fill(colors[1].opacity(0.35)))
    }

    private var lifeInWeeksButton: some View {
        Button { showingLifeInWeeks = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "squareshape.split.3x3")
                    .font(.system(size: 20))
                    .foregroundStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                VStack(alignment: .leading, spacing: 2) {
                    Text("View Life in Weeks")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Every box is one week of life")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(colors[1].opacity(0.3)))
        }
        .buttonStyle(.plain)
    }

    private var secondaryStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            StatCard(icon: "hourglass", label: "Years remaining", value: String(format: "~%.0f", member.remainingYears), subtitle: "estimated")
            if member.relationship == .myself {
                StatCard(icon: "calendar", label: "Weeks lived", value: "\(member.weeksLived)", subtitle: "so far")
            } else {
                StatCard(icon: "calendar.badge.clock", label: "See them", value: member.visitFrequency.rawValue, isText: true)
            }
            if member.relationship == .child, let leavesAt = member.leavesHomeAtAge {
                let yearsLeft = max(0, leavesAt - member.ageInYears)
                StatCard(icon: "house.fill", label: "At home", value: "\(yearsLeft)", subtitle: "more years")
            }
            StatCard(icon: "heart.fill", label: "Life expectancy", value: "\(member.lifeExpectancy)", subtitle: "years")
        }
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your note", systemImage: "note.text")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            Text(member.note)
                .font(.system(size: 16, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\u{201C}")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 2)
                .padding(.bottom, -16)
            Text(member.relationship.inspirationalQuote)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
                .italic()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(colors[1].opacity(0.25)))
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            store.delete(member)
            dismiss()
        } label: {
            Label("Remove from list", systemImage: "trash")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.red.opacity(0.75))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.07)))
        }
        .padding(.top, 4)
        .padding(.bottom, 20)
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    var subtitle: String = ""
    var isText: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            if isText {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .lineLimit(2)
            } else {
                Text(value)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
            }
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }
}
