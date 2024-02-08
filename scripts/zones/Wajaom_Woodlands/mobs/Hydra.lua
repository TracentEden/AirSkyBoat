-----------------------------------
-- Area: Wajaom Woodlands
--  Mob: Hydra
-- !pos -282 -24 -1 51
-----------------------------------
require("scripts/globals/titles")
-----------------------------------
local entity = {}

local drawInPos =
{
    { x = -280.20, y = -23.88, z =  -5.94 },
    { x = -272.08, y = -23.75, z =  -1.73 },
    { x = -276.90, y = -24.00, z =   2.09 },
    { x = -268.59, y = -23.96, z = -16.00 },
    { x = -285.57, y = -24.20, z =  -0.56 },
    { x = -282.16, y = -24.00, z =   1.95 },
    { x = -271.35, y = -23.66, z =  -5.46 },
    { x = -272.75, y = -23.55, z = -11.25 },
}

local animationSubToHeads = { [4] = 3, [5] = 2, [6] = 1 }
local headsToRegain = { [1] = 0, [2] = 125, [3] = 250 }
local headsToRegen = { [1] = 0, [2] = 150, [3] = 300 }

entity.getNumHeads = function(animationSub)
    return animationSubToHeads[animationSub]
end

-- adjust regen and regain based on number of heads
entity.adjustPower = function(mob, animationSub)
    print("AnimationSub: " .. tostring(animationSub))
    local heads = entity.getNumHeads(animationSub)
    print("heads: " .. tostring(heads))
    mob:setMod(xi.mod.REGEN, headsToRegen[heads])
    mob:setMod(xi.mod.REGAIN, headsToRegain[heads])
end

entity.headGrow = function(mob, animationSub)
    print("headGrow")
    local currentTime = os.time()
    mob:setAnimationSub(animationSub - 1)
    entity.adjustPower(mob, animationSub - 1)
    mob:setLocalVar("nextHeadGrow", currentTime + 300)
    mob:setLocalVar("lastHeadGrow", currentTime)
    -- always use TP move right after head growth
    mob:setTP(3000)
end

entity.headBreak = function(mob, animationSub)
    print("headBreak")
    local currentTime = os.time()
    mob:setAnimationSub(animationSub + 1)
    entity.adjustPower(mob)
    mob:setLocalVar("nextHeadGrow", currentTime + math.random(120, 180))
end

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.WEAPON_BONUS, 48) -- level 80 + 2 + 48 = 130 base weapon dmg
    mob:setMod(xi.mod.DEF, 578) -- 580 + 52 gives 630 DEF
    mob:setMod(xi.mod.EVA, 326) -- 15% above normal
    mob:setMod(xi.mod.ATT, 915) -- 915 + 60 gives 975 ATT
    mob:setMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:setMod(xi.mod.UDMGMAGIC, -8500)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.GRAVITY)
    mob:addImmunity(xi.immunity.PARALYZE)
end

entity.onMobEngaged = function(mob, target)
    entity.adjustPower(mob)
end

entity.onMobFight = function(mob, target)
    local currentTime = os.time()
    local animationSub = mob:getAnimationSub()

    if
        entity.getNumHeads(animationSub) < 3 and
        mob:getLocalVar("nextHeadGrow") < currentTime and
        -- space out the head grows at least 30 seconds
        mob:getLocalVar("lastHeadGrow") + 30 < currentTime
    then
        entity.headGrow(mob, animationSub)
    end

    if
        (target:getXPos() < -295 or target:getXPos() > -260 or
        target:getZPos() < -25 or target:getZPos() > 13) and
        os.time() > mob:getLocalVar("DrawInWait")
    then
        local pos = math.random(1, 8)

        target:setPos(drawInPos[pos])
        mob:messageBasic(232, 0, 0, target)
        mob:setLocalVar("DrawInWait", currentTime + 2)
        -- always use TP move right after draw-in
        mob:setTP(3000)
    end
end

entity.onMobRoam = function(mob)
    local currentTime = os.time()
    local animationSub = mob:getAnimationSub()

    if
        entity.getNumHeads(animationSub) < 3 and
        mob:getLocalVar("nextHeadGrow") < currentTime and
        -- space out the head grows at least 30 seconds
        mob:getLocalVar("lastHeadGrow") + 30 < currentTime
    then
        entity.headGrow(mob, animationSub)
    end
end

entity.onMobWeaponSkill = function(target, mob, skill)
    local currentTime = os.time()
    local animationSub = mob:getAnimationSub()

    if
        entity.getNumHeads(animationSub) < 3 and
        -- space out the head grows at least 30 seconds
        mob:getLocalVar("lastHeadGrow") + 30 < currentTime and
        -- 10% chance to regrow
        math.random(1, 10) == 10
    then
        entity.headGrow(mob, animationSub)
    end
end

entity.onMobWeaponSkillPrepare = function(mob, target)
    local animationSub = mob:getAnimationSub()

    -- use nerve gas more often under certain conditions
    if
        mob:getHPP() < 25 and
        entity.getNumHeads(animationSub) == 3 and
        math.random(1, 3) == 3
    then
        return 1836
    end
end

entity.onCriticalHit = function(mob)
    local animationSub = mob:getAnimationSub()

    if
        entity.getNumHeads(animationSub) > 1 and
        math.random(1, 8) == 8
    then
        entity.headBreak(mob, animationSub)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    player:addTitle(xi.title.HYDRA_HEADHUNTER)
end

entity.onMobDespawn = function(mob)
    mob:setRespawnTime(math.random(48, 72) * 3600) -- 48 to 72 hours, in 1 hour windows
end

return entity
