local kirjastohylly = false
local kaupantrapdoor = false
local gunsmithtrapdoor = false
local objekti
local open = false

local VORPutils = {}

TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)

Citizen.CreateThread(function()
	local PromptGroup = VORPutils.Prompts:SetupPromptGroup() --Setup Prompt Group
	
	local firstprompt = PromptGroup:RegisterPrompt("Open trapdoor", 0x4CC0E2FE, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"}) --Register your first prompt
	while true do
		Citizen.Wait(1)
		local ped = PlayerPedId()
		for k,v in pairs(Config.TrapDoors) do
			if IsPlayerNearCoords(v.x, v.y, v.z) then
				PromptGroup:ShowGroup("Trapdoor")
				if firstprompt:HasCompleted() then
					InitiateOpen(v.name)
				end
			end
		end
	end
end)

function IsPlayerNearCoords(x, y, z)
    local playerx, playery, playerz = table.unpack(GetEntityCoords(PlayerPedId(), 0))
    local distance = Vdist2(playerx, playery, playerz, x, y, z, true) -- USE VDIST

    if distance < 2 then
        return true
    end
end


function InitiateOpen(doorname) --doorname from Eye system
	local ped = PlayerPedId()
    local pc = GetEntityCoords(PlayerPedId())
	for k,v in pairs(Config.TrapDoors) do
		local propName = v.doorProp
		local door = GetClosestObjectOfType(pc.x,pc.y, pc.z , 5.0, propName, false, false, false) 
		if door then 
			if doorname == v.name then
				if v.walldoor then 
					if DoesEntityExist(door) then
						DeleteEntity(door)
					end
					if not HasModelLoaded(propName) then
						RequestModel(propName)
					end
					while not HasModelLoaded(propName) do
						Citizen.Wait(1)
					end
					doorObject = CreateObject(propName, v.x, v.y, v.z, true, true, false) 
					if not open then
						SetEntityRotation(doorObject, 0.0, 0.0, v.closedRotZ, 2, true)
					else
						SetEntityRotation(doorObject, 0.0, 0.0, v.openRotZ, 2, true)
					end
					RotateDoors(doorname, doorObject, open)
					break 
				elseif v.floordoor then 
					if DoesEntityExist(door) then
						DeleteEntity(door)
					end
					if not HasModelLoaded(propName) then
						RequestModel(propName)
					end
					while not HasModelLoaded(propName) do
						Citizen.Wait(1)
					end
					doorObject = CreateObject(propName, v.x, v.y, v.z, true, true, false) 
					if not open then
						SetEntityRotation(doorObject, v.closedRotX, v.closedRotY, v.closedRotZ, 2, true)
					else
						SetEntityRotation(doorObject, v.openRotX, v.openRotY, v.openRotZ, 2, true)
					end
					RotateDoors(doorname, doorObject, open)
					break 
				end
				break
			end
		end
	end
end

function RotateDoors(name, entity, open)
	SetEntityCanBeDamaged(entity, false)
	SetEntityInvincible(entity, true)
	FreezeEntityPosition(entity, false)
	local value = 0
	for k,v in pairs(Config.TrapDoors) do
		if name == v.name then
			if v.walldoor then
				if not open then
					value = v.closedRotZ
					while true do
						Wait(1)
						value = value + 1
						SetEntityRotation(entity, v.closedRotX, v.closedRotY, value, 2, true)
						if value >= v.openRotZ then
							open = true
							FreezeEntityPosition(entity, true)
							TriggerServerEvent("Perry_Trapdoor:ChangeState", name, open)
							break
						end
					end
				else
					value = v.openRotZ
					while true do
						Wait(1)
						value = value - 1
						SetEntityRotation(entity, v.openRotX, v.openRotY, value, 2, true)
						if value <= v.closedRotZ then
							open = false
							FreezeEntityPosition(entity, true)
							TriggerServerEvent("Perry_Trapdoor:ChangeState", name, open)
							break
						end
					end
				end
			elseif v.floordoor then
				if not open then
					value = v.closedRotX
					while true do
						Wait(1)
						value = value - 1
						SetEntityRotation(entity, value, v.closedRotY, v.closedRotZ, 2, true)
						if value <= v.openRotX then
							open = true
							TriggerServerEvent("Perry_Trapdoor:ChangeState", name, open)
							break
						end
					end
				else
					value = v.openRotX
					while true do
						Wait(1)
						value = value + 1
						SetEntityRotation(entity, value, v.closedRotY, v.closedRotZ, 2, true)
						if value >= v.closedRotX then
							open = false
							TriggerServerEvent("Perry_Trapdoor:ChangeState", name, open)
							break
						end
					end
				end
				break
			end
			break
		end
	end
end


RegisterNetEvent("Perry_Trapdoors:AvaaOvi")
AddEventHandler("Perry_Trapdoors:AvaaOvi", function(doori)
	InitiateOpen(doori)
end)

RegisterNetEvent("Perry_Trapdoor:ChangeState")
AddEventHandler("Perry_Trapdoor:ChangeState", function(door, openstate)
	open = openstate
	if door == "kirjastohylly" then
		if kirjastohylly == true then
			kirjastohylly = false
		else
			kirjastohylly = true
		end
	elseif door == "kaupantrapdoor" then
		if kaupantrapdoor == true then
			kaupantrapdoor = false
		else
			kaupantrapdoor = true
		end
	elseif door == "gunsmithtrapdoor" then
		if gunsmithtrapdoor == true then
			gunsmithtrapdoor = false
		else
			gunsmithtrapdoor = true
		end
	end
end)