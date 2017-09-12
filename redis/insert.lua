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

-- Chequea si existe registro n-2 y n-1
if (redis.call('EXISTS', puestoYArea..':'..nextIndex - 2) ~= 0 and redis.call('EXISTS', puestoYArea..':'..nextIndex - 1) ~= 0) then
  -- Chequea variables
  for index = 1, 3 do
    local indexMinusTwo = redis.call('HGET', puestoYArea..':'..nextIndex - 2, parametros[index])
    local indexMinusOne = redis.call('HGET', puestoYArea..':'..nextIndex - 1, parametros[index])
    local currentIndex = redis.call('HGET', puestoYArea..':'..nextIndex, parametros[index])

    if not (indexMinusTwo == indexMinusOne or indexMinusOne == currentIndex) then
      if not (indexMinusOne > indexMinusTwo and indexMinusOne < currentIndex) then
        print('anomalo '..parametros[index])
      end
    end
  end
end

-- return redis.call('HGETALL', nextKey)
