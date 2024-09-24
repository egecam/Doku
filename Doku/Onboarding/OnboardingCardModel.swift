//
//  OnboardingCardModel.swift
//  Doku
//
//  Created by Ege Çam on 7.09.2024.
//

import Foundation

struct OnboardingCardModel: Identifiable {
    var id: Int
    var title: String
    var headline: String
    var media: String?
    var buttonTitle: String
}

let onboardingCardData: [OnboardingCardModel] = [
    OnboardingCardModel(id: 0, title: "Welcome to Doku", headline: "The feed controlled by you", media: nil, buttonTitle: "Next"),
    OnboardingCardModel(id: 1, title: "Your First Step", headline: "Let's add something into your Doku. First, open your web browser and long tap on a link or passage.", buttonTitle: "Next"),
    OnboardingCardModel(id: 2, title: "Share with Doku", headline: "After selection, tap to share and choose Doku as your target. Adding something to your Doku is simple as that!", buttonTitle: "Next"),
    OnboardingCardModel(id: 3, title: "Tags and All That Stuff", headline: "You may want to attach some tags or a custom title to your Doku.", buttonTitle: "Next"),
    OnboardingCardModel(id: 4, title: "Filter, Search, Favourite", headline: "Now you may want to wander around in your Doku using favourites, tag filtering and search bar.", buttonTitle: "Next"),
    OnboardingCardModel(id: 5, title: "All Set", headline: "You are ready to go!", buttonTitle: "Start")
]
