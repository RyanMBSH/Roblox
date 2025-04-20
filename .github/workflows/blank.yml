--// SegLib (Secure Execution Library)
local SegLib = {}

-- Protege e encapsula qualquer função nativa original
function SegLib.spoofFunc(funcName)
    local env = getrenv and getrenv() or getfenv(0)
    for k, v in pairs(env) do
        if typeof(v) == "function" and tostring(k):lower():find(funcName:lower()) then
            return newcclosure(function(...)
                return v(...)
            end)
        end
    end
    warn("[SegLib] Função '" .. funcName .. "' não encontrada.")
    return function() end -- retorna dummy seguro
end

-- Executa uma função protegida, checando ambiente
function SegLib.secureCall(func, ...)
    if typeof(func) ~= "function" then
        warn("[SegLib] Função inválida para secureCall.")
        return
    end
    if checkcaller and not checkcaller() then
        warn("[SegLib] secureCall bloqueada fora do script.")
        return
    end
    return pcall(func, ...)
end

-- Seta uma propriedade de forma protegida (caso possível)
function SegLib.safeSet(instance, property, value)
    if instance and instance[property] ~= nil then
        local ok, err = pcall(function()
            instance[property] = value
        end)
        if not ok then
            warn("[SegLib] Falha ao setar propriedade: " .. tostring(err))
        end
    end
end

-- Retorna se a função passada é um closure seguro
function SegLib.isSafe(func)
    return iscallerclosure and iscallerclosure(func)
end

-- Exemplo de uso automático com firetouchinterest
SegLib.firetouch = SegLib.spoofFunc("firetouchinterest")

return SegLib
