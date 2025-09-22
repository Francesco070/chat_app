# Chat Server mit Elixir

## Schnellstart

```bash
docker-compose up --build
```

oder mit mix:

```bash
mix deps.get
mix compile
mix run --no-halt
```

Der Server läuft auf Port 4000.



## Verbinden

```bash
telnet localhost 4000
```

Oder mit netcat:
```bash
nc localhost 4000
```

## Funktionen

### Was der Chat kann:
- **Username-Eingabe**: Jeder User muss einen Namen eingeben
- **Channel-Liste**: Alle aktiven Channels
- **Channel beitreten**: Neue oder existierende Channels betreten
- **Echtzeit-Chat**: Nachrichten werden sofort an alle Channel-Mitglieder gesendet
- **Username-Anzeige**: Jede Nachricht zeigt den Absender
- **Automatisches Cleanup**: User werden automatisch entfernt bei Disconnect
- **Multiple Channels**: Mehrere Channels können gleichzeitig laufen

### Actor Model
- Jeder Channel ist ein eigener GenServer-Prozess
- Nachrichten werden zwischen Prozessen ausgetauscht
- Automatisches Fehler-Handling durch Supervisor

![GenServer Grafik](https://miro.medium.com/v2/resize:fit:720/format:webp/1*Kll_Xxko91JKaS0rzM9XpQ.png)
