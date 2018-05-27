_G['os'] = nil
_G['io'] = nil
json = require 'json'
gUser = nil
function setUser(pUser)
gUser = pUser
end

gName = 'Origin Erc20 Template'
gSymbol = 'OET'

gOwner = nil
gTotalSupply = 0
gBalance = {}

function _toJson(pKey,pVar)
	return json.encode({f=pKey,v=pVar,u=gUser})
end

function init(pTotal)
	if gOwner ~= nil then
		return toJson('init','fail: it was init')
	end
	gTotalSupply = pTotal
	gOwner = gUser
	gBalance[gOwner] = tonumber(pTotal)
	return _toJson('init','init finish')
end

function getBalanceOf(pUser)
	if gBalance[pUser] == nil then
		return _toJson('balanceOf',0)
	end
	return _toJson('balanceOf',gBalance[pUser])
end

function transfer(pTo,pAmount)
	if gBalance[gUser] == nil then
		return _toJson('transfer','sender not found')
	end
	if gBalance[pTo] == nil then
		gBalance[pTo] = 0
	end
	local curAmount = tonumber(pAmount)
	if curAmount <= 0 then
		return _toJson('transfer','curAmount <= 0')
	end
	if gBalance[gUser] < curAmount then
		return _toJson('transfer','sender amount not enough')
	end
	gBalance[gUser] = gBalance[gUser] - curAmount
	gBalance[pTo] = gBalance[pTo] + curAmount
	return json.encode({sender=gUser,senderBalance=gBalance[gUser],reciver=pTo,reciverBlance=gBalance[pTo]})
end