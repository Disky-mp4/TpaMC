--[[---------------------------------------------
-- Name: tpamc
-- Description: TPA, inspired by Minecraft.
-- Author: Disky & Superzorik
--]]---------------------------------------------

local requests = {
    --[RequestSentToID] = {RequestFromID, GetGameTimer()}
}

local function sendMsg(id, msg, name, cols)
    TriggerClientEvent("chat:addMessage", id, {
        color = cols or {242, 245, 66},
        multiline = true,
        args = {name or "TPA", msg}
    })
end

RegisterCommand("tpa", function(source, args)
    if #args < 1 then return sendMsg(source, "You must provide an ID to teleport to.") end
    if not tonumber(args[1]) then return sendMsg(source, "You must provide an ID to teleport to.") end
    if not GetPlayerPed(source) then return sendMsg(source, "ID " .. args[1] .. " doesn't exist.") end

    local id = tonumber(args[1])

    requests[id] = {source, GetGameTimer()}
    sendMsg(id, ("You have recieved a teleport request from %s [%i]. Type /tpaccept to accept it."):format(GetPlayerName(source), source))
    sendMsg(source, ("You have successfully sent a teleport request to %s [%i]."):format(GetPlayerName(id), id))
end)

RegisterCommand("tpaccept", function(source)
    if not requests[source] then return sendMsg(source, "You do not have any pending teleport requests.") end
    
    if GetGameTimer() - requests[source][2] > TPA.ExpirationTime then sendMsg(source, ("That teleport request from %s [%i] has expired."):format(GetPlayerName(requests[source][1]), requests[source][1])); requests[source] = nil; return end

    local target = GetPlayerPed(source)
    local ped    = GetPlayerPed(requests[source][1])

    if not ped then requests[source] = nil; return sendMsg(source, "Your last teleport request has expired.") end

    
    sendMsg(requests[source][1], ("Your teleport request to %s [%i] has been accepted. You will be teleported in 5 seconds."):format(GetPlayerName(source), source))
    sendMsg(source, ("You accepted the teleport request from %s [%i]."):format(GetPlayerName(requests[source][1]), requests[source][1]))
    
    Wait(5000)
    
    local targetCoords = GetEntityCoords(target)
    SetEntityCoords(ped, targetCoords.x, targetCoords.y, targetCoords.z)
end)

RegisterCommand("tpdeny", function(source)
    if not requests[source][1] then return sendMsg(source, "You do not have any pending teleport requests.") end
    
    sendMsg(source, ("You just denied the teleport request from %s [%i]."):format(GetPlayerName(requests[source][1]), requests[source][1]))
    sendMsg(requests[source][1], ("Your teleport request to %s [%i] has been denied."):format(GetPlayerName(source), source))
    
    requests[source] = nil
end)