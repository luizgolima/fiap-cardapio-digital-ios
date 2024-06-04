//
//  ContentView.swift
//  fiap-cardapio-digital-ios
//
//  Created by Luiz Lima on 03/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var foods: [Food] = []
    let apiClient = APIClient()

    var body: some View {
        List(foods, id: \.id) { food in
            HStack {
                AsyncImage(url: URL(string: food.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    @unknown default:
                        EmptyView()
                    }
                }

                VStack(alignment: .leading) {
                    Text(food.title)
                        .font(.headline)
                    Text("Price: \(food.price)")
                        .font(.subheadline)
                }
            }
        }
        .onAppear {
            apiClient.fetchFoods { fetchedFoods, error in
                if let fetchedFoods = fetchedFoods {
                    self.foods = fetchedFoods
                } else if let error = error {
                    print("Error fetching foods: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

struct Food: Codable {
    let id: Int
    let title: String
    let image: String
    let price: Int
}

class APIClient {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }

    func fetchFoods(completion: @escaping ([Food]?, Error?) -> Void) {
        guard let url = URL(string: "http://localhost:8080/food") else {
            completion(nil, URLError(.badURL))
            return
        }

        session.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let foods = try JSONDecoder().decode([Food].self, from: data)
                completion(foods, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
