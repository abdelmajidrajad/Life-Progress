import SwiftUI
import Core

struct CountryLife: Identifiable {
    var id: Int
    let country: String
    let overall: Double
    let female: Double
    let male: Double
    
}


let countryId = Parser
    .prefix("| ")
    .take(Parser.int)
    .skip("\n")
    .map { $1 }

let countryName = Parser
    .prefix("| ")
    .skip("{{flag|")
    .take(Parser.prefix(upTo: "}}"))
    .map { $1 }
    .map(String.init)
    
  
let lifeValue = Parser
    .prefix("| ")
    .take(Parser.double)
    .map { $1 }

let countryParser = zip(
    countryId,
    countryName.skip("}}\n"),
    lifeValue.skip("\n"),
    lifeValue.skip("\n"),
    lifeValue.skip("\n")
).map(CountryLife.init(id:country:overall:female:male:))

func flag(country:String) -> String {
    let base = 127397
    var usv = String.UnicodeScalarView()
    for i in country.utf16 {
        usv.append(UnicodeScalar(base + Int(i))!)
    }
    return String(usv)
}

let numberFormatter: () -> NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.allowsFloats = true
    formatter.numberStyle = .decimal
    return formatter
}

struct LifeProgressView: View {
    @State var countries: [CountryLife] = []
    var body: some View {
        List {
            
            RoundedRectangle(cornerRadius: .py_grid(5))
            
            ForEach(countries) { life in
                VStack {
                    Text(
                        flag(country:
                                countryCodes[
                                    life.country
                                ] ?? ""
                        )
                    ).font(.title)
                    Text("Male ") + 
                    Text(NSNumber(value: life.male), formatter: numberFormatter())
                    Text("female \(life.female)")
                    Text("overall \(life.overall)")
                }
            }
        }.onAppear {
            
            guard let fileURL = Bundle.component
                    .url(forResource: "life_average", withExtension: nil),
                  let countries = try? String(contentsOf: fileURL)
            else { return }
            
            self.countries = countryParser
                .zeroOrMore(separatedBy: "|-\n")
                .run(countries).match ?? []
            
            
            
        }
    }
}

struct LifeProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LifeProgressView()
    }
}
