import SwiftUI
import Core

struct AppIconsView: View {
    
    @State var current: AppIcon = .classic
    
    var body: some View {
        List {
            ForEach(AppIcon.allCases, id: \.self) { icon in
                HStack {
                    Image(icon.rawValue, bundle: .settings)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: .py_grid(16),
                            height: .py_grid(16)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: .py_grid(3),
                                style: .continuous
                            )
                    )
                    
                    Text(icon.rawValue)
                        .font(Font
                            .preferred(.py_title3()).lowercaseSmallCaps()
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    
                    if icon == current {
                        Image(systemName: "checkmark")
                            .font(.preferred(.py_headline()))
                    }
                }.background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                )
                .onTapGesture {
                    current = icon
                }
            }
        }.navigationBarTitle(Text("App Icons"))
    }
}

struct AppIconsView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconsView()
            .preferredColorScheme(.dark)
    }
}
