if SERVER then
    
    AddCSLuaFile("cl_physical_voice.lua")

    include("sv_physical_voice.lua")

else

    hook.Add("InitPostEntity", "PhysicalVoice", function()
        include("cl_physical_voice.lua")

        hook.Remove("InitPostEntity", "PhysicalVoice")
    end)


    hook.Add("PopulateToolMenu", "PhysicalVoice", function()
        spawnmenu.AddToolMenuOption("Utilities", "User", "PhysicalVoiceCLSettings", "#spawnmenu.utilities.physical_voice", "", "", function(cpanel)
            cpanel:CheckBox("#pv.settings.enabled", "pv_enabled_cl")

            
            cpanel:NumSlider("#pv.settings.volume_mult", "pv_volume_mult", 0.0, 10.0)
        end)

        spawnmenu.AddToolMenuOption("Utilities", "Admin", "PhysicalVoiceSVSettings", "#spawnmenu.utilities.physical_voice", "", "", function(cpanel)
            cpanel:CheckBox("#pv.settings.enabled", "pv_enabled_sv")


            cpanel:NumSlider("#pv.settings.search_distance", "pv_search_distance", 0, 9999, 0)

            cpanel:NumSlider("#pv.settings.search_angle", "pv_search_angle", 0, 180, 0)
            cpanel:ControlHelp("#pv.settings.search_angle.help")

            cpanel:NumSlider("#pv.settings.force", "pv_force", 0, 10000, 0)

            cpanel:NumSlider("#pv.settings.force_player", "pv_force_player", 0.0, 1.0)
            cpanel:ControlHelp("#pv.settings.force_player.help")
            
            cpanel:NumSlider("#pv.settings.force_direction_up", "pv_force_direction_up", 0.0, 1.0)
            cpanel:ControlHelp("#pv.settings.force_direction_up.help")
            
            cpanel:NumSlider("#pv.settings.damage", "pv_damage", 0, 1000, 0)
            
            cpanel:NumSlider("#pv.settings.unfreeze_volume", "pv_unfreeze_volume", 0.0, 1.0)
            cpanel:ControlHelp("#pv.settings.unfreeze_volume.help")
        end)
    end)

end