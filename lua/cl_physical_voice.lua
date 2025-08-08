local IsNearlyEqual = math.IsNearlyEqual

local lply = LocalPlayer()


local function SendVoiceVolume()
    local volume = lply:VoiceVolume()
    
    if IsNearlyEqual(volume, 0, 1e-2) then return end

    net.Start("PhysicalVoice")
        net.WriteFloat(volume)
    net.SendToServer()
end


hook.Add("PlayerStartVoice", "PhysicalVoice", function(ply)
    if ply ~= lply then return end

    timer.Create("PhysicalVoice", 0.1, 0, SendVoiceVolume)
end)

hook.Add("PlayerEndVoice", "PhysicalVoice", function(ply)
    if ply ~= lply then return end
    
    timer.Remove("PhysicalVoice")
end)