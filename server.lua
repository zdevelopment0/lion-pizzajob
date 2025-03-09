local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-pizzajob:server:PayForDelivery', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.AddMoney(Config.PaymentType, amount, "pizza-delivery-payment")
        TriggerClientEvent('QBCore:Notify', src, string.format(Config.Messages['delivery_complete'], amount), "success")
    end
end)

RegisterNetEvent('qb-pizzajob:server:GiveBag', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player and Config.RequireBag then
        Player.Functions.AddItem(Config.BagItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.BagItem], "add")
    end
end)

RegisterNetEvent('qb-pizzajob:server:ReturnBag', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player and Config.RequireBag then
        if Player.Functions.RemoveItem(Config.BagItem, 1) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.BagItem], "remove")
        end
    end
end)

Citizen.CreateThread(function()
    if Config.RequireBag then
        print("^2[qb-pizzajob]^7: Pizza Bag Item kullanılıyor. QBCore SharedItems.lua'da aşağıdaki item'in olduğundan emin olun:")
        print("^3['pizza_bag'] = {name = 'pizza_bag', label = 'Pizza Çantası', weight = 500, type = 'item', image = 'pizza_bag.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Pizza taşımak için sıcak tutan bir çanta.'}^7")
    end
end)