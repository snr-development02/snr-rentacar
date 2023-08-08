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
                    TriggerServerEvent("snr:rental:print", locale.uyari)
                end
            end)
        end
    end
end)

RegisterNetEvent('snr:rental:menuac')
AddEventHandler('snr:rental:menuac', function()
    WarMenu.OpenMenu('snrrental')
end)

local snroptimized = 500
local NPCandBlipandDrawtextCoords = Config.NPCandBLIPandDrawtextCoords
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(snroptimized)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local mesafe = #(NPCandBlipandDrawtextCoords - playerCoords)
        if mesafe < 8 then
            if Config.Target == true then
                if Config.ESXorQBorNewQB == "esx" then
                    TriggerServerEvent("snr:rental:print", "İf you using ESX you dont use qb-target function! Please change snr-rentacar/config.lua Config.Target = true to false")
                else
                    exports["qb-target"]:AddBoxZone(
                        "RentaCar",
                        NPCandBlipandDrawtextCoords,
                        2,
                        2,
                        {
                            name = "RentaCar",
                            heading = 1,
                            debugPoly = false,
                            minZ = 0.669,
                            maxZ = 999.87834
                        },
                        {
                            options = {
                                {
                                    type = "Client",
                                    event = "snr:rental:menuac",
                                    icon = "fas fa-circle",
                                    label = locale.targetrentacar
                                }
                            },
                            distance = 1.5
                        }
                    )
                end
            else
                snroptimized = 0
                DrawText3D(NPCandBlipandDrawtextCoords , locale.drawtext)
                if mesafe < 1.8 then
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent("snr:rental:menuac")
                    end
                end
            end
        else
            snroptimized = 1000
        end
    end
end)

Citizen.CreateThread(function()
    local menus = {
        "snrrental",
        "rentalveh",
        "rentalreturnveh",
    }

    WarMenu.CreateMenu('snrrental', 'Car Rental')
    WarMenu.CreateSubMenu('rentalveh', 'snrrental')
    WarMenu.CreateSubMenu('rentalreturnveh', 'snrrental')
    for k, v in pairs(menus) do
        WarMenu.SetMenuX(v, 0.71)
        WarMenu.SetMenuY(v, 0.15)
        WarMenu.SetMenuWidth(v, 0.23)
        WarMenu.SetTitleColor(v, 255, 255, 255, 255)
        WarMenu.SetTitleBackgroundColor(v, 0, 0, 0, 111)
    end
    while true do
        if WarMenu.IsMenuOpened('snrrental') then
            WarMenu.MenuButton(locale.menurentalvehicles, 'rentalveh')
            WarMenu.MenuButton(locale.menureturnvehicle, 'rentalreturnveh')
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('rentalveh') then
            if WarMenu.Button('Panto') then
                snrarackirala("panto", 500)
            end
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('rentalreturnveh') then
            if WarMenu.Button(locale.returvehiclebutton) then
                snraraciade()
            end
            WarMenu.Display()
        end
        Citizen.Wait(3)
    end
end)

function snrarackirala(aracmodeli, fiyat)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local mesafe = #(NPCandBlipandDrawtextCoords - playerCoords)
    if mesafe < 8 then
        if Config.ESXorQBorNewQB == "esx" then
            ESX.TriggerServerCallback("snr:kira-kontrol", function(durum, plaka)
                print(durum)
                if durum then
                    local coords = Config.Kordinat["araba"].coords
                    local heading = Config.Kordinat["araba"].heading
                    ESX.Game.SpawnVehicle(aracmodeli, function(yourVehicle)
                        local vehicleProps = {}
                            vehicleProps.plate = plaka
                            ESX.Game.SetVehicleProperties(yourVehicle, vehicleProps)
                            NetworkFadeInEntity(yourVehicle, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)
                            SetVehicleHasBeenOwnedByPlayer(yourVehicle, true)
                            local id = NetworkGetNetworkIdFromEntity(yourVehicle)
                            SetNetworkIdCanMigrate(id, true)
                            SetVehicleFuelLevel(yourVehicle, 90.0)
                            DecorSetFloat(yourVehicle, "_FUEL_LEVEL", 90.0)
                            if Config.Hotwire == true then
                                TriggerEvent(Config.HotwireTrigger, yourVehicle)
                            end
                            ESX.ShowHelpNotification(locale.carspawned)
                    end, coords, true)
                end
            end, fiyat)
        else
            QBCore.Functions.TriggerCallback("snr:kira-kontrol", function(durum, plaka)
                print(durum)
                if durum then
                    local coords = Config.Kordinat["araba"].coords
                    local heading = Config.Kordinat["araba"].heading
                    QBCore.Functions.SpawnVehicle(aracmodeli, function(yourVehicle)
                        local vehicleProps = {}
                            vehicleProps.plate = plaka
                            QBCore.Functions.SetVehicleProperties(yourVehicle, vehicleProps)
                            NetworkFadeInEntity(yourVehicle, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)
                            SetVehicleHasBeenOwnedByPlayer(yourVehicle, true)
                            local id = NetworkGetNetworkIdFromEntity(yourVehicle)
                            SetNetworkIdCanMigrate(id, true)
                            SetVehicleFuelLevel(yourVehicle, 90.0)
                            DecorSetFloat(yourVehicle, "_FUEL_LEVEL", 90.0)  
                            if Config.Hotwire == true then
                                TriggerEvent(Config.HotwireTrigger, yourVehicle)
                            end                
                            QBCore.Functions.Notify(locale.carspawned)
                    end, coords, true)
                end
            end, fiyat)
        end
    end
