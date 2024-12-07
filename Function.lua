--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Types)

local Function = {}

type FunctionType<Parameters..., Returning...> = {
	Name: string,
	
	setServerInvocationHandler: (Types.Callback<(Player, Parameters...), Returning...>) -> (),
	setClientInvocationHandler: (Types.Callback<Parameters..., Returning...>) -> (),
	invokeServer: Types.Callback<Parameters..., Returning...>,
	invokeClient: Types.Callback<(Player, Parameters...), Returning...>,
}
type Device = "Client" | "Server"

type BaseFunction = {
	Name: string,
}
type ClientSideFunction<Parameters..., Returning...> = BaseFunction & {
	setClientInvocationHandler: (Types.Callback<Parameters..., Returning...>) -> (),
	invokeClient: Types.Callback<(Player, Parameters...), Returning...>,
}
type ServerSideFunction<Parameters..., Returning...> = BaseFunction & {
	setServerInvocationHandler: (Types.Callback<(Player, Parameters...), Returning...>) -> (),
	invokeServer: Types.Callback<Parameters..., Returning...>,
}
type BidirectionalFunction<Parameters..., Returning...> = ClientSideFunction<Parameters..., Returning...> &
	ServerSideFunction<Parameters..., Returning...>

export type ClientSide<Parameters... = (), Returning... = ()> = ClientSideFunction<Parameters..., Returning...>
export type ServerSide<Parameters... = (), Returning... = ()> = ServerSideFunction<Parameters..., Returning...>
export type Bidirectional<Parameters... = (), Returning... = ()> = BidirectionalFunction<Parameters..., Returning...>
export type Any<Parameters... = (), Returning... = ()> = ClientSideFunction<Parameters..., Returning...> |
	ServerSideFunction<Parameters..., Returning...> |
	BidirectionalFunction<Parameters..., Returning...>

local function findRelatedRemoteFunction(name: string): RemoteFunction
	local remoteFunctionFound: RemoteFunction? = ReplicatedStorage:FindFirstChild(name)
	
	if not remoteFunctionFound then
		error(`Could not find remote function "{name}"`)
	end
	
	return remoteFunctionFound
end

function Function.clientSide<Parameters..., Returning...>(name: string): ClientSideFunction<Parameters..., Returning...>
	local remoteFunction = findRelatedRemoteFunction(name)
	local self = {
		Name = name,
	}
	
	function self.setClientInvocationHandler(callback)
		remoteFunction.OnClientInvoke = callback
	end
	
	function self.invokeClient(player, ...)
		return remoteFunction:InvokeClient(player, ...)
	end
	
	if RunService:IsClient() then
		function remoteFunction.OnClientInvoke(...)
			print(`OnClientInvoke not implemented for "{name}"`)
		end
	end
	
	return self
end

function Function.serverSide<Parameters..., Returning...>(name: string): ServerSideFunction<Parameters..., Returning...>
	local remoteFunction = findRelatedRemoteFunction(name)
	local self = {
		Name = name,
	}
	
	function self.setServerInvocationHandler(callback)
		remoteFunction.OnServerInvoke = callback
	end
	
	function self.invokeServer(...)
		return remoteFunction:InvokeServer(...)
	end
	
	if RunService:IsServer() then
		function remoteFunction.OnServerInvoke(...)
			print(`OnServerInvoke not implemented for "{name}"`)
		end
	end
	
	return self
end

function Function.bidirectional<Parameters..., Returning...>(
	name: string
): BidirectionalFunction<Parameters..., Returning...>
	local remoteFunction = findRelatedRemoteFunction(name)
	local self = {
		Name = name,
	}
	
	function self.setClientInvocationHandler(callback)
		remoteFunction.OnClientInvoke = callback
	end

	function self.invokeServer(...)
		return remoteFunction:InvokeServer(...)
	end
	
	function self.setServerInvocationHandler(callback)
		remoteFunction.OnServerInvoke = callback
	end

	function self.invokeClient(player, ...)
		return remoteFunction:InvokeClient(player, ...)
	end
	
	if RunService:IsServer() then
		function remoteFunction.OnServerInvoke(...)
			print(`OnServerInvoke not implemented for "{name}"`)
		end
	elseif RunService:IsClient() then
		function remoteFunction.OnClientInvoke(...)
			print(`OnClientInvoke not implemented for "{name}"`)
		end
	end
	
	return self
end

return Function
