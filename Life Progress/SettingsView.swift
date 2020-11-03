import SwiftUI

struct SettingsView: View {
    
    enum SettingItem {
        case appInfo
        case appIcon
        case showSettings
        case nightMode
        case rateUs
        case support
        case notifications
        case about
    }
    
    @State var section: SettingItem? = .none
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                                        
                    //MARK:- Life Progress
                    NavigationLink(
                        destination: Text("Destination"),
                        tag: .appInfo,
                        selection: $section,
                        label: {
                            HStack(spacing: .py_grid(4)) {
                                Image("")
                                    .frame(
                                        width: .py_grid(16),
                                        height: .py_grid(16)
                                    ).background(
                                        RoundedRectangle(
                                            cornerRadius: .py_grid(4),
                                            style: .continuous
                                        )
                                        .fill(Color(white: 0.96))
                                    )
                                
                                VStack(alignment: .leading, spacing: .py_grid(2)) {
                                    Text("Life Progress PLUS".uppercased())
                                        .font(
                                            Font.preferred(
                                                .py_title3())
                                                .bold()
                                                .smallCaps()
                                        )
                                    Text("Progress your tasks")
                                        .font(.preferred(.py_body()))
                                }
                            }.padding(.vertical)
                        }).onTapGesture {
                            self.section = .appInfo
                        }
                                                            
                    //MARK:- App Icon
                    NavigationLink(
                        destination: Text("App Icon"),
                        tag: .appIcon,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "a.circle.fill",
                                    fillColor: .green
                                )
                                Text("App Icon")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .appIcon
                        }
                    
                    //MARK:- Show Settings
                    NavigationLink(
                        destination: Text("Settings"),
                        tag: .showSettings,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "wrench.fill",
                                    fillColor: .gray
                                )
                                Text("Show Settings")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .showSettings
                        }
                }
                
                Section {
                    //MARK:- Night Mode
                    NavigationLink(
                        destination: Text("Night Mode"),
                        tag: .nightMode,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "moon.fill",
                                    fillColor: .purple
                                )
                                Text("Night Mode")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .nightMode
                        }
                    
                    //MARK:- Notifications
                    NavigationLink(
                        destination: Text("Notifications"),
                        tag: .notifications,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "app.badge",
                                    fillColor: .red
                                )
                                Text("Notifications")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .notifications
                        }
                    
                }
                
                
                Section {
                    //MARK:- App Store Rating
                    NavigationLink(
                        destination: Text("App Store Rating"),
                        tag: .rateUs,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "star.fill",
                                    fillColor: .blue
                                )
                                Text("Please Rate on App Store")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .rateUs
                        }
                    
                }
                
                Section {
                    //MARK:- Support
                    NavigationLink(
                        destination: Text("Support"),
                        tag: .support,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "questionmark",
                                    fillColor: .orange
                                )
                                Text("Support")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .support
                        }
                    //MARK:- About
                    NavigationLink(
                        destination: Text("About"),
                        tag: .support,
                        selection: $section,
                        label: {
                            HStack {
                                LeftImage(
                                    systemName: "exclamationmark",
                                    fillColor: .pink
                                )
                                Text("About")
                                    .font(.preferred(.py_body()))
                            }.padding(.vertical, .py_grid(1))
                        }).onTapGesture {
                            self.section = .support
                        }
                    
                    
                    
                }
                
                
                
            }.navigationBarTitle(
                Text("Settings"),
                displayMode: .inline
            ).listStyle(GroupedListStyle())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct LeftImage: View {
    let systemName: String
    let fillColor: Color
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(.white)
            .font(.headline)
            .frame(width: .py_grid(10), height: .py_grid(10))
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(3),
                    style: .continuous
                ).fill(fillColor)
            )
    }
}
