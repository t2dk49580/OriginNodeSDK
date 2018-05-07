_G['os'] = nil
_G['io'] = nil
json = require 'json'
gUser = nil
function setUser(pUser)
gUser = pUser
end

gSymbol  = 'ONN'
gBalance = {}
gTotal   = 7000000000
gOwner   = nil

function _getResult(pUser,pMethod,pResult,pMsg)
	local buffer = {}
	local result = {}
	buffer['method'] = pMethod
	buffer['result'] = pResult
	buffer['msg']    = pMsg
	result[pUser]    = buffer
	return json.encode(result)
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

function init()
    if gOwner ~= nil then
        return _getResult(gUser,'init',false,'fail')
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

function getBalanceOf(pUser)
    if gBalance[pUser] == nil then
        return _getResult(gUser,'getBalanceOf',true,0)
    end
    return _getResult(gUser,'getBalanceOf',true,gBalance[pUser])
end

function transfer(pTo,pAmount)
	local curAmount = tonumber(pAmount)
	if curAmount <= 0 then
		return _getResult(gUser,'transfer',false,'amount <= 0')
	end
	if gBalance[gUser] < curAmount then
		return _getResult(gUser,'transfer',false,'sender amount < curAmount')
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

function getHelp()
    local curHelp = {}
	curHelp['get'] = {}
    curHelp['set'] = {}

    curHelp['get']['getSymbol'] = {}
	curHelp['get']['getSymbol']['param'] = {'null'}
	curHelp['get']['getSymbol']['response'] = '{"0x123":{"msg":"ONN","method":"getSymbol","result":true}}'

    curHelp['get']['getTotalSupply'] = {}
	curHelp['get']['getTotalSupply']['param'] = {'null'}
	curHelp['get']['getTotalSupply']['response'] = '{"0x123":{"msg":7000000000,"method":"getTotalSupply","result":true}}'

    curHelp['get']['getBalanceOf'] = {}
	curHelp['get']['getBalanceOf']['param'] = {'address'}
	curHelp['get']['getBalanceOf']['response'] = '{"0x123":{"msg":7000000000,"method":"getBalanceOf","result":true}}'

    curHelp['set']['transfer'] = {}
	curHelp['set']['transfer']['param'] = {'address','amount'}
	curHelp['set']['transfer']['response'] = '[{"owner":"0x123","msg":6999999900,"method":"transfer","result":true},{"owner":"0x456","msg":100,"method":"transfer","result":true}]'

    return _getResult(gUser,'getHelp',true,curHelp)
end