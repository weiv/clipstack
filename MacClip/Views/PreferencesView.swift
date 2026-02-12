import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferences = PreferencesManager.shared

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at Login", isOn: $preferences.launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
        .padding()
    }
}

#Preview {
    PreferencesView()
}
