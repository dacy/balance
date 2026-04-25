import WidgetKit
import SwiftUI

// MARK: - Shared constants

private let appGroupID = "group.com.stageX.balance"
private let membersKey = "family_members_v1"

// MARK: - Timeline Entry

struct LifeTimerEntry: TimelineEntry {
    let date: Date
    let members: [FamilyMember]

    var myself: FamilyMember? { members.first { $0.relationship == .myself } }
    var family: [FamilyMember] { members.filter { $0.relationship != .myself } }

    var mediumPeople: [FamilyMember] {
        var result: [FamilyMember] = []
        if let me = myself { result.append(me) }
        result += family.prefix(2 - result.count)
        return result
    }

    var largePeople: [FamilyMember] {
        var result: [FamilyMember] = []
        if let me = myself { result.append(me) }
        result += family.prefix(4 - result.count)
        return result
    }
}

// MARK: - Timeline Provider

struct LifeTimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeTimerEntry {
        LifeTimerEntry(date: Date(), members: sampleMembers)
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeTimerEntry) -> Void) {
        completion(LifeTimerEntry(date: Date(), members: loadMembers()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeTimerEntry>) -> Void) {
        let entry = LifeTimerEntry(date: Date(), members: loadMembers())
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func loadMembers() -> [FamilyMember] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: membersKey),
              let members = try? JSONDecoder().decode([FamilyMember].self, from: data)
        else { return sampleMembers }
        return members
    }

    private var sampleMembers: [FamilyMember] {
        let cal = Calendar.current
        return [
            FamilyMember(
                name: "You",
                birthDate: cal.date(byAdding: .year, value: -35, to: Date()) ?? Date(),
                relationship: .myself,
                gender: .other
            ),
            FamilyMember(
                name: "Emma",
                birthDate: cal.date(byAdding: .year, value: -8, to: Date()) ?? Date(),
                relationship: .child,
                visitFrequency: .livingTogether,
                leavesHomeAtAge: 18,
                gender: .female
            ),
        ]
    }
}

// MARK: - Root Widget View

struct LifeTimerWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: LifeTimerEntry

    var body: some View {
        switch family {
        case .systemSmall:
            if let primary = entry.myself ?? entry.family.first {
                SmallWidgetView(member: primary)
                    .widgetBackground {
                        LinearGradient(
                            colors: primary.relationship.cardColors,
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    }
            } else {
                EmptyWidgetView()
                    .widgetBackground { Color(.systemBackground) }
            }
        case .systemMedium:
            if entry.mediumPeople.isEmpty {
                EmptyWidgetView()
                    .widgetBackground { Color(.systemBackground) }
            } else {
                MediumWidgetView(members: entry.mediumPeople)
                    .widgetBackground {
                        HStack(spacing: 0) {
                            ForEach(Array(entry.mediumPeople.prefix(2).enumerated()), id: \.offset) { _, member in
                                LinearGradient(
                                    colors: member.relationship.cardColors,
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            }
                        }
                    }
            }
        default:
            if entry.largePeople.isEmpty {
                EmptyWidgetView()
                    .widgetBackground { Color(.systemBackground) }
            } else {
                LargeWidgetView(members: entry.largePeople)
                    .widgetBackground { Color(.systemBackground) }
            }
        }
    }
}

// MARK: - Small Widget (1 person)

struct SmallWidgetView: View {
    let member: FamilyMember

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(member.emoji).font(.system(size: 26))
                Spacer()
                Text("Age \(member.ageInYears)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Text(member.name)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            Text("\(member.remainingMoments)")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
            Text(shortLabel(member))
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(2)
                .padding(.bottom, 6)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.18)).frame(height: 5)
                    Capsule().fill(Color.white.opacity(0.90))
                        .frame(width: max(5, geo.size.width * member.lifeFractionElapsed), height: 5)
                }
            }
            .frame(height: 5)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func shortLabel(_ m: FamilyMember) -> String {
        if m.relationship == .myself { return "weeks remaining" }
        if m.relationship == .child, m.leavesHomeAtAge != nil { return "weekends at home" }
        return m.visitFrequency.momentLabel + " remaining"
    }
}

// MARK: - Medium Widget (2 people side-by-side)

struct MediumWidgetView: View {
    let members: [FamilyMember]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(members.prefix(2).enumerated()), id: \.offset) { idx, member in
                if idx > 0 {
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 1)
                }
                MediumCell(member: member)
            }
        }
    }
}

struct MediumCell: View {
    let member: FamilyMember

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(member.emoji).font(.system(size: 22))
                Spacer()
                Text("Age \(member.ageInYears)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Text(member.name)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
            Text("\(member.remainingMoments)")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
            Text(shortLabel(member))
                .font(.system(size: 8, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
                .padding(.bottom, 5)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.18)).frame(height: 4)
                    Capsule().fill(Color.white.opacity(0.90))
                        .frame(width: max(4, geo.size.width * member.lifeFractionElapsed), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func shortLabel(_ m: FamilyMember) -> String {
        if m.relationship == .myself { return "weeks remaining" }
        if m.relationship == .child, m.leavesHomeAtAge != nil { return "weekends at home" }
        return m.visitFrequency.momentLabel + " remaining"
    }
}

// MARK: - Large Widget (up to 4 people in rows)

struct LargeWidgetView: View {
    let members: [FamilyMember]
    private let accentGradient = LinearGradient(
        colors: [Color(red: 0.80, green: 0.38, blue: 0.18), Color(red: 0.95, green: 0.62, blue: 0.28)],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Balance")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(accentGradient)
                Spacer()
                Image(systemName: "heart.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(accentGradient)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ForEach(Array(members.prefix(4).enumerated()), id: \.offset) { idx, member in
                LargeRow(member: member)
                if idx < min(members.count, 4) - 1 {
                    Divider().padding(.leading, 56)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LargeRow: View {
    let member: FamilyMember
    private var colors: [Color] { member.relationship.cardColors }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                Text(member.emoji)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(member.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                    Spacer()
                    Text("\(member.remainingMoments)")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(colors[0])
                }
                HStack {
                    Text("Age \(member.ageInYears) · \(member.relationship.rawValue)")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(shortLabel(member))
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5)).frame(height: 3)
                        Capsule().fill(colors[0])
                            .frame(width: max(3, geo.size.width * member.lifeFractionElapsed), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func shortLabel(_ m: FamilyMember) -> String {
        if m.relationship == .myself { return "weeks left" }
        if m.relationship == .child, m.leavesHomeAtAge != nil { return "wknds at home" }
        return m.visitFrequency.momentLabel
    }
}

// MARK: - Empty State

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.circle")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("Open Balance\nto add people")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Configuration

struct LifeTimerWidget: Widget {
    let kind = "LifeTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeTimerProvider()) { entry in
            LifeTimerWidgetView(entry: entry)
        }
        .configurationDisplayName("Balance")
        .description("See how much time you have left with the people you love.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// containerBackground fills edge-to-edge on iOS 17+; falls back to .background() on iOS 16
private extension View {
    @ViewBuilder
    func widgetBackground<B: View>(@ViewBuilder _ background: () -> B) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) { background() }
        } else {
            self.background(background())
        }
    }
}
