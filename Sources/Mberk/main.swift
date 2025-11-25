import Foundation
import HighlightJSPublishPlugin
import Plot
import Publish

// This type acts as the configuration for your website.
struct Mberk: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case projects
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://mberk.com")!
    var name = "Michael Berk"
    var description = "Michael Berk's website"
    var language: Language { .english }
    var imagePath: Path? { "images/favicon.png" }
    var favicon: Favicon? = .init(path: "images/favicon.png", type: "image/png")
}

// This will generate your website using the built-in Foundation theme:
let mberk = Mberk()
try mberk.publish(using: [
    .installPlugin(.highlightJS()),
    .copyResources(),
    .addMarkdownFiles(),
    .copyFile(at: "Content/donate.html"),
    .addPage(aboutPage(site: mberk)),
    .generateHTML(withTheme: .mberk),
    // .step(named: "Fix RSS") { context in
    //     context.sections[.posts].mutateItems(using: { item in
            // let newString = "src=\"\(context.site.url(for: item))"
    //         item.body.html = item.body.html.replacingOccurrences(of: #"src=\""#, with: newString)
    //     })
    // },
    
    .generateRSSFeed(including: [.posts]),
    .generateSiteMap(),
    // .step(named: "fix") {context in 
    //     let file = try context.file(at: "feed.rss")
    //     let feed = try file.readAsString()

    // },
    .deploy(using: .gitHub("MichaelJBerk/MberkWebsite2")),
])
