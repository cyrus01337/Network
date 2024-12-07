--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Types)

local BasicEventWrapper = {}
local Event = {}

type BasicEventWrapperType<Arguments...> = {
	Original: RBXScriptSignal,
	
	connect: (Types.Callback<Arguments...>) -> (),
	once: (Types.Callback<Arguments...>) -> (),
	wait: () -> Arguments...,
}

type BaseEvent = {
	Name: string,
}
type ClientSideEvent<Arguments...> = BaseEvent & {
	OnClientEvent: BasicEventWrapperType<Arguments...>,

	fireClient: Types.Callback<(Player, Arguments...)>,
	fireAllClients: Types.Callback<Arguments...>,
}
type ServerSideEvent<Arguments...> = BaseEvent & {
	OnServerEvent: BasicEventWrapperType<(Player, Arguments...)>,

	fireServer: Types.Callback<Arguments...>,
}
type BidirectionalEvent<Arguments...> = ClientSideEvent<Arguments...> & ServerSideEvent<Arguments...>

export type ClientSide<Arguments... = ()> = ClientSideEvent<Arguments...>
export type ServerSide<Arguments... = ()> = ServerSideEvent<Arguments...>
export type Bidirectional<Arguments... = ()> = BidirectionalEvent<Arguments...>
export type Any<Arguments... = ()> = ClientSideEvent<Arguments...> |
	ServerSideEvent<Arguments...> |
	BidirectionalEvent<Arguments...>

function BasicEventWrapper.new<Arguments...>(event: RBXScriptSignal): BasicEventWrapperType<Arguments...>
	local self = {
		Original = event,
	}
	
	function self.connect(callback)
		self.Original:Connect(callback)
	end
	
	function self.once(callback)
		self.Original:Once(callback)
	end
	
	function self.wait()
		return self.Original:Wait()
	end
	
	return self
end

function findRelatedRemoteEvent(name: string): RemoteEvent
	local remoteEventFound: RemoteEvent? = ReplicatedStorage:FindFirstChild(name)

	if not remoteEventFound then
		error(`Could not find remote event "{name}"`)
	end

	return remoteEventFound
end

function Event.clientSide<Arguments...>(name: string): ClientSideEvent<Arguments...>
	local remoteEvent = findRelatedRemoteEvent(name)
	local self = {
		Name = name,
		OnClientEvent = BasicEventWrapper.new(remoteEvent.OnClientEvent),
	}
	
	function self.fireClient(player, ...)
		remoteEvent:FireClient(player, ...)
	end

	function self.fireAllClients(...)
		remoteEvent:FireAllClients(...)
	end

	return self
end

function Event.serverSide<Arguments...>(name: string): ServerSideEvent<Arguments...>
	local remoteEvent = findRelatedRemoteEvent(name)
	local self = {
		Name = name,
		OnServerEvent = BasicEventWrapper.new(remoteEvent.OnServerEvent),
	}

	function self.fireServer(...)
		remoteEvent:FireServer(...)
	end
	
	return self
end

function Event.bidirectional<Arguments...>(name: string): BidirectionalEvent<Arguments...>
	local remoteEvent = findRelatedRemoteEvent(name)
	local self = {
		Name = name,
		OnClientEvent = BasicEventWrapper.new(remoteEvent.OnClientEvent),
		OnServerEvent = BasicEventWrapper.new(remoteEvent.OnServerEvent),
	}
	
	function self.fireServer(...)
		remoteEvent:FireServer(...)
	end
	
	function self.fireClient(player, ...)
		remoteEvent:FireClient(player, ...)
	end

	function self.fireAllClients(...)
		remoteEvent:FireAllClients(...)
	end
	
	return self
end

return Event
