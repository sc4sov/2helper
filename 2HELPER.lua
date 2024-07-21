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
                    chat_message('Обновлено успешно')
                    thisScript():reload()
                end
            end)
        else
			chat_message('Ошибка при обновлении скрипта {ffdead}(№'..lastver..')')
        end
    end
    return f
end

function main() 
    if not isSampfuncsLoaded() or not isSampLoaded() then return end 
    while not isSampAvailable() do wait(100) end 

	local lastver = update():getLastVersion()
	if lastver == "UNKNOWN" then lastver = "0.0" end
	if tonumber(thisScript().version) < tonumber(lastver) then
		chat_message('Нам необходимо обновиться до версии {ffdead}'..lastver, 0xffdead)
		update():download()
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
	sampRegisterChatCommand("sskin", cmd_sskin)
	if tonumber(thisScript().version) > tonumber(lastver) and lastver ~= "0.0" then
		chat_message('У вас установлена {ffdead}версия разработчика')
	end
	chat_message('Загружен. Автор: {ffdead}scandalque{ffffff}. Команды: {ffdead}/yinfo{ffffff}. Версия скрипта: {ffdead}'..thisScript().version)
end

function cmd_smshere()
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('Вы не авторизованы в админку. Введите команду еще раз после авторизации')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("Вы уже используете одну из команд. Дождитесь ее выполнения") return end
	smshere = not smshere
	if smshere then
		chat_message("Теперь все игроки, которые напишут вам в смс, будут телепортированы")
	else
		chat_message("Телепорт отключен")
	end
end

function cmd_fid()
	sampShowDialog(0, "{ffdead}-2HELPER {ffffff}| ID фракций",
	"\
	{ffdead}[0] {ffffff}Гражданский\
	{ffdead}[1] {ffffff}LSPD\
	{ffdead}[2] {ffffff}FBI\
	{ffdead}[3] {ffffff}Army SF\
	{ffdead}[5] {ffffff}La Cosa Nostra\
	{ffdead}[6] {ffffff}Yakuza\
	{ffdead}[7] {ffffff}Мэрия\
	{ffdead}[8] {ffffff}BJ Company\
	{ffdead}[9] {ffffff}SF News\
	{ffdead}[10] {ffffff}SFPD\
	{ffdead}[11] {ffffff}Инструкторы\
	{ffdead}[12] {ffffff}The Ballas\
	{ffdead}[13] {ffffff}Los Santos Vagos\
	{ffdead}[14] {ffffff}Русская мафия\
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
	"Закрыть",
	"",
	DIALOG_STYLE_MSGBOX)
end

function cmd_yinfo()
	sampShowDialog(0, "{ffdead}-2HELPER {ffffff}| Команды",
	"\
	{ffdead}/rygivegun [радиус] [id оружия] [патроны] {ffffff}- Выдача оружия в радиусе\
	{ffdead}/rysetarm [радиус] [количество брони] {ffffff}- Выдача брони в радиусе\
	{ffdead}/rysetskin [pадиус] [id скина] {ffffff}- Выдача скина в радиусе\
	{ffdead}/prolet {ffffff}- Быстрый invite в банду\
	{ffdead}/smshere {ffffff}- Телепортация к себе игроков, написавших в смс\
	{ffdead}/fid {ffffff}- ID фракций\
	{ffdead}/sskin [id] {ffffff}- Выдать себе скин\
	{ffdead}/yinfo {ffffff}- Команды скрипта",
	"Закрыть",
	"",
	DIALOG_STYLE_MSGBOX)
end

function cmd_prolet()
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('Вы не авторизованы в админку. Введите команду еще раз после авторизации')
		sampSendChat('/alogin')
		return
	end
	lua_thread.create(function()
			sampShowDialog(ProletDialog, "{ffdead}-2HELPER {ffffff}| Выбор банды", "{B313E7}Ballas\n{DBD604}Vagos\n{009F00}Grove\n{01FCFF}Aztecas\n{2A9170}Rifa\n{ffffff}Инструкторы", "Выбрать", "Отмена", DIALOG_STYLE_LIST) -- сам диалог
			while sampIsDialogActive(ProletDialog) do wait(100) end
			local _, button, list, _ = sampHasDialogRespond(ProletDialog) -- получаем ответ на диалог
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
		chat_message('Вы не авторизованы в админку. Введите команду еще раз после авторизации')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("Вы уже используете одну из команд. Дождитесь ее выполнения") return end
	local radius, gun, ammo = string.match(arg, "(%d+) (%d+) (%d+)")
	if radius ~= nil and radius ~= "" and gun ~= nil and gun ~= "" and ammo ~= nil and ammo ~= "" then
		--if tonumber(gun) < 22 and tonumber(gun) > 31 or tonumber(gun) == 26 or tonumber(gun) == 27 then chat_message("Доступный список оружия: с 22 по 31, запрещены 26 и 27") return end
		if tonumber(ammo) < 1 and tonumber(ammo) > 500 then chat_message("Доступно от 1 до 500 патронов за раз") return end
		chat_message("Начинаем выдавать оружие")
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
				chat_message('Выдано {ffdead}'..gun..' {ffffff}оружие с {ffdead}'..ammo..' {ffffff}патронами игроку {ffdead}'..sampGetPlayerNickname(v), 0xffdead)
				kolvo = kolvo + 1
				Log(v)
			end
			chat_message('Выдача оружия закончена. Выдано оружие {ffdead}'..kolvo..' {ffffff}игрокам')
			players = {}
			kolvo = 0
			rgive = false
		end)
	else chat_message("Неверно указаны параметры (Используйте: /rygivegun [радиус] [оружие] [количество патрон])") return end
