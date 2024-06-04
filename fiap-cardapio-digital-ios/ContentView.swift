//
//  ContentView.swift
//  fiap-cardapio-digital-ios
//
//  Created by Luiz Lima on 03/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var foods: [FoodResponse] = []
    @State private var newFoodTitle = ""
    @State private var newFoodImage = ""
    @State private var newFoodPrice = ""

    let apiClient = APIClient()

    var body: some View {
        VStack {
            TextField("Title", text: $newFoodTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Image URL", text: $newFoodImage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Price", text: $newFoodPrice)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save") {
                let newFood = FoodRequest(
                    title: newFoodTitle,
                    image: newFoodImage,
                    price: Int(newFoodPrice) ?? 0
                )
                apiClient.saveFood(food: newFood) { result in
                    switch result {
                    case .success(let savedFood):
                        foods.append(savedFood)
                        newFoodTitle = ""
                        newFoodImage = ""
                        newFoodPrice = ""
                    case .failure(let error):
                        print("Error saving food: \(error)")
                    }

                    apiClient.fetchFoods { fetchedFoods, error in
                        if let fetchedFoods = fetchedFoods {
                            self.foods = fetchedFoods
                        } else if let error = error {
                            print("Error fetching foods: \(error)")
                        }
                    }
                }
            }
            .padding()

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
}

#Preview {
    ContentView()
}

struct FoodRequest: Codable {
    let title: String
    let image: String
    let price: Int
}

struct FoodResponse: Codable {
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

    func fetchFoods(completion: @escaping ([FoodResponse]?, Error?) -> Void) {
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
                let foods = try JSONDecoder().decode([FoodResponse].self, from: data)
                completion(foods, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    func saveFood(food: FoodRequest, completion: @escaping (Result<FoodResponse, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8080/food") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(food)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let savedFood = try JSONDecoder().decode(FoodResponse.self, from: data)
                completion(.success(savedFood))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
