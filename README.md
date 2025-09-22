# Chat Server with Elixir

## Quickstart

```bash
docker-compose up --build
```

or with mix:

```bash
mix deps.get
mix compile
mix run --no-halt
```

The server runs on port 4040.

## Connect

```bash
telnet localhost 4040
```

Or with netcat:

```bash
nc localhost 4040
```

## Features

### What the chat can do:

* **Username input**: Every user must enter a name
* **Channel list**: View all active channels
* **Join channel**: Join new or existing channels
* **Real-time chat**: Messages are instantly sent to all channel members
* **Username display**: Every message shows the sender
* **Automatic cleanup**: Users are automatically removed on disconnect
* **Multiple channels**: Several channels can run simultaneously

### Actor Model

* Each channel is its own GenServer process
* Messages are exchanged between processes
* Automatic error handling via Supervisor

![GenServer Graphic](https://miro.medium.com/v2/resize\:fit:720/format\:webp/1*Kll_Xxko91JKaS0rzM9XpQ.png)