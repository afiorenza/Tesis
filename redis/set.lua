-- Inicializa variables desde parametros
local puesto = ARGV[1]
local area = ARGV[2]
local lumenes = ARGV[3]
local grados = ARGV[4]
local decibelios = ARGV[5]
local tipoPuesto = ARGV[6]

-- Busca valor contador y si no existe lo agrega
if (redis.call('GET', puesto..':'..area) == nil) then
  redis.call('SET', puesto..':'..area, 0)
end

-- Incrementa contador
local nextIndex = redis.call('INCR', puesto..':'..area)
local nextKey = puesto..':'..area..':'..nextIndex

-- Agrega registros
redis.call('HSET', nextKey, KEYS[3], ARGV[3])
redis.call('HSET', nextKey, KEYS[4], ARGV[4])
redis.call('HSET', nextKey, KEYS[5], ARGV[5])
redis.call('HSET', nextKey, KEYS[6], ARGV[6])

return redis.call('HGETALL', nextKey)
