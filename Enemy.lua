friendList = {'oMerda'}
enemyList = {''}

for index, name in ipairs(friendList) do
    friendList[name:lower():trim()] = true
    friendList[index] = nil
end

for index, value in ipairs(enemyList) do
    enemyList[value:lower():trim()] = true
    enemyList[index] = nil
end

stopTime = 0

onCreaturePositionChange(function(creature, newPos, oldPos)
    if not creature:isPlayer() or not oldPos or not newPos then
        return
    end

    newPos = newPos.x .. ',' .. newPos.y .. ',' .. newPos.z
    if newPos ~= creature.lastPos then
        creature.whiteList = nil
        creature.lastPos = newPos
    end
end)

local function shouldAttack(creature, specName)
    return (not friendList[specName] and creature ~= player) or enemyList[specName]
end

local function isInRange(pos1, pos2, maxDist)
    return getDistanceBetween(pos1, pos2) <= maxDist
end

macro(100, 'Enemy', function()
    if isInPz() then return end
    local pos = pos()
    local actualTarget, actualTargetPos, actualTargetHp
    
    for _, creature in ipairs(getSpectators(pos)) do
        local specHp = creature:getHealthPercent()
        local specPos = creature:getPosition()
        local specName = creature:getName():lower()
        
        if not creature.whiteList and creature:isPlayer() and specHp and specHp > 0 
           and specHp <= 95 and isInRange(pos, specPos, 6) then
            if shouldAttack(creature, specName) and creature:getEmblem() ~= 4 
               and creature:getShield() ~= 3 and creature:canShoot() then
                if not actualTarget or actualTargetHp > specHp 
                   or (actualTargetHp == specHp and getDistanceBetween(pos, actualTargetPos) > getDistanceBetween(specPos, pos)) then
                    actualTarget, actualTargetPos, actualTargetHp = creature, specPos, specHp
                end
            end
        end
    end
    
    if actualTarget and g_game.getAttackingCreature() ~= actualTarget then
        modules.game_interface.processMouseAction(nil, 2, pos, nil, actualTarget, actualTarget)
    end
end)

macro(100, 'Attack PK', function()
    if isInPz() then return end
    local pos = pos()
    local actualTarget, actualTargetPos, actualTargetHp
    
    for _, creature in ipairs(getSpectators(pos)) do
        local specHp = creature:getHealthPercent()
        local specPos = creature:getPosition()
        local specName = creature:getName():lower()
        
        if not creature.whiteList and creature:isPlayer() and specHp and specHp > 0 
           and creature:getSkull() ~= 0 and isInRange(pos, specPos, 6) then
            if shouldAttack(creature, specName) and creature:getEmblem() ~= 1 
               and creature:getShield() < 3 and creature:canShoot() then
                if not actualTarget or actualTargetHp > specHp 
                   or (actualTargetHp == specHp and getDistanceBetween(pos, actualTargetPos) > getDistanceBetween(specPos, pos)) then
                    actualTarget, actualTargetPos, actualTargetHp = creature, specPos, specHp
                end
            end
        end
    end
    
    if actualTarget and g_game.getAttackingCreature() ~= actualTarget then
        modules.game_interface.processMouseAction(nil, 2, pos, nil, actualTarget, actualTarget)
    end
end)

onTextMessage(function(mode, text)
    if text == 'You may not attack a person in a protection zone.' or text == 'You may not attack this player.' or text == 'This action is not permitted in a protection zone.' then
        local target = g_game.getAttackingCreature()
        if target then
            target.whiteList = true
        end
    end
end)
