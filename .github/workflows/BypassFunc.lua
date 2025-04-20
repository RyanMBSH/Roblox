--// SegLib (Secure Execution Library)
local SegLib = {}

-- Protege e encapsula qualquer função nativa original
function SegLib.spoofFunc(funcName)
    -- Primeiro: verifica se já foi spoofado antes
    if SegLib[funcName] and typeof(SegLib[funcName]) == "function" then
        return SegLib[funcName]
    end

    -- Tentativa 1: diretamente pelo environment global
    local sources = {getgenv and getgenv(), getrenv and getrenv(), getfenv and getfenv(0), shared}
    for _, env in ipairs(sources) do
        if type(env) == "table" then
            for k, v in pairs(env) do
                if typeof(v) == "function" and tostring(k):lower():find(funcName:lower()) then
                    SegLib[funcName] = newcclosure(function(...) return v(...) end)
                    return SegLib[funcName]
                end
            end
        end
    end

    -- Tentativa 2: varredura por namecall
    local success, f = pcall(function() return firetouchinterest end)
    if success and typeof(f) == "function" then
        SegLib[funcName] = newcclosure(function(...) return f(...) end)
        return SegLib[funcName]
    end

    -- Falha final: retorna dummy seguro
    warn("[SegLib] Função '" .. funcName .. "' não encontrada em nenhum ambiente.")
    return function() end
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

return SegLib
