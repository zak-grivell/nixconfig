function Dump(o, n)
    if n == nil then n = 0 end

    local indent = string.rep("  ", n)
    if type(o) == 'table' then
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. indent .. '  [' .. k .. '] = ' .. Dump(v, n + 1) .. ',\n'
        end
        return s .. indent .. '}'
    else
        return tostring(o)
    end
end
