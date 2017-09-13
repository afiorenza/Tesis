local parametros = {'area', 'puesto', 'lumenes', 'grados', 'decibelios', 'tipoPuesto'}

local function nuevoNroSecuencial (areaYPuesto)
  if (redis.call('GET', areaYPuesto) == nil) then
    redis.call('SET', areaYPuesto, 0)
  end
  return redis.call('INCR', areaYPuesto)
end

local function agregarCampo (clave, campo, valor)
  redis.call('HSET', clave, campo, valor)
end

local areaYPuesto = KEYS[1]..':'..KEYS[2]
local proximoIndice = nuevoNroSecuencial(areaYPuesto)
local proximaKey = areaYPuesto..':'..proximoIndice

for indice = 3, 6 do
  local valorIndiceMenosDos = redis.call('HGET', areaYPuesto..':'..proximoIndice - 2, parametros[indice])
  local valorIndiceMenosUno = redis.call('HGET', areaYPuesto..':'..proximoIndice - 1, parametros[indice])
  local valorActual = KEYS[indice]

  if (indice ~= 6) then
    if (type(tonumber(valorActual)) ~= 'number') then
      redis.call('PUBLISH', 'error', 'Valor anomalo '..parametros[indice]..' en '..proximaKey..'.')
    else
      if (
        valorIndiceMenosDos ~= false and valorIndiceMenosUno ~= false and valorActual ~= false and
        not (valorIndiceMenosUno >= valorIndiceMenosDos and valorIndiceMenosUno <= valorActual)
      ) then
        local indiceMenosUno = proximoIndice - 1
        redis.call('HDEL', areaYPuesto..':'..indiceMenosUno, parametros[indice])
        redis.call('PUBLISH', 'error', 'Valor fuera de rango '..parametros[indice]..' en '..areaYPuesto..':'..indiceMenosUno..'.')
      end
      agregarCampo(proximaKey, parametros[indice], valorActual)
    end
  else
    agregarCampo(proximaKey, parametros[indice], valorActual)
  end
end
