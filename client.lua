local QBCore = exports['qb-core']:GetCoreObject()
local isOnDuty = false
local currentBlip = nil
local deliveryVehicle = nil
local deliveryBlip = nil
local currentDelivery = nil
local deliveriesCompleted = 0
local totalDeliveries = 0
local PlayerData = {}
local pizzaPed = nil

local uiOpen = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if uiOpen then
        CloseUI()
    end

    CreatePizzaNPC()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isOnDuty = false
    EndDeliveryJob()
    PlayerData = {}

    if pizzaPed ~= nil then
        DeletePed(pizzaPed)
        pizzaPed = nil
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNUICallback('startJob', function(data, cb)
    StartDeliveryJob()
    SetNuiFocus(false, false)
    uiOpen = false
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    uiOpen = false
    cb('ok')
end)

function OpenUI()
    if uiOpen then return end

    if Config.UseUI then
        uiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'open'
        })
    end
end

function CloseUI()
    if not uiOpen then return end

    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'close'
    })
end

function CreatePizzaNPC()
    if pizzaPed ~= nil then
        DeletePed(pizzaPed)
        pizzaPed = nil
    end

    local pedModel = Config.NPCSettings.model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    pizzaPed = CreatePed(4, pedModel, Config.NPCSettings.coords.x, Config.NPCSettings.coords.y, Config.NPCSettings.coords.z - 1.0, Config.NPCSettings.coords.w, false, false)

    SetEntityHeading(pizzaPed, Config.NPCSettings.coords.w)
    FreezeEntityPosition(pizzaPed, true)
    SetEntityInvincible(pizzaPed, true)
    SetBlockingOfNonTemporaryEvents(pizzaPed, true)

    if Config.NPCSettings.animation.enabled then
        RequestAnimDict(Config.NPCSettings.animation.dict)
        while not HasAnimDictLoaded(Config.NPCSettings.animation.dict) do
            Wait(10)
        end

        TaskPlayAnim(pizzaPed, Config.NPCSettings.animation.dict, Config.NPCSettings.animation.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end

function StartDeliveryJob()
    if isOnDuty then return end

    isOnDuty = true
    deliveriesCompleted = 0
    totalDeliveries = math.random(Config.MinDeliveries, Config.MaxDeliveries)

    QBCore.Functions.Notify(string.format(Config.Messages['job_started'], totalDeliveries), "success")

    if Config.RequireBag and Config.GiveBagOnJobStart then
        TriggerServerEvent('qb-pizzajob:server:GiveBag')
    end

    QBCore.Functions.SpawnVehicle(Config.VehicleModel, function(vehicle)
        SetEntityHeading(vehicle, Config.VehicleSpawnPoint.w)

        if Config.CustomVehicleSettings.fuelLevel then
            exports['LegacyFuel']:SetFuel(vehicle, Config.CustomVehicleSettings.fuelLevel)
        end

        local plate = Config.CustomVehicleSettings.platePrefix
        if Config.CustomVehicleSettings.plateNumbers then
            plate = plate .. tostring(math.random(1000, 9999))
        end
        SetVehicleNumberPlateText(vehicle, plate)

        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))

        if Config.VehicleLivery > 0 then
            SetVehicleLivery(vehicle, Config.VehicleLivery)
        end

        deliveryVehicle = vehicle

        SelectNewDeliveryPoint()

        QBCore.Functions.Notify(Config.Messages['vehicle_spawned'], "success")
    end, Config.VehicleSpawnPoint, true)
end

function EndDeliveryJob()
    if not isOnDuty then return end

    isOnDuty = false
    QBCore.Functions.Notify(Config.Messages['job_ended'], "success")

    if Config.RequireBag and Config.ReturnBagOnJobEnd then
        TriggerServerEvent('qb-pizzajob:server:ReturnBag')
    end

    if deliveryBlip ~= nil then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end

    if deliveryVehicle ~= nil and Config.DeleteVehicleOnJobEnd then
        QBCore.Functions.DeleteVehicle(deliveryVehicle)
        deliveryVehicle = nil
    end

    currentDelivery = nil
    deliveriesCompleted = 0
    totalDeliveries = 0
end

