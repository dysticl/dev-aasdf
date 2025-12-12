import SwiftUI

struct LiquidGlassView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Globaler Hintergrund
            AmbientGlowBackground()
            
            // 2. Hauptinhalt
            TabView(selection: $selectedTab) {
                ModernHomeView()
                    .tag(0)
                
                ModernProfileView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            
            // 3. Floating Glass Tab Bar
            ModernTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 20)
        }
        .preferredColorScheme(.dark)
    }
}

struct ModernHomeView: View {
    // State für API-Daten
    @State private var currentStreak: Int = 0
    @State private var isLoadingStreak = false
    @State private var streakError: String?
    
    // Dynamisches Abrufen der User-ID aus den UserDefaults
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "user_id") 
            ?? UserDefaults.standard.string(forKey: "userId")
            ?? UserDefaults.standard.string(forKey: "current_user_id")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Apple-Style Large Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date().formatted(date: .complete, time: .omitted).uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Übersicht")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 60)
                
                // Stats Row
                HStack(spacing: 12) {
                    HunterStatBadge(title: "Level", value: "42", icon: "arrow.up.circle.fill", color: .yellow)
                    
                    // Daystrike Integration: Zeigt Ladezustand oder echten Wert
                    HunterStatBadge(
                        title: "Streak", 
                        value: isLoadingStreak ? "..." : "\(currentStreak)", 
                        icon: "flame.fill", 
                        color: .red
                    )
                    
                    HunterStatBadge(title: "XP", value: "85%", icon: "bolt.fill", color: .blue)
                }
                
                // Fehlermeldung bei API-Problemen
                if let error = streakError {
                    Text("Konnte Streak nicht laden: \(error)")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                // Glass Container für Missionen
                VStack(alignment: .leading, spacing: 16) {
                    Text("Missionen")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    
                    // Verwendung des "GlassEffectContainer" wie in der Doku
                    GlassEffectContainer(spacing: 0) {
                        MissionRow(title: "Schatten-Extraktion", subtitle: "Täglich • 100 XP", isLast: false)
                        MissionRow(title: "Dungeon Raid", subtitle: "Wöchentlich • 500 XP", isLast: false)
                        MissionRow(title: "Training", subtitle: "Optional • 50 XP", isLast: true)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        // Daten beim Start laden (GET Request für Streak)
        .onAppear {
            loadStreakData()
        }
        // Pull-to-Refresh Unterstützung
        .refreshable {
            loadStreakData()
        }
    }
    
    func loadStreakData() {
        guard let userId = currentUserId else {
            self.streakError = "Nicht eingeloggt"
            return
        }
        
        isLoadingStreak = true
        streakError = nil
        
        // Verwende GET /current für Dashboard-Anzeige
        DaystrikeService.shared.fetchCurrentStreak(userId: userId) { result in
            DispatchQueue.main.async {
                isLoadingStreak = false
                switch result {
                case .success(let streak):
                    self.currentStreak = streak
                case .failure(let error):
                    self.streakError = error.localizedDescription
                }
            }
        }
    }
}

struct ModernProfileView: View {
    // State für Streak im Profil
    @State private var currentStreak: Int = 0
    
    // Dynamisches Abrufen der User-ID
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "user_id") 
            ?? UserDefaults.standard.string(forKey: "userId")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.white, .white.opacity(0.3))
                        .shadow(radius: 20)
                    
                    VStack(spacing: 4) {
                        Text("Sung Jin-Woo")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text("S-Rank Hunter")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .glassEffect(material: .ultraThinMaterial, radius: 100)
                    }
                }
                .padding(.top, 60)
                
                // Attribute Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Attribute")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // NEU: Daystrike Anzeige auch hier
                        StatDetailCard(label: "Daystrike", value: "\(currentStreak)", color: .red)
                        
                        StatDetailCard(label: "Stärke", value: "98", color: .red)
                        StatDetailCard(label: "Intelligenz", value: "124", color: .blue)
                        StatDetailCard(label: "Agilität", value: "110", color: .green)
                        StatDetailCard(label: "Vitalität", value: "95", color: .orange)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            // Lädt den Streak separat, unabhängig vom Leveling-Call
            loadStreakData()
        }
    }
    
    func loadStreakData() {
        guard let userId = currentUserId else { return }
        
        DaystrikeService.shared.fetchCurrentStreak(userId: userId) { result in
            DispatchQueue.main.async {
                if case .success(let streak) = result {
                    self.currentStreak = streak
                }
            }
        }
    }
}

// MARK: - Subcomponents

struct MissionRow: View {
    let title: String
    let subtitle: String
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider().background(.white.opacity(0.1))
            }
        }
    }
}

struct StatDetailCard: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(material: .ultraThinMaterial, radius: 16)
    }
}
