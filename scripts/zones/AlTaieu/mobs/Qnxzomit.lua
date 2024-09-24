-----------------------------------
-- Area: Al'Taieu
--  Mob: Qn'xzomit
-- Note: Pet for JOJ and JOL
-----------------------------------
local ID = require("scripts/zones/AlTaieu/IDs")
-----------------------------------
local entity = {}

entity.onMobEngaged = function(mob)
    if mob:getID() < ID.mob.JAILER_OF_LOVE then
        mob:timer(30000, function(mobArg)
            if mobArg:isAlive() then
                mobArg:useMobAbility(xi.jsa.MIJIN_GAKURE)
                mobArg:timer(2000, function(mobArg2)
                    mobArg2:setHP(0)
                end)
            end
        end)

        mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
        mob:addStatusEffectEx(xi.effect.FLEE, 0, 100, 0, 60)
    end
end

entity.onMobDespawn = function(mob)
    if mob:getID() > ID.mob.JAILER_OF_LOVE then
        local jailerOfLove = GetMobByID(ID.mob.JAILER_OF_LOVE)
        local xzomitsKilled = jailerOfLove:getLocalVar("JoL_Qn_xzomit_Killed")
        jailerOfLove:setLocalVar("JoL_Qn_xzomit_Killed", xzomitsKilled + 1)
    end
end

return entity
