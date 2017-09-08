-- Inicializa variables desde parametros
local puesto = ARGV[1]
local area = ARGV[2]
local lumenes = ARGV[3]
local grados = ARGV[4]
local decibelios = ARGV[5]
local tipoPuesto = ARGV[6]
local nextIndex

-- Busca valor contador y si no existe lo agrega
if (redis.call('GET', puesto..':'..area) == nil) then
  redis.call('SET', puesto..':'..area, 0)
end

-- Incrementa contador
nextIndex = redis.call('INCR', puesto..':'..area)

-- Agrega registro
redis.call('HSET', puesto..':'..area..':'..nextIndex, '')

lumenes [lumenes] grados [grados] decibelios [decibelios] tipoPuesto [tipoPuesto]

return nextIndex
