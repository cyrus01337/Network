# Network
Light-weight, fully typed networking interface for communication between client and server

### Setup
Create a module, require whatever remotes you need, define then return them in this module.
```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedTypes = require(ReplicatedStorage.Types)

local Event = require(script.Event)
local Function = require(script.Function)

local Events = {
	Damage = Event.serverSide("Damage") :: Event.ServerSide<Humanoid, number>,
	Acknowledged = Event.bidirectional("Acknowledged") :: Event.Bidirectional,
	CreateKiBlast = Event.bidirectional("CreateKiBlast") :: Event.Bidirectional<Vector3, Vector3, Part?>,
	TriggerMaxPowerMode = Event.serverSide("TriggerMaxPowerMode") :: Event.ServerSide,
}
local Functions = {
	FetchClientNecessaryData = Function.serverSide(
		"FetchClientNecessaryData"
	) :: Function.ServerSide<(), (SharedTypes.ClientNecessaryData?)>,
}

return {
	Events = Events,
	Functions = Functions,
}
```
Here is how I organised mine if you would like a convention:

![Conventional design for Network](https://github.com/user-attachments/assets/15e9d0d1-1906-4d4a-8ba1-ce07d78c6235)

Now you have fully-typed networking at your discretion.

### License
None.
