--// SegLib (Secure Execution Library)
local SegLib = {}

-- Protege e encapsula qualquer função nativa original
local SegLib = {}

-- Armazena funções já encontradas
SegLib._cache = {}

function SegLib.spoofFunc(funcName)
    if SegLib._cache[funcName] then
        return SegLib._cache[funcName]
    end

    -- 1ª tentativa: ambientes conhecidos
    local sources = {getgenv and getgenv(), getrenv and getrenv(), getfenv and getfenv(0), shared, _G}
    for _, env in ipairs(sources) do
        if type(env) == "table" then
            for k, v in pairs(env) do
                if typeof(v) == "function" and tostring(k):lower():find(funcName:lower()) then
                    local secured = newcclosure(function(...) return v(...) end)
                    SegLib._cache[funcName] = secured
                    return secured
                end
            end
        end
    end

    -- 2ª tentativa: checagem de variáveis locais via debug
    if debug and debug.getregistry then
        for _, v in pairs(debug.getregistry()) do
            if typeof(v) == "function" and tostring(v):lower():find(funcName:lower()) then
                local secured = newcclosure(function(...) return v(...) end)
                SegLib._cache[funcName] = secured
                return secured
            end
        end
    end

    -- 3ª tentativa: tentar acesso direto
    local suc, direct = pcall(function() return getfenv(0)[funcName] end)
    if suc and typeof(direct) == "function" then
        local secured = newcclosure(function(...) return direct(...) end)
        SegLib._cache[funcName] = secured
        return secured
    end

    -- Se ainda não encontrou, retorna dummy
    warn("[SegLib] Função '" .. funcName .. "' não encontrada.")
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
