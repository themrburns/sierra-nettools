sierra = {...}

if not fs.exists("ecc.lua") then
    error("Package ecc not found. Consult system administrator for more information", 2)
end
local a = require("ecc")
if not fs.exists("pub.key") then
    local b, c = a.keypair(a.random.random())
    local d = fs.open("pub.key", "w")
    d.write(tostring(c))
    d.close()
    d = fs.open("sec.key", "w")
    d.write(tostring(b))
    d.close()
end
function sierra.beginCom(e, f)
    return tostring(a.exchange(e, f))
end
function sierra.createPacket(g, h, c)
    local i = a.encrypt(g, h)
    local j = {msg = i, time = os.time(), idemp = tostring(a.random.random())}
    local k = a.sign(c, textutils.serialize(j))
    local l = {packet = j, sig = k}
    return textutils.serialize(l)
end
function sierra.computePacket(l, f, h, m)
    l = textutils.unserialize(l)
    local n = l.packet
    local k = l.sig
    isValid = a.verify(f, textutils.serialize(n), k)
    if not isValid then
        return "SIGNATURE_CHECK_FAIL"
    end
    if os.time() < n.time + 0.03 then
        return "TIME_CHECK_FAIL"
    end
    local o = true
    for p, q in ipairs(m) do
        if q == n.idemp then
            o = false
        end
    end
    if not o then
        return "IDEMP_CHECK_FAIL"
    end
    table.add(m, n.idemp)
    local i = n.msg
    local g = a.decrypt(i, h)
    return tostring(g)
end

return sierra
