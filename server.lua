RegisterServerEvent('Perry_Trapdoor:ChangeState')
AddEventHandler('Perry_Trapdoor:ChangeState', function(door, doorstate)
	TriggerClientEvent("Perry_Trapdoor:ChangeState", -1, door, doorstate)
end)