function SelectNewDeliveryPoint()
    if currentDelivery ~= nil then
        if deliveryBlip ~= nil then
            RemoveBlip(deliveryBlip)
        end
    end

    local randomPoint = Config.DeliveryHomes[math.random(#Config.DeliveryHomes)]
    currentDelivery = randomPoint

    deliveryBlip = AddBlipForCoord(randomPoint.x, randomPoint.y, randomPoint.z)
    SetBlipSprite(deliveryBlip, Config.DeliveryBlipSprite)
    SetBlipDisplay(deliveryBlip, 4)
    SetBlipScale(deliveryBlip, Config.DeliveryBlipScale)
    SetBlipAsShortRange(deliveryBlip, true)
    SetBlipColour(deliveryBlip, Config.DeliveryBlipColor)
    SetBlipRoute(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Pizza Teslimat Noktası")
    EndTextCommandSetBlipName(deliveryBlip)

    QBCore.Functions.Notify(Config.Messages['new_delivery'], "success")
end

function CompleteDelivery()
    if currentDelivery == nil then return end

    local payment = math.random(Config.MinPayment, Config.MaxPayment)
    TriggerServerEvent('qb-pizzajob:server:PayForDelivery', payment)

    QBCore.Functions.Notify(string.format(Config.Messages['delivery_complete'], payment), "success")

    deliveriesCompleted = deliveriesCompleted + 1

    if deliveriesCompleted >= totalDeliveries then
        QBCore.Functions.Notify(Config.Messages['all_deliveries_done'], "success")

        if deliveryBlip ~= nil then
            RemoveBlip(deliveryBlip)
            deliveryBlip = nil
        end

        local centerBlip = AddBlipForCoord(Config.NPCSettings.coords.x, Config.NPCSettings.coords.y, Config.NPCSettings.coords.z)
        SetBlipSprite(centerBlip, 162)
        SetBlipColour(centerBlip, 2)
        SetBlipRoute(centerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Pizza Merkezi - Dön")
        EndTextCommandSetBlipName(centerBlip)

        currentDelivery = nil
    else
        SelectNewDeliveryPoint()
    end
end

function DeliverPizzaToHouse()
    if not isOnDuty or currentDelivery == nil then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local deliveryCoords = vector3(currentDelivery.x, currentDelivery.y, currentDelivery.z)
    local distance = #(playerCoords - deliveryCoords)

    if distance > 5.0 then return end

    if IsPedInAnyVehicle(playerPed, false) then
        QBCore.Functions.Notify(Config.Messages['exit_vehicle'], "error")
        return
    end

    if Config.RequireBag then
        local hasBag = QBCore.Functions.HasItem(Config.BagItem)
        if not hasBag then
            QBCore.Functions.Notify(Config.Messages['no_bag'], "error")
            return
        end
    end

    if Config.UseAnimation then
        QBCore.Functions.Progressbar("deliver_pizza", Config.Messages['delivering_pizza'], Config.DeliveryTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = Config.AnimDict,
            anim = Config.AnimName,
            flags = Config.AnimFlag,
        }, {
            model = "prop_pizza_box_01",
            bone = 28422,
            coords = { x = 0.0, y = 0.0, z = 0.0 },
            rotation = { x = 0.0, y = 0.0, z = 0.0 },
        }, {}, function()
            CompleteDelivery()
        end, function()
            QBCore.Functions.Notify(Config.Messages['cancelled'], "error")
        end)
    else
        CompleteDelivery()
    end
end

function InteractWithPizzaNPC()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local npcCoords = vector3(Config.NPCSettings.coords.x, Config.NPCSettings.coords.y, Config.NPCSettings.coords.z)
    local distance = #(playerCoords - npcCoords)

    if distance < 2.0 then
        if isOnDuty then
            EndDeliveryJob()
        else
            OpenUI()
        end
    end
end

Citizen.CreateThread(function()
    if Config.UseBlip then
        local blip = AddBlipForCoord(Config.NPCSettings.coords.x, Config.NPCSettings.coords.y, Config.NPCSettings.coords.z)
        SetBlipSprite(blip, Config.BlipSprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.BlipScale)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, Config.BlipColor)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.BlipName)
        EndTextCommandSetBlipName(blip)
    end

    CreatePizzaNPC()

    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local npcCoords = vector3(Config.NPCSettings.coords.x, Config.NPCSettings.coords.y, Config.NPCSettings.coords.z)
        local npcDistance = #(playerCoords - npcCoords)

        if npcDistance < 10.0 then
            if Config.UseMarkers then
                DrawMarker(Config.MarkerType, 
                    npcCoords.x, npcCoords.y, npcCoords.z - 0.95, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, 
                    false, true, 2, false, nil, nil, false)
            end

            if npcDistance < 2.0 then
                if isOnDuty then
                    QBCore.Functions.DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, 
                        string.format(Config.Messages['end_job'], Config.UIKey))
                else
                    QBCore.Functions.DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, 
                        string.format(Config.Messages['start_job'], Config.UIKey))
                end

                if IsControlJustReleased(0, 38) then
                    InteractWithPizzaNPC()
                end
            else
                if uiOpen and Config.AutoCloseUIOnDistance then
                    CloseUI()
                end
            end
        end

        if uiOpen and Config.AllowUICloseWithEscape and IsControlJustReleased(0, 177) then
            CloseUI()
        end

        if isOnDuty and currentDelivery ~= nil then
            local deliveryCoords = vector3(currentDelivery.x, currentDelivery.y, currentDelivery.z)
            local deliveryDistance = #(playerCoords - deliveryCoords)

            if deliveryDistance < 15.0 then
                if Config.UseMarkers then
                    DrawMarker(Config.MarkerType, 
                        deliveryCoords.x, deliveryCoords.y, deliveryCoords.z, 
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                        Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
                        Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a, 
                        false, true, 2, false, nil, nil, false)
                end

                if deliveryDistance < 2.0 then
                    if IsPedInAnyVehicle(playerPed, false) then
                        QBCore.Functions.DrawText3D(deliveryCoords.x, deliveryCoords.y, deliveryCoords.z + 0.5, 
                            string.format(Config.Messages['exit_vehicle'], Config.UIKey))
                    else
                        QBCore.Functions.DrawText3D(deliveryCoords.x, deliveryCoords.y, deliveryCoords.z + 0.5, 
                            string.format(Config.Messages['deliver_pizza'], Config.UIKey))

                        if IsControlJustReleased(0, 38) then
                            DeliverPizzaToHouse()
                        end
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if isOnDuty and deliveryVehicle ~= nil then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if vehicle ~= deliveryVehicle then
                    QBCore.Functions.Notify(Config.Messages['not_your_vehicle'], "error")
                end
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if Config.DisableUIOnStartup and uiOpen then
        CloseUI()
    end
    Citizen.Wait(1000)
    if Config.DisableUIOnStartup and uiOpen then
        CloseUI()
    end

    CreatePizzaNPC()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if uiOpen then
        CloseUI()
    end
    if isOnDuty then
        if deliveryBlip ~= nil then
            RemoveBlip(deliveryBlip)
        end
        if deliveryVehicle ~= nil then
            QBCore.Functions.DeleteVehicle(deliveryVehicle)
        end
    end

    if pizzaPed ~= nil then
        DeletePed(pizzaPed)
        pizzaPed = nil
    end
end)