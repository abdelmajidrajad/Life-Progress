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
