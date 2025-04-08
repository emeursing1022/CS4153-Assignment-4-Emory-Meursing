//
//  ContentView.swift
//  CS4153 Assignment 4 Emory Meursing
//
//  Created by Sarah Luster on 4/7/25.
//

import SwiftUI
import Foundation
import Combine
import CoreData

struct Book: Identifiable, Codable {
    var id: String
    var title: String
    var authors: [String]
    var publisher: String
    var coverImageUrl: String
    var description: String?

    // Create an initializer for easy mapping from the API response.
    init(id: String, title: String, authors: [String], publisher: String, coverImageUrl: String, description: String?) {
        self.id = id
        self.title = title
        self.authors = authors
        self.publisher = publisher
        self.coverImageUrl = coverImageUrl
        self.description = description
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"

    func fetchBooks(query: String, completion: @escaping (Result<[Book], Error>) -> Void) {
        let urlString = "\(baseURL)?q=\(query)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                return
            }

            do {
                let result = try JSONDecoder().decode(BookAPIResponse.self, from: data)
                let books = result.items.map { item in
                    Book(id: item.id, title: item.volumeInfo.title, authors: item.volumeInfo.authors ?? [], publisher: item.volumeInfo.publisher ?? "Unknown", coverImageUrl: item.volumeInfo.imageLinks?.thumbnail ?? "", description: item.volumeInfo.description)
                }
                completion(.success(books))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Response structure to decode JSON
struct BookAPIResponse: Codable {
    var items: [BookItem]
}

struct BookItem: Codable {
    var id: String
    var volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    var title: String
    var authors: [String]?
    var publisher: String?
    var imageLinks: ImageLinks?
    var description: String?
}

struct ImageLinks: Codable {
    var thumbnail: String
}

class SearchViewModel: ObservableObject {
    @Published var books = [Book]()
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func searchBooks() {
        guard !searchQuery.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchBooks(query: searchQuery) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let books):
                    self.books = books
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

class FavoritesViewModel: ObservableObject {
    @Published var favoriteBooks: [BookEntity] = []

    private let context = PersistenceController.shared.context

    func fetchFavorites() {
        let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        do {
            favoriteBooks = try context.fetch(request)
        } catch {
            print("Error fetching favorites: \(error)")
        }
    }

    func addFavorite(book: Book) {
        let bookEntity = BookEntity(context: context)
        bookEntity.id = book.id
        bookEntity.title = book.title
        bookEntity.authors = book.authors.joined(separator: ", ")
        bookEntity.publisher = book.publisher
        bookEntity.coverImageUrl = book.coverImageUrl
        bookEntity.bookDescription = book.description

        saveContext()
    }

    func removeFavorite(book: BookEntity) {
        context.delete(book)
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel

    var body: some View {
        VStack {
            TextField("Search books", text: $viewModel.searchQuery, onCommit: {
                viewModel.searchBooks()
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.books) { book in
                    HStack {
                        AsyncImage(url: URL(string: book.coverImageUrl))
                            .frame(width: 50, height: 70)
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .fontWeight(.bold)
                            Text(book.authors.joined(separator: ", "))
                            Text(book.publisher)
                        }
                        Spacer()
                        Button(action: {
                            favoritesViewModel.addFavorite(book: book)
                        }) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        List {
            ForEach(viewModel.favoriteBooks, id: \.id) { bookEntity in
                HStack {
                    Text(bookEntity.title ?? "")
                    Spacer()
                    Button(action: {
                        viewModel.removeFavorite(book: bookEntity)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchFavorites()
        }
    }
}

class PersistenceController {
    static let shared = PersistenceController()  // Singleton instance

    let persistentContainer: NSPersistentContainer

    // Private initializer ensures only one instance is created
    private init() {
        persistentContainer = NSPersistentContainer(name: "BookModel") // Replace with your actual model name
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)") // Handle error appropriately
            }
        }
    }

    // Access the context using this property
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