end

function snraraciade()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local mesafe = #(NPCandBlipandDrawtextCoords - playerCoords)
    if mesafe < 8 then
        if IsPedInAnyVehicle(PlayerPedId()) then
            local Arac = GetVehiclePedIsUsing(PlayerPedId())
                local Plaka = QBCore.Shared.Trim(GetVehicleNumberPlateText(Arac))
            if string.starts(Plaka, "K") and (string.match(Plaka, "K%d") or string.match(Plaka, "K%d%d") or string.match(Plaka, "K%d%d%d")) then
                local free = true
                for i=1, GetVehicleModelNumberOfSeats(GetEntityModel(Arac)) do
                    if i ~= 1 then
                        if not IsVehicleSeatFree(Arac, i-2) then 
                            if Config.ESXorQBorNewQB == "esx" then
                                ESX.ShowHelpNotification(locale.incaranyplayer)
                            else
                                QBCore.Functions.Notify(locale.incaranyplayer)
                            end
                            free = false
                        end
                    end
                end

                if free then
                    if Config.ESXorQBorNewQB == "esx" then
                        ESX.TriggerServerCallback("snr:aracBirak", function(durum)
                            if durum then
                                if DoesEntityExist(Arac) then
                                    TaskLeaveVehicle(playerPed, Arac, 0)
                                    while IsPedInVehicle(playerPed, Arac, true) do
                                        Citizen.Wait(0)
                                    end
                                    NetworkFadeOutEntity(Arac, true, true)
                                    Citizen.Wait(100)
                                    ESX.Game.DeleteVehicle(Arac)
                                end
                            end
                        end, Plaka)
                    else
                        QBCore.Functions.TriggerCallback("snr:aracBirak", function(durum)
                            if durum then
                                if DoesEntityExist(Arac) then
                                    TaskLeaveVehicle(playerPed, Arac, 0)
                                    while IsPedInVehicle(playerPed, Arac, true) do
                                        Citizen.Wait(0)
                                    end
                                    NetworkFadeOutEntity(Arac, true, true)
                                    Citizen.Wait(100)
                                    QBCore.Functions.DeleteVehicle(Arac)
                                end
                            end
                        end, Plaka)
                    end
                end
            else
                if Config.ESXorQBorNewQB == "esx" then
                    ESX.ShowHelpNotification(locale.thiscarnotrental)
                else
                    QBCore.Functions.Notify(locale.thiscarnotrental, "error")
                end
            end
        end
    end
end

function string.starts(String,Start)
    return string.sub(String,1,#Start)==Start
end

Citizen.CreateThread(function()
    if Config.blip == true then
        local gblip = AddBlipForCoord(NPCandBlipandDrawtextCoords)
        SetBlipSprite(gblip, 475)
        SetBlipDisplay(gblip, 4)
        SetBlipScale (gblip, 0.7)
        SetBlipColour(gblip, 4)
        SetBlipAsShortRange(gblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.RentalBlipIsim)
        EndTextCommandSetBlipName(gblip)
    end
end)



Citizen.CreateThread(function()
    if Config.NPCOlsunmu == true then
        RequestModel(Config.NPCKodu)
        while not HasModelLoaded(Config.NPCKodu) do
            Wait(1)
        end
    
        snrstore = CreatePed(1, Config.NPCKodu, Config.NPCKonumu.x, Config.NPCKonumu.y, Config.NPCKonumu.z-1, Config.NPCKonumu.h, false, true)
        SetBlockingOfNonTemporaryEvents(snrstore, true)
        SetPedDiesWhenInjured(snrstore, false)
        SetPedCanPlayAmbientAnims(snrstore, true)
        SetPedCanRagdollFromPlayerImpact(snrstore, false)
        SetEntityInvincible(snrstore, true)
        FreezeEntityPosition(snrstore, true)
        TaskStartScenarioInPlace(snrstore, "WORLD_HUMAN_CLIPBOARD", 0, true);
    end
end)

function DrawText3D(coord, text)
	local onScreen,_x,_y=GetScreenCoordFromWorldCoord(coord.x, coord.y, coord.z)
	local px,py,pz=table.unpack(GetGameplayCamCoords()) 
	local scale = 0.3
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropshadow(0)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 380
        DrawRect(_x, _y + 0.0120, 0.0 + factor, 0.025, 41, 11, 41, 100)
	end
end
