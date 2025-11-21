Hades2MP

---

Hades2MP is a multiplayer co-op mod for Hades II. It aims to enable network communication between players, allowing them to connect and play together using a Host/Client architecture.

---

Project Overview

This project is currently in an early development / Proof of Concept stage. It implements a custom networking layer to synchronize game state between players.

Key Features

    UDP Networking: Utilizes high-performance, non-blocking UDP sockets for low-latency communication between players.

    Host & Client Modes: Fully configurable roles allowing a player to act as the server (Host) or join an existing session (Client).

    Hot-Reloading: Designed with development in mind, supporting script updates during runtime without needing to restart the game.

    Seamless Integration: Hooks directly into the game's map loading process to initialize connections automatically when gameplay begins.

---

Installation

The easiest way to install this mod is via a mod manager:

    Use r2modman or Thunderstore Mod Manager.

    Search for Hades2MP.

    Download and install the latest version.

---

Configuration

To establish a connection, one player must configure themselves as the Host and the other as the Client. This is done by editing the mod's configuration file.

    Host: Sets the mode to host. The host listens for incoming connections on a specified port.

    Client: Sets the mode to client and provides the target_ip of the Host to connect.

Note: The Host may need to port-forward the designated UDP port (default: 7777) on their router.

Current Status

    Connectivity: The mod currently successfully establishes a UDP connection between a Host and Client.

    Game Loop: Network threads are spawned automatically when a map is loaded.

    Testing: Basic packet transmission is functional (sending test packets between connected instances).

---

Dependencies

This mod requires the following libraries to function:

    Hell2Modding

    LuaENVY

    SGG_Modding-Chalk

    SGG_Modding-ReLoad

    SGG_Modding-SJSON

    SGG_Modding-ModUtil

---

License

This project is licensed under the MIT License.