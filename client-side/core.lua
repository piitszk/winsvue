local Reports = {}

RegisterNetEvent("winsvue:playerDamage", function(Data)
    local VictimPid = GetPlayerFromServerId(tonumber(Data["Victim"]["Source"]))
    local AuthorPid = GetPlayerFromServerId(tonumber(Data["Author"]["Source"]))
    local VictimPed = GetPlayerPed(VictimPid)

    local Hit,Id = GetPedLastDamageBone(VictimPed)

    Data["Part"] = (Hit and Bones[Id] or "Chest") or "Chest"
    Data["Author"]["Name"] = GetPlayerName(AuthorPid)
    Data["Victim"]["Name"] = GetPlayerName(VictimPid)

    -- Nesse caso apenas mostro o tipo de arma, mas em produção isso poderia ser alterado pro nome do modelo da arma em sí
    Data["Weapon"] = (Data["Weapon"] and (Weapons[Data["Weapon"]] or "UNKNOWN") or false)

    TriggerServerEvent("winsvue:updateRoundData",Data)
end)

RegisterNetEvent("winsvue:updateCombatReport", function(Type,Data)
    Reports[Type] = Data
end)

CreateThread(function()
    while true do
        local Timeout = 999

        if (Reports["Dealt"] or Reports["Taken"]) then
            Timeout = 1

            for Key, Value in pairs(Reports) do
                DrawRect(Draw[Key][1],0.52,0.15,0.25,26,26,26,255)
                DrawText2D(Draw[Key][2],0.41,0.35,4,"REPORT - "..string.upper(Key),255,255,255,255)
    
                DrawText2D(Draw[Key][3],0.45,0.35,4,"NAME",255,255,255,255)
                DrawText2D(Draw[Key][4],0.45,0.35,4,"-",255,255,255,255)
                DrawText2D(Draw[Key][5],0.45,0.35,4,Reports[Key]["Name"],255,255,255,255)
        
                DrawText2D(Draw[Key][6],0.48,0.35,4,"DAMAGE",255,255,255,255)
                DrawText2D(Draw[Key][7],0.48,0.35,4,"-",255,255,255,255)
                DrawText2D(Draw[Key][8],0.48,0.35,4,tostring(Reports[Key]["Damage"]),255,255,255,255)
        
                DrawText2D(Draw[Key][9],0.51,0.35,4,"HEAD",255,255,255,255)
                DrawText2D(Draw[Key][10],0.51,0.35,4,"-",255,255,255,255)
                DrawText2D(Draw[Key][11],0.51,0.35,4,tostring(Reports[Key]["Parts"]["Head"]),255,255,255,255)
        
                DrawText2D(Draw[Key][12],0.54,0.35,4,"CHEST",255,255,255,255)
                DrawText2D(Draw[Key][13],0.54,0.35,4,"-",255,255,255,255)
                DrawText2D(Draw[Key][14],0.54,0.35,4,tostring(Reports[Key]["Parts"]["Chest"]),255,255,255,255)
        
                DrawText2D(Draw[Key][15],0.57,0.35,4,"LEGS",255,255,255,255)
                DrawText2D(Draw[Key][16],0.57,0.35,4,"-",255,255,255,255)
                DrawText2D(Draw[Key][17],0.57,0.35,4,tostring(Reports[Key]["Parts"]["Legs"]),255,255,255,255)
        
                if (Reports[Key]["Weapon"]) then
                    DrawText2D(Draw[Key][18],0.60,0.35,4,"WEAPON",255,255,255,255)
                    DrawText2D(Draw[Key][19],0.60,0.35,4,"-",255,255,255,255)
                    DrawText2D(Draw[Key][20],0.60,0.35,4,Reports[Key]["Weapon"],255,255,255,255)
                end 
            end
        end

        Wait(Timeout)
    end
end)