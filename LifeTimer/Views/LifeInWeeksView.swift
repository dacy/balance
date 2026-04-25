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
            VStack(spacing: 10) {
                statsHeader
                legendRow
                GeometryReader { geo in
                    weeksGridFitted(in: geo.size)
                }
                footerNote
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)
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
            statCell(value: "\(weeksLived)", label: "weeks lived", valueColor: colors[0])
            Rectangle().fill(Color(.separator)).frame(width: 1, height: 36)
            statCell(value: "\(weeksRemaining)", label: "weeks ahead", valueColor: Color(.secondaryLabel))
            Rectangle().fill(Color(.separator)).frame(width: 1, height: 36)
            statCell(value: "\(totalWeeks)", label: "total weeks", valueColor: Color(.label))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(colors[1].opacity(0.3)))
    }

    private func statCell(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(valueColor)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var legendRow: some View {
        HStack(spacing: 16) {
            legendItem(color: colors[0], label: "Lived")
            legendItem(color: colors[0], label: "This week", isCurrent: true)
            legendItem(color: Color(.systemGray5), label: "Ahead")
        }
    }

    private func legendItem(color: Color, label: String, isCurrent: Bool = false) -> some View {
        HStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(isCurrent ? color.opacity(0.3) : color.opacity(0.85))
                    .frame(width: 12, height: 12)
                if isCurrent {
                    RoundedRectangle(cornerRadius: 1.5)
                        .strokeBorder(color, lineWidth: 1.5)
                        .frame(width: 12, height: 12)
                }
            }
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private func weeksGridFitted(in size: CGSize) -> some View {
        let yearLabelWidth: CGFloat = 18
        let yearLabelPad: CGFloat = 3
        let years = member.lifeExpectancy
        let weeksPerYear = 52
        let cellSpacing: CGFloat = 1

        // Compute cell size so the grid exactly fills the available space
        let availW = size.width - yearLabelWidth - yearLabelPad
        let cellW = (availW - CGFloat(weeksPerYear - 1) * cellSpacing) / CGFloat(weeksPerYear)
        let cellH = (size.height - CGFloat(years - 1) * cellSpacing) / CGFloat(years)
        // Use the smaller dimension for square cells; don't allow it to shrink below 1.5pt
        let cellSize = max(1.5, min(cellW, cellH))

        return VStack(alignment: .leading, spacing: cellSpacing) {
            ForEach(0..<years, id: \.self) { year in
                HStack(spacing: 0) {
                    // Constrain label to cellSize height so it never inflates the row
                    Text(year % 5 == 0 ? "\(year)" : "")
                        .font(.system(size: min(6, cellSize * 0.95), weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: yearLabelWidth, height: cellSize, alignment: .trailing)
                        .clipped()
                        .padding(.trailing, yearLabelPad)

                    HStack(spacing: cellSpacing) {
                        ForEach(0..<weeksPerYear, id: \.self) { week in
                            weekBox(weekIndex: year * weeksPerYear + week, cellSize: cellSize)
                        }
                    }
                }
                .frame(height: cellSize)  // pin each row to exactly cellSize — prevents text from inflating rows
            }
        }
    }

    private func weekBox(weekIndex: Int, cellSize: CGFloat) -> some View {
        let isLived = weekIndex < currentWeekIndex
        let isCurrent = weekIndex == currentWeekIndex

        return RoundedRectangle(cornerRadius: max(0.5, cellSize * 0.2))
            .fill(isLived ? colors[0].opacity(0.82) : (isCurrent ? colors[0].opacity(0.25) : Color(.systemGray3)))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                isCurrent
                    ? RoundedRectangle(cornerRadius: max(0.5, cellSize * 0.2))
                        .strokeBorder(colors[0], lineWidth: max(0.5, cellSize * 0.25))
                    : nil
            )
    }

    private var footerNote: some View {
        Text("Each row is one year · Each box is one week · \(member.lifeExpectancy) yr life expectancy")
            .font(.system(size: 10, design: .rounded))
            .foregroundColor(Color(.tertiaryLabel))
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
}
