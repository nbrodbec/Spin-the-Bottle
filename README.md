# Spin the Bottle
Round-based russian roulette-inspired game developed for the Roblox platform. The game was published [here](https://www.roblox.com/games/7133467811/Spin-The-Bottle).

## Project Structure
The project is composed entirely of Lua modules. The main module runner is located at `src/ReplicatedStorage/MainModules` and provides every module with the dependencies it needs by first requiring the module and then calling its `init()` function.
Respecting the client-server model that the Roblox platform enforces, server modules are located in `src/ServerScriptService/ServerModules` and client modules are located in `src/StarterPlayerScripts/ClientModules`. Shared utilities, libraries and datastructure implementations are located in `src/ReplicatedStorage`.
Communication between server and client is accomplished using the [RemoteEvents](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) and [RemoteFunctions](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction) in `src/ReplicatedStorage/RemoteObjects`.
Several modules containing only constants are also included in the project, but not tracked by source control. They live solely in Roblox Studio so the non-programmer developers can interact with them.

## External Dependencies
This project uses a few external libraries:
* [Fusion](https://elttob.uk/Fusion/0.2/) for the user interface,
* [EZ Camera Shake](https://github.com/Sleitnick/RbxCameraShaker) for bullet shake effects
* [Rojo](https://rojo.space/) for managing the source code of the project and synchronizing it with Roblox Studio.

Any other utility libraries or datastructures were implemented by the author of this repository.

## Features

This game has been fully completed with the following core features:
* Main gameplay
    1. Players sit around a table
    2. A bottle is spun to select a player
    3. Selected player receives a gun and has a time limit to shoot another player
    4. Either the gun fires a bullet or a blank, with the probability based on the number of blanks fired before this player (assuming a 6 chamber revolver with a single bullet)
    5. When all players have been eliminated but one, the remaining player is declared the winner and a new round is setup.
* Extra gamemodes
    1. Lights out: Lights turn off when player receives a gun so nobody can see who they're aiming at before they shoot
    2. Double shot: Every selected player gets 2 chances to fire the gun
    3. Rapid fire: The time limit for a player to choose a target is significantly reduced
    4. Blitz: No blanks, every chamber has a bullet and every player has a 100% chance of killing their target
*  Inventory system for suits and guns
*  In-game currency shop for suits and guns
*  Microtransaction shop for in-game currency
*  Microtransaction shop for special perks
*  Anticheat detection
*  Background music
*  Player stats leaderboard
*  Visual effects (gun muzzle flash, camera shake, moving scenery parts, etc.)
*  Sound effects (gun firing, death noises, blood on death)
*  Player settings (Toggle violent effects like blood, toggle music, toggle sound effects)
*  Player data persistence
*  Synchronization between player data fetched on server, and viewed on client

## Game Statistics
The published game has been played 39 million times and has generated over $200,000USD in revenue, with roughly 1500 concurrent active users at a time at the game's peak.

(The game is now no longer playable as Roblox moderation took it down and refuses to respond to any communications inquiring about the reason for its termination)
