Arbeite im Projekt `/Users/daniel/Projekte/AASDF/ios-app` (Xcode/SwiftUI Projekt für AASDF).

ZIEL:
- Das bestehende Status/Progress-Tab erweitern, so dass der User dort das komplette Reward-System sieht:
  - XP/Level/Progress (Bereits vorhanden)
  - Wish-Pool (Rewards) mit Status (Locked/Unlockable/Cooldown)
  - Claim-Flow mit Satisfaction-Slider und Backend-Anbindung an das neue Reward-Backend.

WICHTIG:
- Analysiere zuerst die bestehende Projektstruktur:
  - Finde den bestehenden Status-Tab / StatusView (z.B. `StatusView`, `ProgressView`, `DashboardView` oder ähnliches).
  - Finde die zentrale BASEURL/Backend-Konfiguration (z.B. `BASEURL`, `ApiConfig`, `NetworkClient`).
- Verwende die existierende BASEURL-Konstante, die du im Code findest, für alle neuen API-Calls.
- Verwende bestehende Architektur-Patterns (State-Management, Services, ViewModels), KEIN kompletter Rewrite.

BACKEND:
- Das FastAPI-Backend für das Reward-System läuft lokal.
- Bevor du Models und Requests definierst, öffne die FastAPI-Dokumentation unter:
  - `http://localhost:8000/docs`
- Nutze die OpenAPI-Beschreibung dort, um:
  - die genauen Pfade, HTTP-Methoden und Query-/Path-Parameter für:
    - `POST /api/v1/reward-engine/activity-completed`
    - `POST /api/v1/reward-engine/rewards/{wish_id}/claim`
    - `POST /api/v1/reward-engine/activity-missed`
    - `GET  /api/v1/wishes` (und weitere relevante Endpoints)
    korrekt abzulesen,
  - die exakten JSON-Request- und Response-Schemas zu sehen
    (Feldnamen, Typen, optional/required).
- Erstelle deine Swift `Codable`-Modelle strikt anhand der JSON-Schemas aus `http://localhost:8000/docs`, damit das Parsen im Frontend 1:1 mit dem Backend übereinstimmt.

DESIGN-VORGABEN:
- iOS 26 „Liquid Glass“ Design:
  - Verwende Glassmorphism: halb-transparente Cards mit Blur (z.B. `.background(.ultraThinMaterial)`), sanfte Schatten und Glow-Effekte.
  - Kein Overload: Nur wichtige Bereiche wie Status-Header, Reward-Cards und Bottom-Bar im Glass-Stil halten.
- Farbwelt: „Solo Leveling“-Vibes
  - Primärfarben: dunkles Blau, tiefes Violett, fast schwarzer Hintergrund (#050510–#050812 Range).
  - Akzente: neon-bläuliches Licht, lilane Glows bei wichtigen Buttons und Unlockable-Rewards.
  - Text: überwiegend hell (Weiß/hellgrau) mit hoher Lesbarkeit.
- Style:
  - XP/Level-Balken als horizontale „Mana-Bar“ mit sanftem Glow.
  - Unlockable-Wishes heben sich deutlich mit Glow/Outer Shadow und kräftigem Farbgradienten (Blau → Violett) ab.
  - Cooldowns als kleine, halb-transparente Timer-Overlays.

IMPLEMENTIEREN:

1. Analysephase
   - Durchsuche das Projekt nach:
     - `StatusView`, `ProgressView`, `Dashboard`, `TabView`, `StatusTab`, etc.
     - `BASEURL`, `ApiClient`, `NetworkManager`, `Environment`, `Config`.
   - Entscheide dich für den existierenden Status-Tab als Haupt-Einstiegspunkt für das Reward-System (KEIN neuer Tab, sondern Integration in die bestehende Status-Seite).

2. Models & Networking
   - Erstelle oder erweitere Swift-Modelle (`Codable`) für:
     - `RewardWish` (Mapping auf WISH_POOL/Wish-Schema)
     - `RewardClaimResponse` (Mapping auf Reward-Engine-Claim-Response)
     - `UserStatsSnapshot` (Level, xpCurrent, xpToNextLevel)
     - Optional: `SystemStatus` (Circuit Breaker, Penalty-Level, ML-Trend)
   - Implementiere einen `RewardApiService` (oder erweitere bestehenden API-Client), der:
     - `fetchWishes()`
     - `postActivityCompleted(...)`
     - `claimReward(wishId:satisfaction:...)`
     - `postActivityMissed(...)`
   - Nutze die gefundene BASEURL-Konstante, KEINE Hardcodes.

3. ViewModels
   - Erstelle ein `RewardDashboardViewModel` oder erweitere das bestehende Status-ViewModel:
     - Lädt:
       - aktuelle UserStats (XP, Level)
       - aktuelle Wishes (inkl. Unlockable-Status)
       - optional System-Status (Circuit Breaker/Recovery)
     - Bietet Aktionen:
       - `refreshStatus()`
       - `claim(wish: RewardWish, satisfaction: Int)`
   - State-Management: Nutze das vorgefundene Pattern (z.B. `@StateObject`, `ObservableObject`, `EnvironmentObject`), passe dich der bestehenden Architektur an.

4. UI-Integration im Status-Tab
   - Im bestehenden Status-/Dashboard-View:
     - Füge einen neuen Bereich „Rewards“ hinzu:
       - Oben: XP/Level-Header (bereits vorhanden, aber auf Solo-Leveling/Liquid-Glass-Style anpassen).
       - Darunter: horizontale oder grid-basierte Liste der Wishes:
         - Locked: ausgegraute Glass-Cards mit Schloss-Icon.
         - Unlockable: leuchtende Cards mit „Claim“-Button.
         - Cooldown: halbtransparente Cards mit Timer-Overlay.
   - Implementiere einen Claim-Sheet/Modal:
     - Wird über `sheet` oder `fullScreenCover` angezeigt, sobald ein Unlockable-Wish angetippt wird.
     - Zeigt Kosten (XP), Dopamin-Potential (optional) und einen Satisfaction-Slider (0–10).
     - „Confirm Claim“-Button ruft `claimReward` beim Backend auf und schließt bei Erfolg das Sheet.
     - Nach Erfolg: animiere XP-Balken-Update und ändere visuell den Wish-Status auf Cooldown.

5. Styling/Design
   - Definiere ein kleines Design-System:
     - `RewardColors` (z.B. `backgroundDark`, `accentBlue`, `accentViolet`, `glassOverlay`).
     - `RewardGlassCardStyle`: ein ViewModifier oder eine Hilfsfunktion, die:
       - `background(.ultraThinMaterial)`
       - `cornerRadius(20)`
       - `shadow(color: accentViolet.opacity(0.4), radius: 20, x: 0, y: 10)`
     - Wiederverwende diese Styles für Status-Header, Wish-Cards und Buttons.
   - Achte auf gute Lesbarkeit (Kontrast!), trotz Glass/Glow.

6. Testing / Cleanup
   - Stelle sicher, dass:
     - die App ohne Backend erreichbar bleibt (z.B. durch Loading-State oder Fehleranzeigen).
     - API-Fehler elegant gehandhabt werden (z.B. Banner-Fehler oben im Status-Tab).
   - Nutze Previews, um die neuen Views (Status + Rewards) in Xcode zu visualisieren.

WICHTIG:
- Nichts am bestehenden Tab-Routing oder an anderen Tabs zerstören.
- Keine bestehende XP-/Status-Logik entfernen, nur erweitern.
- Schreibe klar kommentierten, gut strukturierten SwiftUI-Code, der sich in die bestehende Architektur einfügt.
