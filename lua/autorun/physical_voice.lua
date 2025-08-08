if SERVER then
    
    AddCSLuaFile("cl_physical_voice.lua")

    include("sv_physical_voice.lua")

else

    hook.Add("InitPostEntity", "PhysicalVoice", function()
        include("cl_physical_voice.lua")

        hook.Remove("InitPostEntity", "PhysicalVoice")
    end)

end