script_author('scandalque')
script_name('-2HELPER')
script_version("1.1")

local sampev = require "lib.samp.events"
local inicfg = require 'inicfg'
local players = {}
local rgive = false
local smshere = false

local DEBUG = false
local AdminLevelGlobal = 159
local ProletDialog = 31488

local kolvo = 0

local Fractions = {
	[0] = 12,
	[1] = 13,
	[2] = 15,
	[3] = 17,
	[4] = 18,
	[5] = 11
}

local Ranks = {
	[0] = 6,
	[1] = 6,
	[2] = 6,
	[3] = 6,
	[4] = 6,
	[5] = 9
}

local iniFile = thisScript().name:gsub('.lua', '')..'.ini'
local ini = inicfg.load({
	cfg = {
		password = ""
	}
}, iniFile)

if not doesDirectoryExist(getWorkingDirectory().."\\config") then createDirectory(getWorkingDirectory().."\\config") end
inicfg.save(ini, iniFile)

function chat_message(text)
	sampAddChatMessage('[-2HELPER] {ffffff}'..text, 0xFFDEAD)
end

function update()
    local raw = 'https://raw.githubusercontent.com/sc4sov/2helper/main/update.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['last']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['url'], thisScript().path, function (id, status, p1, p2)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    chat_message('��������� �������')
                    thisScript():reload()
                end
            end)
        else
			chat_message('������ ��� ���������� ������� {ffdead}(�'..lastver..')')
        end
    end
    return f
end

function main() 
    if not isSampfuncsLoaded() or not isSampLoaded() then return end 
    while not isSampAvailable() do wait(100) end 

	local lastver = update():getLastVersion()
	if tonumber(thisScript().version) < tonumber(lastver) then
		chat_message('��� ���������� ���������� �� ������ {ffdead}'..lastver, 0xffdead)
		return
	end

	sampRegisterChatCommand("rygivegun", cmd_rygivegun)
	sampRegisterChatCommand("rysetarm", cmd_rysetarm)
	sampRegisterChatCommand("rysetskin", cmd_rysetskin)
	sampRegisterChatCommand("prolet", cmd_prolet)
	sampRegisterChatCommand("smshere", cmd_smshere)
	sampRegisterChatCommand("masstp", cmd_smshere)
	sampRegisterChatCommand("fid", cmd_fid)
	sampRegisterChatCommand("yinfo", cmd_yinfo)
	if tonumber(thisScript().version) > tonumber(lastver) then
		chat_message('� ��� ����������� {ffdead}������ ������������')
	end
	chat_message('��������. �����: {ffdead}scandalque{ffffff}. �������: {ffdead}/yinfo{ffffff}. ������ �������: {ffdead}'..thisScript().version)
end

function cmd_smshere()
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('�� �� ������������ � �������. ������� ������� ��� ��� ����� �����������')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("�� ��� ����������� ���� �� ������. ��������� �� ����������") return end
	smshere = not smshere
	if smshere then
		chat_message("������ ��� ������, ������� ������� ��� � ���, ����� ���������������")
	else
		chat_message("�������� ��������")
	end
end

function cmd_fid()
	sampShowDialog(0, "{ffdead}-2HELPER {ffffff}| ID �������",
	"\
	{ffdead}[0] {ffffff}�����������\
	{ffdead}[1] {ffffff}LSPD\
	{ffdead}[2] {ffffff}FBI\
	{ffdead}[3] {ffffff}Army SF\
	{ffdead}[5] {ffffff}La Cosa Nostra\
	{ffdead}[6] {ffffff}Yakuza\
	{ffdead}[7] {ffffff}�����\
	{ffdead}[8] {ffffff}BJ Company\
	{ffdead}[9] {ffffff}SF News\
	{ffdead}[10] {ffffff}SFPD\
	{ffdead}[11] {ffffff}�����������\
	{ffdead}[12] {ffffff}The Ballas\
	{ffdead}[13] {ffffff}Los Santos Vagos\
	{ffdead}[14] {ffffff}������� �����\
	{ffdead}[15] {ffffff}Grove Street\
	{ffdead}[16] {ffffff}LS News\
	{ffdead}[17] {ffffff}Varios Los Aztecas\
	{ffdead}[18] {ffffff}The Rifa\
	{ffdead}[19] {ffffff}Army LV\
	{ffdead}[20] {ffffff}LV News\
	{ffdead}[21] {ffffff}LVPD\
	{ffdead}[22] {ffffff}Medic\
	{ffdead}[24] {ffffff}Mongols MC\
	{ffdead}[26] {ffffff}Warlocks MC\
	{ffdead}[29] {ffffff}Pagans MC",
	"�������",
	"",
	DIALOG_STYLE_MSGBOX)
