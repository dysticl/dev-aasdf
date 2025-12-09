import Foundation

// Datenmodell für POST /daystrikes/check/{user_id}
struct DaystrikeResponse: Codable {
    let userId: String
    let allCompleted: Bool
    let artifactCount: Int
    let completedArtifacts: Int
    let previousStreak: Int
    let newStreak: Int
    let streakUpdated: Bool
    let message: String
    let longestStreak: Int? // Optional, falls vom Backend unterstützt
}

// NEU: Datenmodell für GET /daystrikes/current/{user_id}
struct CurrentStreakResponse: Codable {
    let found: Bool
    let current_streak: Int
    let last_streak_date: String?
}

class DaystrikeService {
    static let shared = DaystrikeService()
    
    // TODO: Ersetzen Sie dies durch Ihre echte API-Base-URL
    private let baseURL = "http://192.168.178.94:8000" 
    
    private init() {}
    
    /// GET /daystrikes/current/{user_id} – Ruft den aktuellen Streak unabhängig vom Leveling ab
    func fetchCurrentStreak(userId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/daystrikes/current/\(userId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CurrentStreakResponse.self, from: data)
                completion(.success(response.current_streak))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    /// POST /daystrikes/check/{user_id} – Überprüft/Aktualisiert den Streak
    func checkStreak(userId: String, completion: @escaping (Result<DaystrikeResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/daystrikes/check/\(userId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(DaystrikeResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
