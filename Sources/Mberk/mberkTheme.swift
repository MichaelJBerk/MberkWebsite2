import Foundation
import Plot
import Publish

extension Theme where Site == Mberk {
    static var mberk: Self {
        print(FileManager.default.currentDirectoryPath)
        return Theme(htmlFactory: MberkHTMLFactory(),
                     resourcePaths: ["styles.css", "hl.css"])
    }
}

struct MBerkPage: Component {
    var context: Publish.PublishingContext<Mberk>
    var selectedSectionID: Mberk.SectionID?
    @ComponentBuilder var pageContents: () -> Component

    var body: Component {
        Div {
            SiteHeader(context: context, selectedSelectionID: selectedSectionID)
            pageContents()
            SiteFooter()
        }.class("page")
    }
}

private struct MberkHTMLFactory: HTMLFactory {
    func makeProjectsHTML(context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .lang(context.site.language),
            .head(for: context.sections[.projects], on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: .projects) {
                    Div {
                        H2("Projects")
                        Homepage()
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makeIndexHTML(for index: Publish.Index, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        let posts = context.sections[.posts]
        return try makeSectionHTML(for: posts, context: context)
    }

    func makeSectionHTML(for section: Publish.Section<Mberk>, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        if section.id == .projects {
            return try makeProjectsHTML(context: context)
        }

        return HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: section.id) {
                    Wrapper {
                        ItemList(items: section.items, site: context.site)
                    }
                }
            }
        )
    }

    func dateString(from date: Date) -> String {
        let formatted = date.formatted(.dateTime
            .hour(.twoDigits(amPM: .abbreviated))
            .minute()
            .day()
            .month()
            .year())
        return String(formatted)
    }

    func makeItemHTML(for item: Publish.Item<Mberk>, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site, stylesheetPaths: ["styles.css", "hl.css"]),
            .body {
                MBerkPage(context: context, selectedSectionID: .posts) {
                    Div {
                        Article {
                            H1(item.content.title)
                            Paragraph("Published: \(dateString(from: item.content.date))")
                                .class("contentDate")
                            Paragraph("Updated: \(dateString(from: item.content.lastModified))")
                                .class("contentDate")
                                Div()
                                .class("divider")
                            // .class("modifiedDate")
                            item.content.body
                        }
                        .class("content")
                        ItemTagList(tags: item.tags, site: context.site)
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makePageHTML(for page: Publish.Page, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                MBerkPage(context: context) {
                    Div {
                        page.content.body
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makeTagListHTML(for page: Publish.TagListPage, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: .posts) {
                    Div {
                        // H1("Browse all tags")
                        ItemTagList(tags: page.tags.sorted(), site: context.site)
                            .class("all-tags")
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makeTagDetailsHTML(for page: Publish.TagDetailsPage, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: .posts) {
                    Wrapper {
                        H3 {
                            Text("Tagged with ")
                            Span(page.tag.string).class("tag")
                        }

                        Link("Browse all tags",
                             url: context.site.tagListPath.absoluteString)
                            .class("allTagsButton")

                        ItemList(
                            items: context.items(
                                taggedWith: page.tag,
                                sortedBy: \.date,
                                order: .descending
                            ),
                            site: context.site
                        )
                    }
                }
            }
        )
    }
}

private struct ItemList: Component {
    var items: [Item<Mberk>]
    var site: Mberk

    var body: Component {
        List(items) { item in
            Div {
                H3(Link(item.title, url: item.path.absoluteString))
                ItemTagList(tags: item.tags, site: site)
                Paragraph(item.description)
            }
            .class("main-card")
        }
        .class("item-list")
    }
}

private struct ItemTagList: Component {
    var tags: [Tag]
    var site: Mberk

    var body: Component {
        Div {
            Div {
                Text("Tags:")
            }
            for tag in tags {
                Div {
                    Link(tag.string, url: site.path(for: tag).absoluteString)
                }
                .class("tag")
            }
        }.class("tag-list-container")
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader: Component {
    var context: PublishingContext<Mberk>
    var selectedSelectionID: Mberk.SectionID?

    var body: Component {
        Header {
            Div {
                Div {
                    Link(context.site.name, url: "/")
                }
                .class("head-title")
                navigation
            }
            .class("head")
        }
    }

    func navLink(title: String, url: URLRepresentable, sectionID: Mberk.SectionID?, linkTarget: HTMLAnchorTarget? = nil) -> Component {
        Div {
            Link(title, url: url)
                .linkTarget(linkTarget)
                .class("nav-item")
                .class(sectionID != nil && sectionID == selectedSelectionID ? "selected" : "")
        }
        .class("nav-item-box")
    }

    private var navigation: Component {
        Div {
            navLink(title: "Posts", url: context.sections[.posts].path.absoluteString, sectionID: .posts)
            navLink(title: "Projects", url: context.sections[.projects].path.absoluteString, sectionID: .projects)
            navLink(title: "Tip Jar", url: "https://donate.stripe.com/4gw3dT31RgDf4la9AA", sectionID: nil, linkTarget: .blank)
                .class("tipJar")
        }
        .class("head-nav")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("Generated using ")
                Link("Publish", url: "https://github.com/johnsundell/publish")
            }
            Paragraph {
                Link("RSS feed", url: "/feed.rss")
            }
            Paragraph {
                Text("Support Email: MichaelBerkDev[at]gmail.com")
            }
        }
    }
}
