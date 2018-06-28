_G['os'] = nil
_G['io'] = nil
json = require 'json'
gLastModify = '2018 0621 10:00'
gUser    = nil
gName    = 'Bitcoin'
gSymbol  = 'BTC'
gBalance = {}
gTotal   = 21000000
gOwner   = nil
gFee     = 0.0001
gFeePool = 0
gIcon    = ''

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
    buffer['symbol'] = gSymbol
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
    print(gUser)
    gOwner = gUser
    gBalance[gUser] = gTotal
    return _getResult(gUser,'init',true,gTotal)
end

function getFee()
    local curResult = {}
    _addResult(gUser,'getFee',true,gFee,curResult)
    _addResult(gUser,'getFeePool',true,gFeePool,curResult)
    return json.encode(curResult)
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

function getIcon()
    return _getResult(gUser,'getIcon',true,gIcon)
end

function setIcon(pIcon)
    if gOwner ~= gUser then
        return 'fail'
    end
    gIcon = pIcon
end

function transfer(pTo,pAmount)
    local curAmount = tonumber(pAmount)
    if curAmount > gTotal then
        return 'fail'
    end
    if curAmount <= gFee then
        --return _getResult(gUser,'transfer',false,'amount <= 0')
        return 'fail'
    end
    if gBalance[gUser] < curAmount+gFee then
        --return _getResult(gUser,'transfer',false,'sender amount < curAmount')
        return 'fail'
    end
    if gBalance[pTo] == nil then
	    gBalance[pTo] = 0
    end
    local curResult = {}
    gFeePool = gFeePool + gFee
    gBalance[gUser] = gBalance[gUser] - curAmount
    gBalance[gUser] = gBalance[gUser] - gFee
    gBalance[pTo] = gBalance[pTo] + curAmount
    _addResult(gUser,'transfer',true,gBalance[gUser],curResult)
    _addResult(pTo,'transfer',true,gBalance[pTo],curResult)
    return json.encode(curResult)
end

function payWorker(pTo,pAmount)
    local curAmount = tonumber(pAmount)
    if gUser ~= gOwner then
        return 'fail'
    end
    if curAmount > gFeePool then
        return 'fail'
    end
    if gBalance[pTo] == nil then
	    gBalance[pTo] = 0
    end
    gFeePool = gFeePool - curAmount
    gBalance[pTo] = gBalance[pTo] + curAmount
    return _getResult(pTo,'payWorker',true,gBalance[pTo])
end

function getHelp()
    local curHelp = {}
    curHelp['get'] = {}
    curHelp['set'] = {}
    curHelp['get']['getFee'] = {}
    curHelp['get']['getFee']['param'] = {'null'}
    curHelp['get']['getFee']['response'] = '[{"owner":"0x123","result":true,"msg":0.01,"method":"getFee"},{"owner":"0x123","result":true,"msg":0.01,"method":"getFeePool"}]'
    curHelp['get']['getSymbol'] = {}
    curHelp['get']['getSymbol']['param'] = {'null'}
    curHelp['get']['getSymbol']['response'] = '[{"owner":0x123,"msg":"ONN","method":"getSymbol","result":true}]'
    curHelp['get']['getName'] = {}
    curHelp['get']['getName']['param'] = {'null'}
    curHelp['get']['getName']['response'] = '[{"owner":0x123,"msg":"Origin Node Network","method":"getName","result":true}]'
    curHelp['get']['getTotalSupply'] = {}
    curHelp['get']['getTotalSupply']['param'] = {'null'}
    curHelp['get']['getTotalSupply']['response'] = '[{"owner":0x123,"msg":7000000000,"method":"getTotalSupply","result":true}]'
    curHelp['get']['getBalanceOf'] = {}
    curHelp['get']['getBalanceOf']['param'] = {'address'}
    curHelp['get']['getBalanceOf']['response'] = '[{"owner":0x123,"msg":7000000000,"method":"getBalanceOf","result":true}]'
    curHelp['set']['transfer'] = {}
    curHelp['set']['transfer']['param'] = {'address','amount'}
    curHelp['set']['transfer']['response'] = '[{"owner":"0x123","msg":6999999900,"method":"transfer","result":true},{"owner":"0x456","msg":100,"method":"transfer","result":true}]'
    curHelp['get']['payWorker'] = {}
    curHelp['get']['payWorker']['param'] = {'address','amount'}
    curHelp['get']['payWorker']['response'] = '[{"owner":0x123,"msg":1,"method":"payWorker","result":true}]'
    return _getResult(gUser,'getHelp',true,curHelp)
end