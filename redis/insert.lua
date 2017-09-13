local parametrosAmbientales = {'lumenes', 'grados', 'decibelios'}

local function initializeAreaYPuesto (areaYPuesto)
  if (redis.call('GET', areaYPuesto) == nil) then
    redis.call('SET', areaYPuesto, 0)
  end
end

local function publish (channel, text)
  redis.call('PUBLISH', channel, text)
end

local areaYPuesto = KEYS[1]..':'..KEYS[2]

initializeAreaYPuesto(areaYPuesto)

local nextIndex = redis.call('INCR', areaYPuesto)
local nextKey = areaYPuesto..':'..nextIndex

redis.call('HSET', nextKey, 'tipoPuesto', KEYS[6])

for index = 1, 3 do
  local valueOfIndexMinusTwo = redis.call('HGET', areaYPuesto..':'..nextIndex - 2, parametrosAmbientales[index])
  local valueOfIndexMinusOne = redis.call('HGET', areaYPuesto..':'..nextIndex - 1, parametrosAmbientales[index])
  local currentValue = KEYS[index + 2]

  if (type(tonumber(currentValue)) ~= 'number') then
    publish('error', 'Valor anomalo '..parametrosAmbientales[index]..' en '..nextKey..'.')
  else
    if (
      valueOfIndexMinusTwo ~= false and valueOfIndexMinusOne ~= false
      and (valueOfIndexMinusTwo ~= valueOfIndexMinusOne or valueOfIndexMinusOne ~= currentValue)
      and not (valueOfIndexMinusOne > valueOfIndexMinusTwo and valueOfIndexMinusOne < currentValue)
    ) then
      local indexMinusOne = nextIndex - 1
      redis.call('HDEL', areaYPuesto..':'..indexMinusOne, parametrosAmbientales[index])
      publish('error', 'Valor fuera de rango '..parametrosAmbientales[index]..' en '..areaYPuesto..':'..indexMinusOne..'.')
    end

    redis.call('HSET', nextKey, parametrosAmbientales[index], currentValue)
    publish('tesis', KEYS[index + 2]..' '..parametrosAmbientales[index]..' agregado en '..nextKey..'.')
  end
end
