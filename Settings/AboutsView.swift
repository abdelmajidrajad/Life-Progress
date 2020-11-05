import SwiftUI
import Core

struct AboutsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    private var image: String {
        colorScheme == .dark ? "blue": "classic"
    }
    
    var body: some View {
        VStack {
            
            Text("app description")
                .frame(maxHeight: .infinity)
            
            
            VStack {
                Image(image, bundle: .settings)
                    .resizable()
                    .frame(width: .py_grid(15), height: .py_grid(15))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: .py_grid(4))
                    )
                
                Text("© Life Progress v\(appVersion)")
                    .font(.preferred(.py_callout()))
            }
            
                
            
        }.navigationBarTitle(Text("About"))
                       
    }
}

struct AboutsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutsView()
            AboutsView()
                .preferredColorScheme(.dark)
        }
    }
}
