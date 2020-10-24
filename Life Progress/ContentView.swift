import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy -> AnyView in
            let width = proxy.size.width * 0.5 - 8.0
            return AnyView(
                VStack(spacing: 16.0) {
                    
                    HStack(spacing: 8.0) {
                        
                        VStack(alignment: .leading) {
                            Text("2020")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .font(.title)                            
                            HStack(spacing: 2) {
                                Text("280d")
                                    .bold()
                                    .font(.headline)
                                Text(" remaining")
                                    .italic()
                                    .fontWeight(.ultraLight)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                        }.padding()
                        .background(
                            RoundedRectangle(
                                cornerRadius: 20.0,
                                style: .continuous
                            ).fill(Color.white)
                            .shadow(radius: 1)
                        ).frame(
                            width: width,
                            height: width,
                            alignment: .leading
                        )
                            
                        RoundedRectangle(cornerRadius: 20.0,
                                         style: .continuous)
                            .frame(width: width, height: width)
                    }.padding(.leading, 4.0)
                    
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "chart.bar.fill")
                                .font(Font.headline.bold())
                        }).buttonStyle(PlusButtonStyle())
                        
                        Button(action: {}, label: {
                            Image(systemName: "checkmark")
                                .font(Font.headline.bold())
                        }).buttonStyle(PlusButtonStyle())
                        .frame(alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                                .font(Font.headline.bold())
                        }).buttonStyle(PlusButtonStyle())
                        .frame(alignment: .leading)
                        
                    }//.frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    
                    
                    ScrollView {
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Read Zero to One")
                                        .font(.headline)
                                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                }
                                Text("13hours 28minutes")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                            }
                        }.padding()
                        .background(
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(
                                    cornerRadius: 8.0, style: .continuous)
                                    .fill(Color.white)
                                Button(action: {}, label: {
                                    Image(systemName: "ellipsis")
                                        .accentColor(.gray)
                                        .font(Font.headline.bold())
                                }).padding()
                            }
                        ).padding(.horizontal)
                                            
                        ForEach(1..<5) { _ in
                            VStack(alignment: .leading, spacing: 16) {
                                
                                Text("Read Zero to One")
                                    .font(.headline)
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                
                                Text("13hours 28minutes")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                
                            }.padding()
                            .background(
                                ZStack(alignment: .topTrailing) {
                                    RoundedRectangle(
                                        cornerRadius: 8.0, style: .continuous)
                                        .fill(Color.white)
                                    Button(action: {}, label: {
                                        Image(systemName: "ellipsis")
                                            .accentColor(.gray)
                                    }).padding()
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        
                        
                    }
                    
                }.background(Color(white: 0.98).blur(radius: 1.2))
            )
        }
    }
}

struct PlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12.0)
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(Color.white)
                    .shadow(color: Color(white: 0.95), radius: 1)
            )
    }
}

let lineWidth: CGFloat = 8.0
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}



