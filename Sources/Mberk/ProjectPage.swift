import Plot
import Publish

struct Homepage: Component {
    var body: Component {
        Div {
            Projrow(title: "Splitter", info: Paragraph("The Speedrunning Timer for macOS"), imageURL: "images/Splitter-icon.png", imageDescription: "Icon for Splitter app", projectLink: "https://splitter.mberk.com")

            Projrow(title: "Siddur + Tehillim Anywhere", info: Text("The Jewish prayer book, on your iPhone or iPad.").addLineBreak() + Text("Includes Nusach Ashkenaz, Sefard, and Edot HaMizrach"), imageURL: "images/Siddur-icon.png", imageDescription: "Icon for Siddur app", projectLink: "https://apps.apple.com/us/app/siddur-tehilim-anywhere/id1455032858")

            Projrow(title: "BlueBed", info: Paragraph("Disconnect a Bluetooth device when your Mac sleeps. Reconnect when it wakes"), imageURL: "images/BlueBed-icon.png", imageDescription: "Icon for BlueBed app", projectLink: "https://apps.apple.com/us/app/bluebed/id6484504503?mt=12")

            Projrow(title: "Zmanim", info: Paragraph("Keep track of Zmanim on iPhone and iPad"), imageURL: "images/Zmanim-icon.png", imageDescription: "Icon for Zmanim app", projectLink: "https://apps.apple.com/us/app/zmanim/id1534265457")
        }
        .class("projlist")
    }
}

private struct Projrow: Component {
    var title: String
    var info: Component
    var imageURL: URLRepresentable
    var imageDescription: String
    var projectLink: URLRepresentable
    var body: Component {
        Div {
            Div {
                titleComp
            }
            .class("smallWidth-proj-title")
            Div {
                Link(url: projectLink) {
                    Image(url: Path(imageURL.description).absoluteString, description: imageDescription)
                }
            }
            .class("projrow-image")
            Div {
                titleComp
                    .class("fullWidth-proj-title")
                info
            }
            .class("projrow-text")
        }
        .class("projrow")
    }

    private var titleComp: Component {
        Link(url: projectLink) {
            Paragraph(title)
                .class("project-title")
        }
    }
}