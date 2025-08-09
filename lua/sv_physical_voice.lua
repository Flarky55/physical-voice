local Clamp = math.Clamp


local callback_value = function(func)
    return function(_, _, value) func(value) end
end


local CVAR_ENABLED = CreateConVar("pv_enabled_sv", 1, nil, "Allow players to physically affect world by their voice")

local CVAR_SEARCH_DISTANCE    = CreateConVar("pv_search_distance", 300, nil, "Entity search distance around player", 0)
local CVAR_SEARCH_ANGLE       = CreateConVar("pv_search_angle", 90, nil, "Full angle of search cone (0 to use search in sphere)", 0, 180)

local CVAR_FORCE                = CreateConVar("pv_force", 1000, nil, "Default force")
local CVAR_FORCE_PLAYER         = CreateConVar("pv_force_player", 0.05, nil, "Percentage of default force applied to players")
local CVAR_FORCE_DIRECTION_UP   = CreateConVar("pv_force_direction_up", 0.3, nil, "Percentage of upward force direction added to player's voice direction", 0.0, 1.0)

local CVAR_DAMAGE           = CreateConVar("pv_damage", 100, nil, "Default damage value")
local CVAR_UNFREEZE_VOLUME  = CreateConVar("pv_unfreeze_volume", 0.5, nil, "Minimum volume required to unfreeze entity", 0.0, 1.0)

local DISTANCE, DISTANCE_SQUARED
do
    local setup = function(value)
        DISTANCE            = value
        DISTANCE_SQUARED    = value^2
    end

    cvars.AddChangeCallback(CVAR_SEARCH_DISTANCE:GetName(), callback_value(setup))

    setup(CVAR_SEARCH_DISTANCE:GetInt())
end

local USE_SPHERE_SEARCH, CONE_ANGLE_COS
do
    local setup = function(value)
        USE_SPHERE_SEARCH = value == 0

        if not USE_SPHERE_SEARCH then
            CONE_ANGLE_COS = math.cos(math.rad(value / 2))
        end
    end

    cvars.AddChangeCallback(CVAR_SEARCH_ANGLE:GetName(), callback_value(setup))

    setup(CVAR_SEARCH_ANGLE:GetInt())
end


util.AddNetworkString("PhysicalVoice")


local function TakeVoicePhysicsDamage(ent, volume, attacker)
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end

    local pos_ent, pos_attacker = ent:GetPos(), attacker:GetPos()
    local distance_sqr = pos_ent:DistToSqr(pos_attacker)

    local distance_frac = 1.0 - math.min(distance_sqr / DISTANCE_SQUARED, 1.0)
    local distance_mult = 0.5 + 0.5 * distance_frac

    local dir = (pos_ent - pos_attacker)
    dir:Normalize()
    dir:Add(vector_up * CVAR_FORCE_DIRECTION_UP:GetFloat())


    local force = phys:GetMass() * dir
    force:Mul(CVAR_FORCE:GetInt() * volume * distance_mult)

    local damage = CVAR_DAMAGE:GetInt() * volume * distance_mult


    if ent:IsPlayer() then
        ent:SetVelocity(force * CVAR_FORCE_PLAYER:GetFloat())
    else
        if not phys:IsMotionEnabled() and volume >= CVAR_UNFREEZE_VOLUME:GetFloat() then
            phys:EnableMotion(true)
        end
    end

    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(damage)
    dmgInfo:SetDamageForce(force)
    dmgInfo:SetDamagePosition(pos_ent)
    dmgInfo:SetDamageType(DMG_SONIC)
    dmgInfo:SetAttacker(attacker)

    ent:TakeDamageInfo(dmgInfo)
end

local function PhysicalVoice_Receive(len, ply)
    -- TODO: Prevent possible net-spam
    local volume = net.ReadFloat()
    volume = Clamp(volume, 0.0, 1.0)

    local entities = USE_SPHERE_SEARCH 
                        and ents.FindInSphere(ply:GetPos(), DISTANCE) 
                        or  ents.FindInCone(ply:EyePos(), ply:GetAimVector(), DISTANCE, CONE_ANGLE_COS)

    for i = 1, #entities do
        local ent = entities[i]

        if ent ~= ply then
            TakeVoicePhysicsDamage(ent, volume, ply)
        end
    end
end


if CVAR_ENABLED:GetBool() then
    net.Receive("PhysicalVoice", PhysicalVoice_Receive) 
end

cvars.AddChangeCallback(CVAR_ENABLED:GetName(), function(_, _, value)
    net.Receive("PhysicalVoice", Either(tobool(value), PhysicalVoice_Receive, nil))
end)