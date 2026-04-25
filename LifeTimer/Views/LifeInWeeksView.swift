import SwiftUI

struct LifeInWeeksView: View {
    @Environment(\.dismiss) var dismiss
    let member: FamilyMember

    private var colors: [Color] { member.relationship.cardColors }
    private var totalWeeks: Int { member.lifeExpectancy * 52 }
    private var weeksLived: Int { member.weeksLived }
    private var weeksRemaining: Int { member.weeksRemaining }
    private var currentWeekIndex: Int { weeksLived }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    statsHeader
                    legendRow
                    weeksGrid
                    footerNote
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle("\(member.name)'s Life in Weeks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                }
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 0) {
            statCell(
                value: "\(weeksLived)",
                label: "weeks lived",
                valueColor: colors[0]
            )
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 1, height: 44)
            statCell(
                value: "\(weeksRemaining)",
                label: "weeks ahead",
                valueColor: Color(.secondaryLabel)
            )
            Rectangle()
                .fill(Color(.separator))
                .frame(width: 1, height: 44)
            statCell(
                value: "\(totalWeeks)",
                label: "total weeks",
                valueColor: Color(.label)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 16).fill(colors[1].opacity(0.3)))
    }

    private func statCell(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(valueColor)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var legendRow: some View {
        HStack(spacing: 20) {
            legendItem(color: colors[0], label: "Lived")
            legendItem(color: colors[0], label: "This week", isCurrent: true)
            legendItem(color: Color(.systemGray5), label: "Ahead")
        }
    }

    private func legendItem(color: Color, label: String, isCurrent: Bool = false) -> some View {
        HStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(isCurrent ? color.opacity(0.3) : color.opacity(0.85))
                    .frame(width: 14, height: 14)
                if isCurrent {
                    RoundedRectangle(cornerRadius: 1.5)
                        .strokeBorder(color, lineWidth: 2)
                        .frame(width: 14, height: 14)
                }
            }
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private var weeksGrid: some View {
        LazyVStack(alignment: .leading, spacing: 3) {
            ForEach(0..<member.lifeExpectancy, id: \.self) { year in
                yearRow(year: year)
            }
        }
    }

    private func yearRow(year: Int) -> some View {
        HStack(spacing: 0) {
            // Year label — only show every 5th year
            Text(year % 5 == 0 ? "\(year)" : "")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)
                .padding(.trailing, 5)

            // 52 week boxes
            HStack(spacing: 1) {
                ForEach(0..<52, id: \.self) { week in
                    weekBox(weekIndex: year * 52 + week)
                }
            }
        }
    }

    private func weekBox(weekIndex: Int) -> some View {
        let isLived = weekIndex < currentWeekIndex
        let isCurrent = weekIndex == currentWeekIndex

        return RoundedRectangle(cornerRadius: 1)
            .fill(isLived ? colors[0].opacity(0.82) : (isCurrent ? colors[0].opacity(0.25) : Color(.systemGray5)))
            .frame(width: 5, height: 5)
            .overlay(
                isCurrent
                    ? RoundedRectangle(cornerRadius: 1).strokeBorder(colors[0], lineWidth: 1.5)
                    : nil
            )
    }

    private var footerNote: some View {
        Text("Each row is one year · Each box is one week · \(member.lifeExpectancy) year life expectancy")
            .font(.system(size: 11, design: .rounded))
            .foregroundColor(Color(.tertiaryLabel))
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
}
