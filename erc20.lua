_G['os'] = nil
_G['io'] = nil
json = require 'json'
gUser = nil
gName    = "Erc20 Template Token"
gSymbol  = 'ETT'
gBalance = {}
gTotal   = 70000000000
gOwner   = nil

function setUser(pUser)
	gUser = pUser
end

function _addResult(pUser,pMethod,pResult,pMsg,pAll)
    local buffer = {}
    local result = pAll
    buffer['method'] = pMethod
    buffer['result'] = pResult
    buffer['msg']    = pMsg
    buffer['owner']  = pUser
    table.insert(result,buffer)
    return result
end

function _getResult(pUser,pMethod,pResult,pMsg)
    local buffer = {}
    local result = _addResult(pUser,pMethod,pResult,pMsg,buffer)
    return json.encode(result)
end

function init()
    if gOwner ~= nil then
		return 'fail'
    end
    gOwner = gUser
    gBalance[gUser] = gTotal
    return _getResult(gUser,'init',true,'ok')
end

function getSymbol()
    return _getResult(gUser,'getSymbol',true,gSymbol)
end

function getTotalSupply()
    return _getResult(gUser,'getTotalSupply',true,gTotal)
end

function getName()
    return _getResult(gUser,'getName',true,gName)
end

function getBalanceOf(pUser)
    if gBalance[pUser] == nil then
		return _getResult(gUser,'getBalanceOf',true,0)
    end
    return _getResult(gUser,'getBalanceOf',true,gBalance[pUser])
end

function transfer(pTo,pAmount)
    local curAmount = tonumber(pAmount)
    if curAmount <= 0 then
		return 'fail'
    end
    if gBalance[gUser] < curAmount then
		return 'fail'
    end
    if gBalance[pTo] == nil then
		gBalance[pTo] = 0
    end
    local curResult = {}
    gBalance[gUser] = gBalance[gUser] - curAmount
    gBalance[pTo] = gBalance[pTo] + curAmount
    _addResult(gUser,'transfer',true,gBalance[gUser],curResult)
    _addResult(pTo,'transfer',true,gBalance[pTo],curResult)
    return json.encode(curResult)
end