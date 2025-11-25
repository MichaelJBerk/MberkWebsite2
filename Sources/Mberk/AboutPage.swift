import Foundation
import Plot
import Publish

let df: DateFormatter = {
    let d = DateFormatter()
    d.dateStyle = .short
    d.timeStyle = .none
    return d
}()

let aboutDate = df.date(from: "2/6/23")!

func aboutPage(site: Mberk) -> Page {
    Page(path: "about", content: .init(title: "About", description: "", body: .init { AboutComp(site: site) }, date: aboutDate, lastModified: aboutDate))
}

struct AboutComp: Component {
    var site: Mberk

    var body: Component {
        Div {
            H1("About")
            Div {
                Image(url: Path("../favicon.jpeg").absoluteString, description: "")
                    .style("display: Block")
            }
            Paragraph("Hello! I'm Michael Berk. I've been developing apps for iOS and macOS for years ")
        }
    }
}
