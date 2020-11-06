import SwiftUI

struct NightModeView: View {
    
    enum Style: CaseIterable {
        case dark, light
    }
    
    @State var currentStyle: Style = .dark
    
    var body: some View {
        List {
            ForEach(Style.allCases, id: \.self) { style in
                HStack {
                    Image(systemName:
                          style == .dark
                          ? "moon.fill"
                          : "sun.min.fill"
                        )
                        .padding(.py_grid(2))
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius: .py_grid(2),
                                style: .continuous
                            ).fill(
                                style == .dark
                                 ? Color.purple
                                 : .orange
                            )
                        )
                    Text(style == .dark ? "Dark": "Light")
                        .font(Font.preferred(.py_subhead()).bold())
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    
                    if style == currentStyle {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                }.font(Font.preferred(.py_body()))
                .padding(.vertical, .py_grid(3))
                .background(
                    Rectangle().fill(Color(.systemBackground))
                ).onTapGesture {
                    currentStyle = style
                    UIApplication.shared.windows.forEach { window in
                        window.overrideUserInterfaceStyle = style == .dark ? .dark: .light
                    }
                }
            }
        }
    }
}

struct NightModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NightModeView()
            NightModeView()
                .preferredColorScheme(.dark)
        }
    }
}
