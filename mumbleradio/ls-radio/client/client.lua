
--===============================================================================
--=== Edited By skiddle pumpkin#0001 4 MERCURY RP================================
--===================== Direitos Reservados ao Mercury RP =======================
--===============================================================================


-- ESX

ESX = nil
local PlayerData                = {}
local phoneProp = 0

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(10)
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)


local radioMenu = false

function PrintChatMessage(text)
    TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end

function newPhoneProp()
  deletePhone()
  RequestModel("prop_cs_walkie_talkie")
  while not HasModelLoaded("prop_cs_walkie_talkie") do
    Citizen.Wait(1)
  end

  phoneProp = CreateObject("prop_cs_walkie_talkie", 1.0, 1.0, 1.0, 1, 1, 0)
  local bone = GetPedBoneIndex(PlayerPedId(), 28422)
  AttachEntityToEntity(phoneProp, PlayerPedId(), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
end

function deletePhone()
  if phoneProp ~= 0 then
    Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(phoneProp))
    phoneProp = 0
  end
end

function enableRadio(enable)
  if enable then
    local dict = "cellphone@"
    if IsPedInAnyVehicle(PlayerPedId(), false) then
      dict = "anim@cellphone@in_car@ps"
    end

    loadAnimDict(dict)

    local anim = "cellphone_call_to_text"
    TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, -1, -1, 50, 0, false, false, false)
    newPhoneProp()
  else
    ClearPedSecondaryTask(PlayerPedId())
    deletePhone()
  end

  SetNuiFocus(true, true)
  radioMenu = enable
  SendNUIMessage({
    type = "enableui",
    enable = enable
  })

end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

--- sprawdza czy komenda /radio jest włączony

RegisterCommand('radio', function(source, args)
    if Config.enableCmd then
      enableRadio(true)
    end
end, false)

--[[ RegisterCommand('radiotest', function(source, args)
  local playerName = GetPlayerName(PlayerId())
  local data = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

  print(tonumber(data))

  if data == "nil" then
    exports['mythic_notify']:SendAlert('inform', Config.messages['not_on_radio'])
  else
   exports['mythic_notify']:SendAlert('inform', Config.messages['on_radio'] .. data .. '.00 MHz </b>')
 end

end, false) ]]

-- dołączanie do radia

RegisterNUICallback('joinRadio', function(data, cb)
    local _source = source
    local PlayerData = ESX.GetPlayerData(_source)
    local playerName = GetPlayerName(PlayerId())
--[[     local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel") ]]

    if tonumber(data.channel) then
      if tonumber(data.channel) == 999 then
        
        
      end
        if tonumber(data.channel) <= Config.RestrictedChannels then
          if(PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then
            exports["mumble-voip"]:SetRadioChannel(tonumber(data.channel))
            --exports['mythic_notify']:SendAlert('inform', Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>')
			TriggerEvent("notification",  Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>', 1)
          elseif not (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance') then
            --- info że nie możesz dołączyć bo nie jesteś policjantem
            exports['mythic_notify']:SendAlert('error', Config.messages['restricted_channel_error'])
			TriggerEvent("notification",  Config.messages['restricted_channel_error'], 2)
          end
        end
        if tonumber(data.channel) > Config.RestrictedChannels then
          exports["mumble-voip"]:SetRadioChannel(tonumber(data.channel))
          --exports['mythic_notify']:SendAlert('inform', Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>')
		  TriggerEvent("notification",  Config.messages['joined_to_radio'] .. data.channel .. '.00 MHz </b>', 1)
        end
      else
       -- exports['mythic_notify']:SendAlert('error', Config.messages['you_on_radio'] .. data.channel .. '.00 MHz </b>')
		--TriggerEvent("notification",  Config.messages['you_on_radio'] .. data.channel .. '.00 MHz </b>', 2)
      end
      --[[
    exports.tokovoip_script:removePlayerFromRadio(getPlayerRadioChannel)
    exports.tokovoip_script:setPlayerData(playerName, "radio:channel", tonumber(data.channel), true);
    exports.tokovoip_script:addPlayerToRadio(tonumber(data.channel))
    PrintChatMessage("radio: " .. data.channel)
    print('radiook')
      ]]--
    cb('ok')
end)

-- opuszczanie radia

RegisterNUICallback('leaveRadio', function(data, cb)
   local playerName = GetPlayerName(PlayerId())
  --local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel")

   -- if getPlayerRadioChannel == "nil" then
    --  exports['mythic_notify']:SendAlert('inform', Config.messages['not_on_radio'])
     --   else
	 TriggerEvent("notification",  Config.messages['you_leave'], 3)
          exports["mumble-voip"]:SetRadioChannel(0)
         
   -- end

   cb('ok')

end)

RegisterNUICallback('escape', function(data, cb)

    enableRadio(false)
    SetNuiFocus(false, false)


    cb('ok')
end)

-- net eventy

RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
  enableRadio(true)
end)

RegisterNetEvent('ls-radio:onRadioDrop')
AddEventHandler('ls-radio:onRadioDrop', function()
  local playerName = GetPlayerName(PlayerId())
--[[   local getPlayerRadioChannel = exports.tokovoip_script:getPlayerData(playerName, "radio:channel") ]]
  --if getPlayerRadioChannel ~= "nil" then
    exports["mumble-voip"]:SetRadioChannel(0)
    --exports['mythic_notify']:SendAlert('inform', Config.messages['you_leave'] .. getPlayerRadioChannel .. '.00 MHz </b>')
 -- end
end)

Citizen.CreateThread(function()
    while true do
        if radioMenu then
            DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown
            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        else
          Citizen.Wait(1500)
        end
        Citizen.Wait(10)
    end
end)
