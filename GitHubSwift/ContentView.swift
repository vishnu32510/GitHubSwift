//
//  ContentView.swift
//  GitHubSwift
//
//  Created by Vishnu Priyan Sellam Shanmugavel on 2/20/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")){ image in
                image
                    .resizable()
                    . aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 200,height: 200)
                
            }placeholder: {
                Circle()
                    .foregroundColor(.gray)
                    
            }
            Text(user?.login ?? "")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do{
                user = try await getUser()
            }catch GHError.invalidURL{
                print("Invaliud URL")
                
            }catch GHError.invalidData{
                print("Invalid Data")
            }catch GHError.invalidResponse{
                print("Invalid Response")
            }catch{
                print("Unexpected Error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/vishnu32510"
        guard let url = URL(string: endPoint) else {throw GHError.invalidURL}
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }catch{
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}

struct GitHubUser: Codable{
    let login: String
    let avatarUrl: String
    let bio: String
    
}

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
