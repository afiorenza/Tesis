local parametrosAmbientales = {'lumenes', 'grados', 'decibelios'}

local function initializeAreaYPuesto (areaYPuesto)
  if (redis.call('GET', areaYPuesto) == nil) then
    redis.call('SET', areaYPuesto, 0)
  end
end

local function publish (channel, text)
  redis.call('PUBLISH', channel, text)
end

-- Inicializa variables desde parametros
local area = KEYS[1]
local puesto = KEYS[2]
local lumenes = KEYS[3]
local grados = KEYS[4]
local decibelios = KEYS[5]
local tipoPuesto = KEYS[6]

local areaYPuesto = area..':'..puesto

initializeAreaYPuesto(areaYPuesto)

local nextIndex = redis.call('INCR', areaYPuesto)
local nextKey = areaYPuesto..':'..nextIndex

redis.call('HSET', nextKey, 'tipoPuesto', tipoPuesto)

for index = 1, 3 do
  local indexMinusTwo = redis.call('HGET', areaYPuesto..':'..nextIndex - 2, parametrosAmbientales[index])
  local indexMinusOne = redis.call('HGET', areaYPuesto..':'..nextIndex - 1, parametrosAmbientales[index])
  local currentValue = KEYS[index + 2]

  if (type(tonumber(currentValue)) ~= 'number') then
    publish('error', 'Valor anomalo '..parametrosAmbientales[index]..' en '..nextKey..'.')
  elseif (indexMinusTwo ~= false and indexMinusOne ~= false and (indexMinusTwo ~= indexMinusOne or indexMinusOne ~= currentValue) and not (indexMinusOne > indexMinusTwo and indexMinusOne < currentValue)) then
    publish('error', 'Valor anomalo '..parametrosAmbientales[index]..' en Area: '..area.. ' puesto: '..puesto..' Secuencial '..indexMinusOne..'.')
  else
    redis.call('HSET', nextKey, parametrosAmbientales[index], currentValue)
    publish('tesis', KEYS[index + 2]..' '..parametrosAmbientales[index]..' agregado en '..nextKey..'.')
  end
end
