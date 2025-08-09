local IsNearlyEqual = math.IsNearlyEqual

local lply = LocalPlayer()

local CVAR_ENABLED = CreateClientConVar("pv_enabled_cl", 1, nil, nil, "Make your voice physically affect world")
local CVAR_VOLUME_MULT = CreateClientConVar("pv_volume_mult", 1.0, nil, nil, "Voice volume multiplier", 1.0, 10.0)


local function SendVoiceVolume()
    local volume = lply:VoiceVolume()
    
    if IsNearlyEqual(volume, 0, 1e-2) then return end

    net.Start("PhysicalVoice")
        net.WriteFloat(volume * CVAR_VOLUME_MULT:GetFloat())
    net.SendToServer()
end


local function PlayerStartVoice(ply)
    if ply ~= lply then return end

    timer.Create("PhysicalVoice", 0.1, 0, SendVoiceVolume)
end

local function PlayerEndVoice(ply)
    if ply ~= lply then return end
    
    timer.Remove("PhysicalVoice")
end


local function Enable()
    hook.Add("PlayerStartVoice",    "PhysicalVoice", PlayerStartVoice)
    hook.Add("PlayerEndVoice",      "PhysicalVoice", PlayerEndVoice)
end

local function Disable()
    hook.Remove("PlayerStartVoice", "PhysicalVoice")
    hook.Remove("PlayerEndVoice",   "PhysicalVoice")
end


if CVAR_ENABLED:GetBool() then
    Enable()
end

cvars.AddChangeCallback(CVAR_ENABLED:GetName(), function(_, _, value)
    if tobool(value) then
        Enable()
    else
        Disable()
    end
end)