end

function cmd_rysetarm(arg)
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('Вы не авторизованы в админку. Введите команду еще раз после авторизации')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("Вы уже используете одну из команд. Дождитесь ее выполнения") return end
	local radius, ammo = string.match(arg, "(%d+) (%d+)")
	if radius ~= nil and radius ~= "" and ammo ~= nil and ammo ~= "" then
		if tonumber(ammo) < 0 and tonumber(ammo) > 200 then chat_message("Доступно от 0 до 200 брони") return end
		chat_message("Начинаем устанавливать броню")
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
				chat_message('Выдано броня ('..ammo..'){ffffff} игроку {ffdead}'..sampGetPlayerNickname(v), 0xffdead)
				kolvo = kolvo + 1
				Log(v)
			end
			chat_message('Выдача брони закончена. Выдано {ffdead}'..kolvo..' {ffffff}игрокам')
			players = {}
			kolvo = 0
			rgive = false
		end)
	else chat_message("Неверно указаны параметры (Используйте: /rysetarm [радиус] [количество брони])") return end
end

function cmd_rysetskin(arg)
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('Вы не авторизованы в админку. Введите команду еще раз после авторизации')
		sampSendChat('/alogin')
		return
	end
	if rgive then chat_message("Вы уже используете одну из команд. Дождитесь ее выполнения") return end
	local radius, ammo = string.match(arg, "(%d+) (%d+)")
	if radius ~= nil and radius ~= "" and ammo ~= nil and ammo ~= "" then
		if tonumber(ammo) < 1 and tonumber(ammo) > 311 then chat_message("Доступны скины от 1 до 311") return end
		chat_message("Начинаем устанавливать скины")
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
				chat_message('Выдан скин ('..ammo..'){ffffff} игроку {ffdead}'..sampGetPlayerNickname(v), 0xffdead)
				kolvo = kolvo + 1
				Log(v)
			end
			chat_message('Выдача скинов закончена. Выдано {ffdead}'..kolvo..' {ffffff}игрокам')
			players = {}
			kolvo = 0
			rgive = false
		end)
	else chat_message("Неверно указаны параметры (Используйте: /rysetskin [радиус] [скин])") return end
end


function cmd_sskin(arg)
	if getGameGlobal(AdminLevelGlobal) < 1 and getGameGlobal(AdminLevelGlobal) ~= -2 then
		chat_message('Вы не авторизованы в админку. Введите команду еще раз после авторизации')
		sampSendChat('/alogin')
		return
	end
	local skin = string.match(arg, "(%d+)")
	if skin ~= nil and skin ~= "" then
		sampSendChat('/ysetskin '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))..' '..skin)
	else chat_message("Неверно указаны параметры (Используйте: /sskin [скин])") return end
end

function sampev.onServerMessage(color, text)
	if text:find('Оружие (.+) выдано игроку (.+)') then return false end
	if text:find("Вы авторизировались как администратор (%S+) уровня") then
		setGameGlobal(AdminLevelGlobal, tonumber(text:match("Вы авторизировались как администратор (%S+) уровня")))
		Log(getGameGlobal(AdminLevelGlobal))
	end
	if text:find('Права администратора отключены') then setGameGlobal(AdminLevelGlobal, 0) end
	if text:find('SMS: (.+). Отправитель: (%S+)%[(%S+)%]') and smshere then
		local _, __, id123 = text:match('SMS: (.+). Отправитель: (%S+)%[(%S+)%]')
		Log('Был телепортирован игрок '..tonumber(id123))
		sampSendChat('/gethere '..tonumber(id123))
		return false
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if text:find('Пароль должен состоять из латинских букв и цифр') then
		if ini.cfg.password == "" then chat_message("Для полноценного использования скрипта поставьте пароль в {ffdead}ini конфиге") return true end
		sampSendDialogResponse(dialogId, 1, 0, ini.cfg.password)
		return false
	end
end

function Log(text)
	if DEBUG then print(text) end
end