end

function cmd_yinfo()
	sampShowDialog(0, "{ffdead}-2HELPER {ffffff}| �������",
	"\
	{ffdead}/rygivegun [������] [id ������] [�������] {ffffff}- ������ ������ � �������\
	{ffdead}/rysetarm [������] [���������� �����] {ffffff}- ������ ����� � �������\
	{ffdead}/rysetskin [p�����] [id �����] {ffffff}- ������ ����� � �������\
	{ffdead}/prolet {ffffff}- ������� invite � �����\
	{ffdead}/smshere {ffffff}- ������������ � ���� �������, ���������� � ���\
	{ffdead}/fid {ffffff}- ID �������\
	{ffdead}/yinfo {ffffff}- ������� �������",
	"�������",
	"",
	DIALOG_STYLE_MSGBOX)
end

function cmd_prolet()
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('�� �� ������������ � �������. ������� ������� ��� ��� ����� �����������')
		sampSendChat('/alogin')
		return
	end
	lua_thread.create(function()
			sampShowDialog(ProletDialog, "{ffdead}-2HELPER {ffffff}| ����� �����", "{B313E7}Ballas\n{DBD604}Vagos\n{009F00}Grove\n{01FCFF}Aztecas\n{2A9170}Rifa\n{ffffff}�����������", "�������", "������", DIALOG_STYLE_LIST) -- ��� ������
			while sampIsDialogActive(ProletDialog) do wait(100) end
			local _, button, list, _ = sampHasDialogRespond(ProletDialog) -- �������� ����� �� ������
			if button == 1 then
				sampSendChat('/ainvite '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))..' '..Fractions[list]..' '..Ranks[list])
				return false
			elseif button == 0 then
				sampSendDialogResponse(ProletDialog, 0, _, _)
			end
	end)
end

function cmd_rygivegun(arg)
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('�� �� ������������ � �������. ������� ������� ��� ��� ����� �����������')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("�� ��� ����������� ���� �� ������. ��������� �� ����������") return end
	local radius, gun, ammo = string.match(arg, "(%d+) (%d+) (%d+)")
	if radius ~= nil and radius ~= "" and gun ~= nil and gun ~= "" and ammo ~= nil and ammo ~= "" then
		--if tonumber(gun) < 22 and tonumber(gun) > 31 or tonumber(gun) == 26 or tonumber(gun) == 27 then chat_message("��������� ������ ������: � 22 �� 31, ��������� 26 � 27") return end
		if tonumber(ammo) < 1 and tonumber(ammo) > 500 then chat_message("�������� �� 1 �� 500 �������� �� ���") return end
		chat_message("�������� �������� ������")
		rgive = true
		for k, v in pairs(getAllChars()) do
			_, id = sampGetPlayerIdByCharHandle(v)
			_, Pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			if Pid ~= id then
				x, y, z = getCharCoordinates(v)
				xp, yp, zp = getCharCoordinates(PLAYER_PED)
				distant = getDistanceBetweenCoords3d(x,y,z,xp,yp,zp)
				if distant <= tonumber(radius) then
					table.insert(players, id)
					Log(id)
				end
			end
		end
		lua_thread.create(function()
			for k, v in ipairs(players) do
				wait(1111)
				sampSendChat('/ygivegun '..v..' '..gun..' '..ammo)
				Log('/ygivegun '..v..' '..gun..' '..ammo)
				chat_message('������ {ffdead}'..gun..' {ffffff}������ � {ffdead}'..ammo..' {ffffff}��������� ������ {ffdead}'..sampGetPlayerNickname(v), 0xffdead)
				kolvo = kolvo + 1
				Log(v)
			end
			chat_message('������ ������ ���������. ������ ������ {ffdead}'..kolvo..' {ffffff}�������')
			players = {}
			kolvo = 0
			rgive = false
		end)
	else chat_message("������� ������� ��������� (�����������: /rygivegun [������] [������] [���������� ������])") return end
end

