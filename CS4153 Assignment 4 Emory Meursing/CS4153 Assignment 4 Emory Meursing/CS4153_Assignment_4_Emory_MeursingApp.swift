//
//  CS4153_Assignment_4_Emory_MeursingApp.swift
//  CS4153 Assignment 4 Emory Meursing
//
//  Created by Sarah Luster on 4/7/25.
//

import SwiftUI

@main
struct BookSearchApp: App {
    @StateObject var searchViewModel = SearchViewModel()
    @StateObject var favoritesViewModel = FavoritesViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                SearchView(viewModel: searchViewModel, favoritesViewModel: favoritesViewModel)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                FavoritesView(viewModel: favoritesViewModel)
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }
            }
        }
    }
}
