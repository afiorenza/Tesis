local parametros = {'area', 'puesto', 'lumenes', 'grados', 'decibelios', 'tipoPuesto'}

local function nuevoNroSecuencial (areaYPuesto)
  if (redis.call('GET', areaYPuesto) == nil) then
    redis.call('SET', areaYPuesto, 0)
  end
  return redis.call('INCR', areaYPuesto)
end

local function addAndPublish (key, field, value)
  redis.call('HSET', key, field, value)
  redis.call('PUBLISH', 'insert', field..': '..value..' agregado en '..key..'.')
end

local areaYPuesto = KEYS[1]..':'..KEYS[2]
local nextIndex = nuevoNroSecuencial(areaYPuesto)
local nextKey = areaYPuesto..':'..nextIndex

for index = 3, 6 do
  local valueOfIndexMinusTwo = redis.call('HGET', areaYPuesto..':'..nextIndex - 2, parametros[index])
  local valueOfIndexMinusOne = redis.call('HGET', areaYPuesto..':'..nextIndex - 1, parametros[index])
  local currentValue = KEYS[index]

  if (index ~= 6) then
    if (type(tonumber(currentValue)) ~= 'number') then
      redis.call('PUBLISH', 'error', 'Valor anomalo '..parametros[index]..' en '..nextKey..'.')
    else
      if (
        valueOfIndexMinusTwo ~= false and valueOfIndexMinusOne ~= false
        and (valueOfIndexMinusTwo ~= valueOfIndexMinusOne or valueOfIndexMinusOne ~= currentValue)
        and not (valueOfIndexMinusOne > valueOfIndexMinusTwo and valueOfIndexMinusOne < currentValue)
      ) then
        local indexMinusOne = nextIndex - 1
        redis.call('HDEL', areaYPuesto..':'..indexMinusOne, parametros[index])
        redis.call('PUBLISH', 'error', 'Valor fuera de rango '..parametros[index]..' en '..areaYPuesto..':'..indexMinusOne..'.')
      end
      addAndPublish(nextKey, parametros[index], currentValue)
    end
  else
    addAndPublish(nextKey, parametros[index], currentValue)
  end
end
