Games = {}
Games.data = {
    ['matchmaking-01'] = {
        players = {
            data = {
                attackers = {
                    [10] = {
                        nick = 'MidnightWolf',
                        group = 'group:10',
                        leader = true
                    },
                    [2] = {
                        nick = 'BlazeGamer',
                        group = 'group:4',
                        leader = false
                    },
                    [3] = {
                        nick = 'SpeedRacer',
                        group = 'group:4',
                        leader = false
                    },
                    [4] = {
                        nick = 'ShadowNinja',
                        group = 'group:4',
                        leader = true
                    },
                    [5] = {
                        nick = 'PhoenixFire',
                        group = 'group:4',
                        leader = false
                    }
                },
                defenders = {
                    [6] = {
                    nick = 'ThunderBolt',
                    group = 'group:6',
                    leader = true
                    },
                    [7] = {
                        nick = 'GhostRider',
                        group = 'group:6',
                        leader = false
                    },
                    [8] = {
                        nick = 'NeonSpectre',
                        group = 'group:9',
                        leader = false
                    },
                    [9] = {
                        nick = 'DriftKing',
                        group = 'group:9',
                        leader = true
                    },
                    [1] = {
                        nick = 'ViperGT',
                        group = 'group:1',
                        leader = true
                    }
                }
            }
        },
        rounds = {
            current = 1,
            data = {
                [1] = {
                    -- Insira os dados da rodada aqui.
                }
            }
        }
    }
}

RegisterNetEvent("winsvue:updateRoundData", function(Data,Callback)
    -- Aqui é necessário checar qual partida o player que infligiu dano estaria e criar uma validação pra checar se ambos realmente estão in-match
    -- Por questões por de ser um ambiente de testes, foi indexado automaticamente ao matchmaking-01 e sem as respectivas validações

    local Match = Games["data"]["matchmaking-01"]
    local Rounds = Match["rounds"]
    local Current = Rounds["current"]
    local Round = Rounds["data"]

    if (not Round[Current]) then
        Round[Current] = {}
    end

    local Victim = Data["Victim"]
    local Author = Data["Author"]

    -- VICTIM TAKEN

    -- Cria os dados da vítima caso não existam assim que o dano é infligido pela primeira vez
    if (not Round[Current][Victim["Identifier"]]) then
        Round[Current][Victim["Identifier"]] = { 
            ["Dealt"] = {},
            ["Taken"] = {}
        }

        Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]] = {
            ["Name"] = Author["Name"],
            ["Parts"] = {
                ["Chest"] = 0,
                ["Legs"] = 0,
                ["Head"] = 0
            },
            ["Damage"] = 0,
            ["Weapon"] = Data["Weapon"]
        }
    end

    -- A condicional abaixo tem apenas como função criar o Taken pra CASO ele ainda não tenha sido criado, isso pode ocorrer em situações onde...
    -- A primeira condicional não seria chamada porque mais abaixo irá criar automaticamente pro AUTHOR mas SEM informações de Taken
    -- Isso ocorre quando o player inflige dano em alguém, e quaisquer outra pessoa inflige dano nele de volta

    if (not Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]) then
        Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]] = {
            ["Name"] = Author["Name"],
            ["Parts"] = {
                ["Chest"] = 0,
                ["Legs"] = 0,
                ["Head"] = 0
            },
            ["Damage"] = 0,
            ["Weapon"] = Data["Weapon"]
        }
    end


    if (Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Parts"][Data["Part"]]) then
        Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Parts"][Data["Part"]] += 1
    end

    Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Damage"] += Data["Damage"]
    Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Weapon"] = Data["Weapon"]

    -- AUTHOR DEALT
    
    if (not Round[Current][Author["Identifier"]]) then
        Round[Current][Author["Identifier"]] = { 
            ["Dealt"] = {},
            ["Taken"] = {}
        }
    end

    Round[Current][Author["Identifier"]]["Dealt"][Victim["Identifier"]] = Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]

    -- DEBUG COMPLETO DO ROUND
    -- print("----------------------------------------------")
    -- print(json.encode(Round[Current], { indent = true }))

    local Payload = { 
        Damage = Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Damage"], 
        Parts = Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Parts"], 
        Weapon = Round[Current][Victim["Identifier"]]["Taken"][Author["Identifier"]]["Weapon"]
    }

    Payload["Name"] = Victim["Name"]
    TriggerClientEvent("winsvue:updateCombatReport",Author["Source"],"Dealt",Payload)

    Payload["Name"] = Author["Name"]
    TriggerClientEvent("winsvue:updateCombatReport",Victim["Source"],"Taken",Payload)
end)

AddEventHandler("weaponDamageEvent", function (Sender,Data)
    local Network = NetworkGetEntityFromNetworkId(Data["hitGlobalId"])
    local Source = NetworkGetEntityOwner(Network)

    if (GetEntityHealth(Network) > 101) then
        TriggerClientEvent("winsvue:playerDamage",Sender,{
            -- Em Author e Victim usei o source como identifier, mas em ambiente de produção é necessário o uso de identificadores únicos como user_id em **STRING** pra persistência do cache
            Author = {
                Source = Sender,
                Identifier = Sender -- "Unique Identifier"
            },
            Victim = {
                Source = tostring(Source),
                Identifier = tostring(Source) -- "Unique Identifier"
            },
            Damage = Data["weaponDamage"],

            -- Weapon só retornará ~= false quando o dano infligido ao player SEJA FATAL (mesma coisa ocorre no valorant)
            Weapon = (Data["willKill"] and Data["weaponType"] or false)
        })
    end
end)