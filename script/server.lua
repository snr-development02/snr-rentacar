-- SNR STORE | https://discord.gg/TtHFpf3enK
local QBCore = nil
local ESX = nil
    
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if Config.ESXorQBorNewQB == "esx" then
            ESX = nil
            Citizen.CreateThread(function()
                while ESX == nil do
                    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                    Citizen.Wait(0)
                end
                ESX.PlayerData = ESX.GetPlayerData()
            end)
	        break
        elseif Config.ESXorQBorNewQB == "qb" then
            QBCore = nil
            Citizen.CreateThread(function()
            while QBCore == nil do
                TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
                Citizen.Wait(30) -- Saniye Bekletme
            end
            end)
	        break
        elseif Config.ESXorQBorNewQB == "newqb" then
            QBCore = exports['qb-core']:GetCoreObject()
	        break
        else
            Citizen.CreateThread(function()
                while true do
                    Citizen.Wait(500)
                    print(locale.uyari)
                end
            end)
        end
    end
end)

Citizen.Wait(3000)
print("Selected Core: " .. Config.ESXorQBorNewQB)

RegisterNetEvent('snr:rental:print')
AddEventHandler('snr:rental:print', function(yazi)
    print(yazi)
end)

if Config.ESXorQBorNewQB == "esx" then
    local PlakalarAracKiralama = {}

    ESX.RegisterServerCallback("snr:kira-kontrol", function(source, cb, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if PlakalarAracKiralama[xPlayer.identifier] then
        TriggerEvent('Notification', locale.youalreadyhaveacar)
        cb(false)
    else
        if xPlayer.removeAccountMoney("bank", price) then
            local plate = "K"..src
            PlakalarAracKiralama[xPlayer.identifier] = {
                plate = plate,
                price = price/2
            }
            cb(true, plate)
        else
            TriggerEvent('Notification', locale.youdonthavemoney)
            cb(false)
        end
    end
    end)

    ESX.RegisterServerCallback("snr:aracBirak", function(source, cb, plate)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        if PlakalarAracKiralama[xPlayer.identifier] then
            if PlakalarAracKiralama[xPlayer.identifier].plate == ESX.Math.Trim(plate) then
                xPlayer.addMoney(PlakalarAracKiralama[xPlayer.identifier].price)
                TriggerEvent('Notification', "Aracı İade Ettin, $"..PlakalarAracKiralama[xPlayer.identifier].price.." Banka Hesabına Yatırıldı!")
                PlakalarAracKiralama[xPlayer.identifier] = nil
                cb(true)
            else
                TriggerEvent('Notification', locale.itsnotyourrentalcar)
                cb(false)
            end
        else
            TriggerEvent('Notification', locale.youdontgaverentalcar)
            cb(false)
        end
    end)

else
    local PlakalarAracKiralama = {}

    QBCore.Functions.CreateCallback("snr:kira-kontrol", function(source, cb, price)
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if PlakalarAracKiralama[xPlayer.PlayerData.citizenid] then
            TriggerClientEvent("QBCore:Notify", src, locale.youalreadyhaveacar, "error")
            cb(false)
        else
            if xPlayer.Functions.RemoveMoney("bank", price) then
                local plate = "K"..src
                PlakalarAracKiralama[xPlayer.PlayerData.citizenid] = {
                    plate = plate,
                    price = price/2
                }
                cb(true, plate)
            else
                TriggerClientEvent("QBCore:Notify", src, locale.youdonthavemoney, "error")
                cb(false)
            end
        end
    end)

    QBCore.Functions.CreateCallback("snr:aracBirak", function(source, cb, plate)
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if PlakalarAracKiralama[xPlayer.PlayerData.citizenid] then
            if PlakalarAracKiralama[xPlayer.PlayerData.citizenid].plate == QBCore.Shared.Trim(plate) then
                xPlayer.Functions.AddMoney('bank', PlakalarAracKiralama[xPlayer.PlayerData.citizenid].price)
                TriggerClientEvent("QBCore:Notify", src, "Aracı İade Ettin, $"..PlakalarAracKiralama[xPlayer.PlayerData.citizenid].price.." Banka Hesabına Yatırıldı!")
                PlakalarAracKiralama[xPlayer.PlayerData.citizenid] = nil
                cb(true)
            else
                TriggerClientEvent("QBCore:Notify", src, locale.itsnotyourrentalcar, "error")
                cb(false)
            end
        else
            TriggerClientEvent("QBCore:Notify", src, locale.youdontgaverentalcar, "error")
            cb(false)
        end
    end)
end