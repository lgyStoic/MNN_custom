//
//  ModelClient.swift
//  MNNLLMiOS
//
//  Created by 游薪渝(揽清) on 2025/1/3.
//

import Hub
import Foundation

class ModelClient {
    private let baseURL = "https://hf-mirror.com"
    private let maxRetries = 3
    
    init() {}
    
    func getModelList() async throws -> [ModelInfo] {
        let url = URL(string: "\(baseURL)/api/models?author=taobao-mnn&limit=100")!
        return try await performRequest(url: url, retries: maxRetries)
    }
    
    func getRepoInfo(repoName: String, revision: String) async throws -> RepoInfo {
        let url = URL(string: "\(baseURL)/api/models/\(repoName)")!
        return try await performRequest(url: url, retries: maxRetries)
    }

    @MainActor
    func downloadWithHub(model: ModelInfo,
                         progress: @escaping (Double) -> Void) async throws {
        let repo = Hub.Repo(id: model.modelId)
        let modelFiles = ["*.*"]
        
        let mirrorHubApi = HubApi(endpoint:"https://hf-mirror.com")
        try await mirrorHubApi.snapshot(from: repo, matching: modelFiles) { fileProgress in
            progress(fileProgress.fractionCompleted)
        }
    }
    
    private func performRequest<T: Decodable>(url: URL, retries: Int = 3) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...retries {
            do {
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                if httpResponse.statusCode == 200 {
                    return try JSONDecoder().decode(T.self, from: data)
                }
                
                throw NetworkError.invalidResponse
                
            } catch {
                lastError = error
                if attempt < retries {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
                    continue
                }
            }
        }
        
        throw lastError ?? NetworkError.unknown
    }
}

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case downloadFailed
    case unknown
}
