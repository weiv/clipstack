import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)

            Text("ClipStack")
                .font(.title.bold())

            Text("Version \(version)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            VStack(spacing: 4) {
                Text("By Vladimir Weinstein")
                    .font(.body)

                Link("weivco.com", destination: URL(string: "https://weivco.com")!)
                    .font(.body)
            }
        }
        .padding(24)
        .frame(width: 260)
    }
}
