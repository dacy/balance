import SwiftUI

struct FamilyMemberCard: View {
    let member: FamilyMember

    private var colors: [Color] { member.relationship.cardColors }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(member.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(member.relationship.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(member.emoji)
                        .font(.system(size: 38))
                    Text("Age \(member.ageInYears)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 16)

            LifeProgressBar(fraction: member.lifeFractionElapsed, colors: colors)
                .padding(.bottom, 18)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(member.remainingMoments)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text("estimated \(member.remainingMomentsLabel)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.primary.opacity(0.3))
                    .padding(.bottom, 6)
            }
        }
        .padding(22)
        .background(
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(22)
        .shadow(color: colors[0].opacity(0.45), radius: 14, x: 0, y: 7)
    }
}

struct LifeProgressBar: View {
    let fraction: Double
    let colors: [Color]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.18))
                    .frame(height: 10)
                Capsule()
                    .fill(Color.white.opacity(0.92))
                    .frame(width: max(10, geo.size.width * fraction), height: 10)
            }
        }
        .frame(height: 10)
    }
}
