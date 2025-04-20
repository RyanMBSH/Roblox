--// SegLib (Secure Execution Library)
local SegLib = {}

-- Armazena funções já encontradas
SegLib._cache = {}

function SegLib.spoofFunc(funcName)
    if SegLib._cache[funcName] then
        return SegLib._cache[funcName]
    end

    local function checkAndReturn(f)
        if typeof(f) == "function" then
            SegLib._cache[funcName] = f
            return f
        end
    end

    -- 1. Checar ambientes seguros
    local envs = {
        getrenv and getrenv(),
        getgenv and getgenv(),
        getfenv and getfenv(0),
        shared,
        _G
    }

    for _, env in ipairs(envs) do
        if type(env) == "table" then
            for name, func in pairs(env) do
                if typeof(func) == "function" and tostring(name):lower():find(funcName:lower()) then
                    return checkAndReturn(func)
                end
            end
        end
    end

    -- 2. Procurar diretamente no registry
    if debug and debug.getregistry then
        for _, v in pairs(debug.getregistry()) do
            if typeof(v) == "function" and tostring(v):lower():find(funcName:lower()) then
                return checkAndReturn(v)
            end
        end
    end

    -- 3. Tentar diretamente
    local ok, direct = pcall(function()
        return getfenv(0)[funcName]
    end)
    if ok and typeof(direct) == "function" then
        return checkAndReturn(direct)
    end

    -- 4. Não encontrado
    error("[SegLib] ❌ Função '" .. funcName .. "' não foi encontrada em nenhum ambiente válido.")
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
    local success, result = pcall(func, ...)
    if not success then
        warn("[SegLib] Erro em secureCall: " .. tostring(result))
    end
    return result
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
