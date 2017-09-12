-- Inicializa variables desde parametros
local puesto = KEYS[1]
local area = KEYS[2]
local lumenes = KEYS[3]
local grados = KEYS[4]
local decibelios = KEYS[5]
local tipoPuesto = KEYS[6]

local parametros = {'decibelios', 'grados', 'lumenes'}
local puestoYArea = puesto..':'..area

-- Busca valor contador y si no existe lo agrega
if (redis.call('GET', puestoYArea) == nil) then
  redis.call('SET', puestoYArea, 0)
end

-- Incrementa contador
local nextIndex = redis.call('INCR', puestoYArea)
local nextKey = puestoYArea..':'..nextIndex

-- Agrega registros
redis.call('HSET', nextKey, parametros[1], decibelios)
redis.call('HSET', nextKey, parametros[2], grados)
redis.call('HSET', nextKey, parametros[3], lumenes)
redis.call('HSET', nextKey, 'tipoPuesto', tipoPuesto)

redis.call('PUBLISH', 'tesis', 'Tupla agregada. Area: '..area.. ' puesto: '..puesto..'. Temperatura: '..grados..' grados. Sonido: '..decibelios..' decibelios. Iluminacion: '..lumenes..' lumenes.')

for index = 1, 3 do
  local indexMinusTwo = redis.call('HGET', puestoYArea..':'..nextIndex - 2, parametros[index])
  local indexMinusOne = redis.call('HGET', puestoYArea..':'..nextIndex - 1, parametros[index])
  local currentIndex = redis.call('HGET', puestoYArea..':'..nextIndex, parametros[index])

  if (indexMinusTwo ~= false and indexMinusOne ~= false and (indexMinusTwo ~= indexMinusOne or indexMinusOne ~= currentIndex)) then
    if not (indexMinusOne > indexMinusTwo and indexMinusOne < currentIndex) then
      redis.call('HDEL', nextKey, parametros[index])
      redis.call('PUBLISH', 'tesis', 'Valor anomalo '..parametros[index]..' en Area: '..area.. ' puesto: '..puesto..' Secuencial '..indexMinusOne..'.')
    end
  end
end
