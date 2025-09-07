//
//  Tab.swift
//  safari tabs layout
//
//  Created by Assistant
//

import SwiftUI

struct Tab: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var url: String
    var favicon: String
    var isPrivate: Bool = false
    var backgroundImageName: String?
    var rupeeAmount: Int
    
    init(title: String, url: String, favicon: String, isPrivate: Bool = false, backgroundImageName: String? = nil) {
        self.title = title
        self.url = url
        self.favicon = favicon
        self.isPrivate = isPrivate
        self.backgroundImageName = backgroundImageName
        // Generate random amount between Rs.10,000 to Rs.99,999
        self.rupeeAmount = Int.random(in: 10000...99999)
    }
    
    var backgroundColor: Color {
        switch url {
        case "https://finance.yahoo.com":
            return Color.purple
        case "https://osxdaily.com":
            return Color.blue
        case "https://9to5mac.com":
            return Color.green
        case "https://apple.com":
            return Color.orange
        case "https://google.com":
            return Color.red
        case "https://github.com":
            return Color.indigo
        case "https://stackoverflow.com":
            return Color.teal
        case "https://developer.apple.com":
            return Color.pink
        case "https://swift.org":
            return Color.mint
        case "https://xcode.com":
            return Color.cyan
        default:
            return Color.gray
        }
    }
    
    var backgroundImage: String? {
        switch url {
        case "https://finance.yahoo.com":
            return "1"
        case "https://osxdaily.com":
            return "2"
        case "https://9to5mac.com":
            return "3"
        case "https://apple.com":
            return "4"
        case "https://google.com":
            return "5"
        case "https://github.com":
            return "6"
        case "https://stackoverflow.com":
            return "7"
        case "https://developer.apple.com":
            return "1" // Reuse first image
        case "https://swift.org":
            return "2" // Reuse second image
        case "https://xcode.com":
            return "3" // Reuse third image
        case "https://reddit.com":
            return "4" // Reuse fourth image
        case "https://twitter.com":
            return "5" // Reuse fifth image
        case "https://youtube.com":
            return "6" // Reuse sixth image
        case "https://netflix.com":
            return "7" // Reuse seventh image
        default:
            return "1" // Default to first image
        }
    }
}

// Sample data matching the image
extension Tab {
    static let sampleTabs = [
        Tab(
            title: "Summary for Vanguard Windsor Fund - Yah...",
            url: "https://finance.yahoo.com",
            favicon: "🌐"
        ),
        Tab(
            title: "How to Increase All System Font Size in Mac OS X...",
            url: "https://osxdaily.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Quick Screen Sharing from Terminal is Suddenly...",
            url: "https://9to5mac.com",
            favicon: "🌐"
        ),
        Tab(
            title: "iPhone Screen Turned Black and Stopped Working?",
            url: "https://apple.com",
            favicon: "🌐"
        ),
        Tab(
            title: "The Threat Remains - Dragon Age Inquisition Walkthrough Part 1 Opening...",
            url: "https://google.com",
            favicon: "🌐"
        ),
        Tab(
            title: "GitHub - Where the world builds software",
            url: "https://github.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Stack Overflow - Where Developers Learn",
            url: "https://stackoverflow.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Apple Developer Documentation",
            url: "https://developer.apple.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Swift Programming Language",
            url: "https://swift.org",
            favicon: "🌐"
        ),
        Tab(
            title: "Xcode - Apple Developer",
            url: "https://xcode.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Reddit - The Front Page of the Internet",
            url: "https://reddit.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Twitter - What's happening?",
            url: "https://twitter.com",
            favicon: "🌐"
        ),
        Tab(
            title: "YouTube - Watch, Listen, Stream",
            url: "https://youtube.com",
            favicon: "🌐"
        ),
        Tab(
            title: "Netflix - Watch TV Shows Online",
            url: "https://netflix.com",
            favicon: "🌐"
        )
    ]
}
