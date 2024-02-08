-----------------------------------
-- Area: Caedarva Mire
--   NM: Khimaira
-----------------------------------
require("scripts/globals/titles")
-----------------------------------
local entity = {}

local drawInPos =
{
    { x = 838.88, y =  0.00, z = 358.86 },
    { x = 834.93, y = -0.14, z = 363.68 },
    { x = 840.13, y = -0.31, z = 366.46 },
    { x = 842.69, y =  0.00, z = 360.12 },
    { x = 846.15, y = -0.27, z = 360.25 },
    { x = 845.30, y = -0.51, z = 366.68 },
    { x = 850.33, y = -1.34, z = 365.43 },
    { x = 850.40, y = -1.45, z = 355.85 },
}

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.WEAPON_BONUS, 53) -- level 85 + 2 + 53 = 140 base weapon dmg
    mob:setMod(xi.mod.DEF, 500) -- 500 + X gives 570 DEF
    mob:setMod(xi.mod.EVA, 330) -- 330 + x gives 358
    mob:setMod(xi.mod.ATT, 700) -- 740 + X gives 740 ATT
    mob:setMod(xi.mod.STUNRESBUILD, 10) -- one second less for each stun
    mob:setMod(xi.mod.UDMGMAGIC, -2500)
    mob:addImmunity(xi.immunity.SLEEP)
    mob:addImmunity(xi.immunity.TERROR)
end

entity.onMobRoam = function(mob)
    if mob:getLocalVar("timeToWingsUp") ~= 0 then
        mob:setLocalVar("timeToWingsUp", 0)
        mob:setAnimationSub(0)
    end
end

entity.onMobFight = function(mob, target)
    local timeToWingsUp = mob:getLocalVar("timeToWingsUp")
    local currentTime = os.time()

    if
        timeToWingsUp ~= 0 and
        timeToWingsUp < currentTime
    then
        mob:setLocalVar("timeToWingsUp", 0)
        mob:setAnimationSub(0)
    end

    if
        (target:getXPos() < 814 or target:getXPos() > 865 or
        target:getZPos() < 345 or target:getZPos() > 377) and
        os.time() > mob:getLocalVar("DrawInWait")
    then
        local pos = math.random(1, 8)

        target:setPos(drawInPos[pos])
        mob:messageBasic(232, 0, 0, target)
        mob:setLocalVar("DrawInWait", os.time() + 2)
    end
end

entity.onCriticalHit = function(mob)
    local timeToWingsUp = mob:getLocalVar("timeToWingsUp")

    if
        timeToWingsUp == 0 and
        -- 5% chance to break on crit hit
        math.random(1, 20) == 20
    then
        mob:setAnimationSub(1)
        mob:setLocalVar("timeToWingsUp", os.time() + math.random(180, 420))   
    end
end

entity.onMobDeath = function(mob, player, optParams)
    player:addTitle(xi.title.KHIMAIRA_CARVER)
end

entity.onMobDespawn = function(mob)
    mob:setRespawnTime(math.random(48, 72) * 3600) -- 48 to 72 hours, in 1-hour increments
end

return entity
