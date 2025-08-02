# 🏎️ Roblox Auto-Rennspiel - Installationsanleitung

## 📋 Übersicht
Dieses Projekt ist ein vollständiges Multiplayer-Rennspiel für Roblox mit:
- **Mehrere Autos** zur Auswahl mit verschiedenen Eigenschaften
- **Blasen-Effekte** an den Händen der Spieler
- **Multiplayer-Racing** mit bis zu 8 Spielern
- **Automatische Rennstrecke** mit Checkpoints
- **Echtzeit-Leaderboard**

## 🚀 Installation in Roblox Studio

### Schritt 1: Neues Projekt erstellen
1. Öffne **Roblox Studio**
2. Erstelle ein neues **Baseplate** Project
3. Speichere es als "RaceGame" oder ähnlich

### Schritt 2: Scripts hinzufügen

#### Server Scripts (ServerScriptService):
1. Erstelle ein **Script** namens "Events" → Kopiere den Inhalt von `src/shared/Events.lua`
2. Erstelle ein **ModuleScript** namens "Config" → Kopiere den Inhalt von `src/shared/Config.lua`
3. Erstelle ein **Script** namens "RaceServer" → Kopiere den Inhalt von `src/server/RaceServerFixed.lua`
4. Erstelle ein **Script** namens "TrackBuilder" → Kopiere den Inhalt von `src/server/TrackBuilder.lua`

#### Client Scripts (StarterPlayer → StarterPlayerScripts):
1. Erstelle ein **LocalScript** namens "RaceClient" → Kopiere den Inhalt von `src/client/RaceClient.lua`
2. Erstelle ein **LocalScript** namens "BubbleEffects" → Kopiere den Inhalt von `src/client/BubbleEffects.lua`
3. Erstelle ein **LocalScript** namens "CheckpointDetection" → Kopiere den Inhalt von `src/client/CheckpointDetection.lua`

#### ReplicatedStorage:
1. Kopiere das **ModuleScript** "Config" auch nach ReplicatedStorage

### Schritt 3: Automatisches Setup
1. **Starte das Spiel** im Studio (F5)
2. Die Scripts erstellen automatisch:
   - Die Rennstrecke mit Checkpoints
   - Spawn-Punkte für die Autos
   - Alle benötigten Ordner im Workspace

### Schritt 4: Testen
1. **Teste das Spiel** mit mehreren Spielern:
   - Klicke auf "Test" → "Local Server" 
   - Anzahl der Spieler: 2-8
   - Starte den Test

## 🎮 Spielanleitung

### Steuerung:
- **WASD** oder **Pfeiltasten**: Auto fahren
- **Space**: Handbremse
- **R**: Auto zurücksetzen

### Auto auswählen:
1. Beim Spawnen erscheint ein Auswahlmenü
2. Wähle zwischen 4 verschiedenen Autos:
   - **SportsCar**: Ausgewogen
   - **RaceCar**: Schnell und wendig  
   - **Truck**: Langsam aber stabil
   - **Supercar**: Sehr schnell

### Blasen-Effekte:
- Automatisch aktiv an beiden Händen
- Toggle mit dem "🫧 BLASEN" Button
- Verschiedene Farben und Animationen

### Rennen:
- Rennen startet automatisch bei 2+ Spielern
- 10-Sekunden Countdown
- 3 Runden um die Strecke
- Echtzeit-Leaderboard

## ⚙️ Anpassungen

### Auto-Eigenschaften ändern:
Bearbeite das "Config" ModuleScript:
```lua
Config.VEHICLES = {
    {
        Name = "DeinAuto",
        Speed = 80,        -- Geschwindigkeit
        Acceleration = 60, -- Beschleunigung  
        Handling = 90,     -- Wendigkeit
        Color = Color3.fromRGB(255, 0, 0) -- Farbe
    }
}
```

### Blasen-Effekte anpassen:
```lua
Config.BUBBLE_SETTINGS = {
    ParticleCount = 100,  -- Mehr Blasen
    Rate = 50,            -- Häufigkeit
    -- ... weitere Einstellungen
}
```

### Rennstrecke ändern:
Bearbeite `TrackBuilder.lua` um die Streckenlayout zu modifizieren.

## 🐛 Fehlerbehebung

### Häufige Probleme:

1. **"Config not found"**:
   - Stelle sicher, dass Config sowohl in ServerScriptService als auch ReplicatedStorage liegt

2. **Keine Autos spawnen**:
   - Überprüfe ob der "Vehicles" Ordner im Workspace existiert
   - Scripts müssen in der richtigen Reihenfolge geladen werden

3. **Blasen funktionieren nicht**:
   - LocalScript muss in StarterPlayerScripts sein
   - Character muss vollständig geladen sein

4. **Checkpoints reagieren nicht**:
   - Überprüfe ob "Checkpoints" Ordner existiert
   - TouchEvents müssen aktiviert sein

## 🌟 Features erweitern

### Weitere Auto-Typen hinzufügen:
1. Neue Einträge in `Config.VEHICLES` hinzufügen
2. UI in `RaceClient.lua` anpassen für mehr Buttons

### Power-Ups hinzufügen:
1. Neue Parts auf der Strecke platzieren
2. Touch-Events für Speed-Boost, etc.

### Verschiedene Strecken:
1. Mehrere Track-Layouts in `TrackBuilder.lua`
2. Zufällige Streckenauswahl

## 📞 Support
Bei Problemen oder Fragen:
- Überprüfe die Konsole auf Fehlermeldungen
- Stelle sicher, dass alle Scripts an der richtigen Stelle sind
- Teste zuerst im Studio bevor du publizierst

Viel Spaß beim Rennen! 🏁