function cmd_rysetarm(arg)
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('�� �� ������������ � �������. ������� ������� ��� ��� ����� �����������')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("�� ��� ����������� ���� �� ������. ��������� �� ����������") return end
	local radius, ammo = string.match(arg, "(%d+) (%d+)")
	if radius ~= nil and radius ~= "" and ammo ~= nil and ammo ~= "" then
		if tonumber(ammo) < 0 and tonumber(ammo) > 200 then chat_message("�������� �� 0 �� 200 �����") return end
		chat_message("�������� ������������� �����")
		rgive = true
		for k, v in pairs(getAllChars()) do
			_, id = sampGetPlayerIdByCharHandle(v)
			_, Pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			if Pid ~= id then
				x, y, z = getCharCoordinates(v)
				xp, yp, zp = getCharCoordinates(PLAYER_PED)
				distant = getDistanceBetweenCoords3d(x,y,z,xp,yp,zp)
				if distant <= tonumber(radius) then
					table.insert(players, id)
					Log(id)
				end
			end
		end
		lua_thread.create(function()
			for k, v in ipairs(players) do
				wait(1111)
				sampSendChat('/setarm '..v..' '..ammo)
				Log('/setarm '..v..' '..ammo)
				chat_message('������ ����� ('..ammo..'){ffffff} ������ {ffdead}'..sampGetPlayerNickname(v), 0xffdead)
				kolvo = kolvo + 1
				Log(v)
			end
			chat_message('������ ����� ���������. ������ {ffdead}'..kolvo..' {ffffff}�������')
			players = {}
			kolvo = 0
			rgive = false
		end)
	else chat_message("������� ������� ��������� (�����������: /rysetarm [������] [���������� �����])") return end
end

function cmd_rysetskin(arg)
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('�� �� ������������ � �������. ������� ������� ��� ��� ����� �����������')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("�� ��� ����������� ���� �� ������. ��������� �� ����������") return end
	local radius, ammo = string.match(arg, "(%d+) (%d+)")
	if radius ~= nil and radius ~= "" and ammo ~= nil and ammo ~= "" then
		if tonumber(ammo) < 1 and tonumber(ammo) > 311 then chat_message("�������� ����� �� 1 �� 311") return end
		chat_message("�������� ������������� �����")
		rgive = true
		for k, v in pairs(getAllChars()) do
			_, id = sampGetPlayerIdByCharHandle(v)
			_, Pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			if Pid ~= id then
				x, y, z = getCharCoordinates(v)
				xp, yp, zp = getCharCoordinates(PLAYER_PED)
				distant = getDistanceBetweenCoords3d(x,y,z,xp,yp,zp)
				if distant <= tonumber(radius) then
					table.insert(players, id)
					Log(id)
				end
			end
		end
		lua_thread.create(function()
			for k, v in ipairs(players) do
				wait(1111)
				sampSendChat('/ysetskin '..v..' '..ammo)
				Log('/ysetskin '..v..' '..ammo)
				chat_message('����� ���� ('..ammo..'){ffffff} ������ {ffdead}'..sampGetPlayerNickname(v), 0xffdead)
				kolvo = kolvo + 1
				Log(v)
			end
			chat_message('������ ������ ���������. ������ {ffdead}'..kolvo..' {ffffff}�������')
			players = {}
			kolvo = 0
			rgive = false
		end)
	else chat_message("������� ������� ��������� (�����������: /rysetskin [������] [����])") return end
end

function sampev.onServerMessage(color, text)
	if text:find('������ (.+) ������ ������ (.+)') then return false end
	if text:find("�� ���������������� ��� ������������� (%S+) ������") then
		setGameGlobal(AdminLevelGlobal, tonumber(text:match("�� ���������������� ��� ������������� (%S+) ������")))
		Log(getGameGlobal(AdminLevelGlobal))
	end
	if text:find('����� �������������� ���������') then setGameGlobal(AdminLevelGlobal, 0) end
	if text:find('SMS: (.+). �����������: (%S+)%[(%S+)%]') and smshere then
		local _, __, id123 = text:match('SMS: (.+). �����������: (%S+)%[(%S+)%]')
		Log('��� �������������� ����� '..tonumber(id123))
		sampSendChat('/gethere '..tonumber(id123))
		return false
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if text:find('������ ������ �������� �� ��������� ���� � ����') then
		if ini.cfg.password == "" then chat_message("��� ������������ ������������� ������� ��������� ������ � {ffdead}ini �������") return true end
		sampSendDialogResponse(dialogId, 1, 0, ini.cfg.password)
		return false
	end
end

function Log(text)
	if DEBUG then print(text) end
end