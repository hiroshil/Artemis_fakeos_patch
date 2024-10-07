----------------------------------------
-- 初期化
----------------------------------------
-- ■ lua読み込み
function system_loadinglua()
	e:tag{"skip",		allow="0"}	-- 停止しておく
	e:tag{"automode",	allow="0"}	-- 停止しておく
	e:tag{"autosave",	allow="0"}	-- 停止しておく

	-- luaの登録
	local luafile = {
		-- system
		{"adv/var",			need=true },	-- 内部変数
		{"adv/varstack",	need=true },	-- 変数stack
		{"adv/fileio",		need=true },	-- ファイル入出力 / system
		{"adv/fsave",		need=true },	-- ファイル入出力 / saveload
		{"adv/parse",		need=true },	-- parse csv
		{"adv/func",		need=true },	-- 汎用関数群
		{"adv/wasm"},						-- wasm

		-- base system
		{"adv/system",		need=true },	-- システム制御
		{"adv/conf",		need=true },	-- システム初期動作
		{"adv/mainloop",	need=true },	-- スクリプト制御
		{"adv/vsync",		need=true },	-- vsync制御
		{"adv/autoskip",	need=true },	-- auto/skip制御
		{"adv/button",		need=true },	-- ボタン制御
		{"adv/select",		need=true },	-- 選択肢制御
		{"adv/keyconfig",	need=true },	-- keyconfig制御
		{"adv/keyevent",	need=true },	-- system event制御
		{"adv/quickjump",	need=true },	-- quickjump制御

		-- game system
		{"adv/adv",			need=true },	-- ADV制御
		{"adv/delay",		need=true },	-- delay制御

		-- message
		{"msg/message",		need=true },	-- メッセージ制御
		{"msg/line",		need=true },	-- メッセージ制御 / LINE
		{"msg/lang",		need=true },	-- メッセージ多言語
		{"msg/mw",			need=true },	-- メッセージウィンドウ
		{"msg/ui",			need=true },	-- UIメッセージ
		{"msg/tablet",		need=true },	-- タブレットUI

		-- image
		{"image/boot",		need=true },	-- 起動関連
		{"image/image",		need=true },	-- 画像汎用
		{"image/image_sys",	need=true },	-- system
		{"image/image_bg",	need=true },	-- BG/EV/CG
		{"fg"},								-- 立ち絵
		{"image/image_act",	need=true },	-- アクション制御
		{"image/shader",	need=true },	-- シェーダー
		{"image/cache",		need=true },	-- キャッシュ制御

		-- media
		{"media/bgm",		need=true },	-- BGM
		{"media/se",		need=true },	-- SE / Voice
		{"media/sysse",		need=true },	-- SystemSE
		{"media/movie",		need=true },	-- 動画

		-- script
		{"extend/adv_mw",	need=true },	-- ADV MW制御
		{"extend/script",	need=true },	-- スクリプトタグ管理
		{"extend/user",		need=true },	-- user拡張管理
--		{"extend/staff/staff"},				-- staffroll

		-- ui
		{"ui/title",		need=true },	-- タイトル画面
		{"ui/dialog",		need=true },	-- dialog制御
		{"ui/backlog",		need=true },	-- バックログ制御
		{"ui/config",		need=true },	-- config制御
		{"ui/conf_mw"},						-- pico config制御
		{"ui/save"},						-- save/load制御
		{"ui/favo"},						-- お気に入りボイス制御
		{"ui/menu"},						-- 右クリックメニュー制御
--		{"ui/sceneback"},					-- シーンバック制御

		-- extra
		{"extra/extra"},					-- 鑑賞
		{"extra/cg"},						-- CG鑑賞
		{"extra/scene"},					-- SCENE鑑賞
		{"extra/bgm"},						-- BGM鑑賞
		{"extra/bgmctrl"},					-- BGM鑑賞コントロール
		{"extra/etc"},						-- MOVIE鑑賞等
		{"extra/exfg"},						-- FG鑑賞
	}
	local luafilefg = {
		"image/e-mote",		-- 立ち絵 / E-mote
		"image/image_l2d",	-- 立ち絵 / Live2D
		"image/image_fg",	-- 立ち絵
	}
	local dbfl = "debug/lua/index.lua"

	-- lua読み込み
	for i, v in ipairs(luafile) do
		local name = v[1]

		-- fgは自動で読み分ける
		if name == "fg" then
			-- debug
			if e:isFileExists(dbfl) and e:isFileExists("debug/dbase.ini") then
				local px = luafilefg[#luafilefg]
				e:include('system/'..px..'.lua')

			-- auto
			else
				for i2, v2 in ipairs(luafilefg) do
					local file = 'system/'..v2..'.lua'
					if e:isFileExists(file) then
						e:include(file)
						break
					end
				end
			end

		-- 読み込み
		else
			local file = 'system/'..name..'.lua'
			if e:isFileExists(file) then
				e:include(file)

			-- 必要なファイルが見つからない場合はエラーを出す
			elseif v.need then
				e:tag{"debug", mode="1", level="2"}
				e:debug(file.."が読み込めませんでした")
			end
		end
	end
	allkeyoff()				-- 入力停止

	----------------------------------------
	-- OSとバージョン
	game = { path={} }
	local nm = get_artemis("os")
	if nm == "iphone" then nm = "ios" end			-- iOSは名前を書き換えておく
	if nm == "webassembly" then nm = "wasm" end		-- WebAssemblyは名前を変えておく
game.os = "windows"
	game.trueos = nm

	-- 画面サイズ
	local w = get_artemis("screen_width")
	local h = get_artemis("screen_height")
	game.width	= w
	game.height	= h
	game.centerx = math.floor(w / 2)
	game.centery = math.floor(h / 2)

	----------------------------------------
	-- debug
	if e:isFileExists(dbfl) then
		e:include(dbfl)

		-- fake OS
		local d = deb and deb.fake
		if d and game.os ~= "vita" and game.os ~= "ps4" then
			if d == 'auto' then
					if w ==  960 then d = 'vita'
				elseif w == 1920 then d = 'ps4'
				elseif w == 1280 then d = 'switch'
				else d = 'windows' end
			end
game.os = "windows"
		end
	end

	----------------------------------------
	-- 機種判定
	local tbl = {
		--						PS		CS		SP		touch	exit				PS		CS
		windows = { fakeos = {	nil,	nil,	nil,	true,	true }, trueos = {	nil,	nil  } },
		android = { fakeos = {	nil,	nil,	true,	true,	true }, trueos = {	nil,	nil  } },
		ios		= { fakeos = {	nil,	nil,	true,	true,	nil  }, trueos = {	nil,	nil  } },
		ps4		= { fakeos = {	true,	true,	nil,	nil,	nil  }, trueos = {	true,	true } },
		vita	= { fakeos = {	true,	true,	nil,	true,	nil  }, trueos = {	true,	true } },
		switch	= { fakeos = {	nil,	true,	nil,	true,	nil  }, trueos = {	nil,	true } },
		wasm	= { fakeos = {	nil,	nil,	nil,	true,	nil  }, trueos = {	nil,	nil  } },
	}
	local gos = game.os
	local tos = game.trueos
	local os1 = tbl[gos].fakeos		-- 仮想OS
	local os2 = tbl[tos].trueos		-- 実機
	game.ps = os1[1]		-- true : PS4/Vita
	game.cs = os1[2]		-- true : CS機
	game.pa = not os1[2]	-- true : CS機以外
	game.sp = os1[3]		-- true : smartphone
	game.touch  = os1[4]	-- true : touch ok
	game.exitbtn= os1[5]	-- true : exit button ok
	game.trueps = os2[1]	-- true : PS4/Vita
	game.truecs = os2[2]	-- true : CS機
	if gos == "windows" then game.pc = true end
	if gos == "switch"  then game.sw = true end

	----------------------------------------
	-- CS用
	local px = 'system/extend/trophy.lua'
	if e:isFileExists(px) then
		e:include(px)
		cs.init()
	end

	----------------------------------------
	-- wasm専用
	if wasm and tos == "wasm" then wasm.init() end

	----------------------------------------
	-- 変換したcsv.lua
	local name = "list_"..gos
	e:include("system/table/"..name..".tbl")

	-- script.ini確認
	system_scriptini()

	----------------------------------------
	-- 設定
	screen_init()	-- 画面初期化
end
----------------------------------------
-- ■ script.ini確認
function system_scriptini()
	local px = "script.ini"
	local md = "init"
	if isFile(px) then
		local p = parseIni(px)
		for i, v in ipairs(p) do
			if v:find(";") then v = v:gsub(";.*", "") end

			-- mode
			if v:sub(1, 1) == '[' then
				local s = v:gsub("%[(.+)%].*", "%1")
				md = s

			-- init param
			elseif md == 'init' then
				local a = explode("=", v)
				if a[2] then
					if debug_flag then console("overwrite : "..a[1].." => "..a[2]) end
					init[a[1]] = a[2]
				end
			end
		end
	end
end
----------------------------------------
-- ■ データ読み込み
function system_dataloading()
	load_system()	-- $g→sys
	load_global()	-- $g→gscr
	conf = fload_pluto(init.save_config)

	-- 初回起動
	local s = init.game_savedatacheck
	if not conf then

		-- save check
		if s then sys.savecheck = s end

		-- config初期化
		config_default()

		-- 復旧を試みる
		e:tag{"var", name="t.c", system="get_exe_parameter", writelocal="1"}
		local c = e:var("t.c.recovery")
		if c == "save" then
			message("通知", "セーブデータをの復元を試みます")

			local px = e:var("s.savepath")
			local mx = game.qsavehead
			local hd = init.save_prefix
			local c  = nil
			local t  = {}
			for i=1, mx do
				local fl = px.."/"..hd..string.format("%04d.dat", i)
				if isFile(fl) then
					table.insert( t, i )
					c = i
				end
			end
			if c then
				local z  = {}
				local d  = {}
				local mx = #t
				for i, v in ipairs(t) do
					local fl = hd..string.format("%04d", v)
					z[i] = {
						text = { text="is broken" },
						title = {},
						date = 0,
						file = fl,
					}
					d[fl] = true
				end
				sys.saveslot = z			-- slot情報
				sys.saveslot.check = d		-- 保存状態
				sys.saveslot.count = c		-- 使用数
			end
		end

	-- 初回以外
	else
		-- セーブデータのver確認
		if s and sys.savecheck ~= s then
			tag_dialog({ title="error", message="Bad savedata." }, "exit")

		-- configのデータが壊れていたら初期化する
		elseif conf and ( not conf.bgm or not conf.se or not conf.voice or not conf.aspeed or not conf.mspeed ) then
			tag_dialog({ title="caution", message="System data has been initialized." })
			config_default()
		end
	end
end
----------------------------------------
-- ■ 初期化
function system_initialize()
	----------------------------------------
	-- 各種操作を禁止する
	e:tag{"alreadyread",  mode="0"}	-- 既読データを保存しない
	e:tag{"writebacklog", mode="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"backlog",	allow="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"hide",		allow="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"rclick",		allow="0"}	-- 使用しないので常に"0"にしておく
	e:tag{"skip",		allow="0"}	-- 停止しておく
	e:tag{"automode",	allow="0"}	-- 停止しておく
	e:tag{"autosave",	allow="0"}	-- 停止しておく

	-- setonpushを停止しておく
	for i=1, init.max_keyno do e:tag{"delonpush", key=(i)} end

	-- keyconfigを停止しておく
	for i=0, 16 do e:tag{"keyconfig", role=(i), keys=""} end
--	e:tag{"keyconfig", role="0", keys="1,13"}
--	e:tag{"keyconfig", role="1", keys="2,27"}
	e:tag{"keyconfig", role="0", keys=(getexclick())}	-- dummy click

	e:setUseMultiTouch(3)			-- マルチタッチ数を制限
--	e:setFlickSensitivity(-1)		-- エンジンのフリックを無効化
	e:setEventFilter(eventFilter)	-- イベント捕捉

	-- ctrlスキップ制御 / eventFilter()で処理するため飛び先はダミー
	e:tag{"setoncontrolskipin" , label="last"}
	e:tag{"setoncontrolskipout", label="last"}

	----------------------------------------
	-- 初期化
	windows_screeninit()-- screen size
	vartable_init()		-- 変数初期化
	storage_path()		-- storage path
	system_cache()		-- ui cache
	font_init()			-- font設定
	setonpush_init()	-- key設定
	key_reset()			-- key flag
	reset_backlog()		-- 念のためバックログをリセット
	sesys_reset()		-- SE初期化
	volume_master()		-- ボリューム復帰
	sysse("boot")		-- 無音SEを再生してエンジンを初期化しておく
	init_tapeffect()	-- tap effect
	shader_init()		-- シェーダー初期化

	----------------------------------------
	-- システムスクリプトをキャッシュしておく
	e:enqueueTag{"call", file="system/ui.asb",		 label="last"}
	e:enqueueTag{"call", file="system/save.asb",	 label="last"}
	e:enqueueTag{"call", file="system/script.asb",	 label="last"}

	----------------------------------------
	-- ■ 登録
	e:setEventHandler{
		onSave		   = "store",			-- セーブ直前に呼ばれる
		onLoad		   = "restore",			-- ロード直後に呼ばれる
		onClickWaitIn  = "keyClickStart",	-- キークリック待ち開始時に呼ばれる
		onClickWaitOut = "keyClickEnd",		-- キークリック待ち終了時に呼ばれる
		onDebugSkipOut = "exskip_end",		-- debugSkip停止時
		onEnterFrame   = "vsync"
	}

	----------------------------------------
	-- 認証
	if game.os == "114514" then
		local nm = "system/extend/auth.lua"
		if isFile(nm) then
			e:include(nm)		-- 認証
			authentication()	-- 認証開始
		end

	-- loading
	elseif game.trueos == "wasm" then
		scr.ip = { file="brandlogo" }
		estag("init")

		-- お気に入りボイスloading
		if init.game_favovoice == "on" then
			wasm_favolock()
			estag{"cache_wasmfavo"}
		end

		-- 素材loading
		estag{"cache_wasmloading"}
		estag()
	end
end
----------------------------------------
-- ■ 起動チェック
function system_starting()

	e:tag{"autosave",	allow="1"}	-- autosave有効化
	allkeyon()						-- キー入力許可
	autoskip_uiinit(true)			-- ui用ctrlskip有効

	-- フルスクリーン
	if not flag_fullscreen then
		fullscreen_on()
		flag_fullscreen = true		-- reset時に実行しない
	end
	mouse_autohide()				-- windows : mouse自動消去設定
	window_button()					-- windows : OSボタン設定
	loading_off()

	--------------------------------
	-- suspend
	local sus = init.save_suspend
	if sus then
		local file = sv.makefile(sus)..".dat"
		if e:isFileExists(e:var("s.savepath").."/"..file) then
			suspend_load = true
			eqtag{"load", file=(file)}
			return
		end
	end

	--------------------------------
	-- debug
	local dflag = true
	if debug_flag and not androidreset then dflag = debugInit() end

	-- スクリプトから起動
	local fl = getScriptStartup()

	-- stop
	if dflag == "stop" then
		e:tag{"jump", file="system/ui.asb", label="stop"}

	-- movie復帰
	elseif androidreset then
		local p = androidreset
		local b = p.ip.block
		local c = p.ip.count or 0
		scr = p
		readScript(p.ip.file)
		scr.ip.block = b		-- p.ip.block
		scr.ip.count = c + 1	-- p.ip.count
		androidreset = nil
--		scriptMainAdd()
		movie_play_exit(e)
		scr.advinit = nil
		adv_init()
		flip()
		e:tag{"jump", file="system/script.asb", label="main"}

	-- logo skip
	elseif systemreset then
		systemreset = nil
		base_fontcache()
		eqtag{"jump", file="system/first.iet", label="title"}

	-- game start / script
	elseif dflag and fl then
		title_start2(fl)

	-- game start
	elseif dflag then
		eqtag{"jump", file="system/first.iet", label="game_start"}
	end
end
----------------------------------------
-- ■ 起動時に１回だけ読み込まれる
function screen_init()

	-- 中心座標
	game.ax = game.centerx
	game.ay = game.os == 'vita' and game.centery - 2 or game.centery

	-- ゲーム倍率 	1:1280 0.75:960  1.5:1920
	--				1:1920 0.75:1280 0.5:960
	local s = init.game_scale
	game.scalewidth  = s[1]
	game.scaleheight = s[2]
	game.sax = s[1] / 2
	game.say = s[2] / 2
	game.scale = 1
	if game.width ~= s[1] then game.scale = game.width / s[1] end

	-- フリックエリア
	local a = 100
	if init.menu_area then a = repercent(init.menu_area, game.width) end
	game.flickarea = a

	-- エンジンバージョン
	game.engver = getArtemisMode("ver")

	-- セーブデータの最大値などを作っておく
	game.savemax = init.save_page * init.save_column		-- ページ数×１ページに表示できる数
	if init.save_etcmode == "quick" then
		game.qsavehead = game.savemax						-- quicksaveの先頭番号
		game.asavehead = game.qsavehead + init.qsave_max	-- autosaveの先頭番号
	else
		game.asavehead = game.savemax						-- autosaveの先頭番号
		game.qsavehead = game.asavehead + init.asave_max	-- quicksaveの先頭番号
	end
end
----------------------------------------
-- パス初期化
function storage_path()
	local s = init.system
	local tros = game.trueos
	local gmos = game.os
	local image = s.image_path
	local sound = s.sound_path
	local movie = s.movie_path
	local vita  = gmos == "vita" and tros == "windows" and s.fake
	if vita then sound = vita.sound_path end

	----------------------------------------
	-- magicpathcheck
	local setpath = function(nm, path)
		local s = path:sub(-1)
		if s == '/' then
			e:debug(nm.." "..path.." パスの末尾に / が付いていると正しく動作しません")
		else
			e:setMagicPath{nm,	path}
		end
	end

	----------------------------------------
	-- magicPath
	for k, v in pairs(init.mpath.image) do setpath(k, image..v) end
	for k, v in pairs(init.mpath.sound) do setpath(k, sound..v) end
--	for k, v in pairs(init.mpath.movie) do setpath(k, movie..v) end

	----------------------------------------
	-- movieはmagicpathが使えないので特殊処理
	game.path.movie	= movie			-- movie path

	----------------------------------------
	-- etc path
	game.path.rule		= image..init.mpath.image.rule..'/'
--	game.path.facemask	= image..init.face_path..'/mask'

	----------------------------------------
	-- ui path
	set_uipath()

	----------------------------------------
	-- 拡張子
	game.fgext	  = s.fg_ext		-- 立ち絵
	game.ruleext  = s.rule_ext		-- rule
	game.movieext = s.movie_ext		-- movie
	game.soundext = s.sound_ext		-- sound
	if vita then game.soundext = s.fake.sound_ext end

	----------------------------------------
	-- etc
	game.mwid			= init.mwid				-- mwid
	game.se_track		= s.se_track or 20		-- se track		

	----------------------------------------
	-- 何か読み込んでおかないとVRAMのゴミが残る問題の回避
--	lyc2{ id="-273", file=(init.black), x=(-game.centerx), y=(-game.centery), anchorx=(game.centerx), anchory=(game.centery)}
	lyc2{ id="-273", file=(init.black) }

	-- emote cache
	if emote then emote.cacheinit() end

	-- mask
	game.clip = "0,0,"..game.width..","..game.height
	if init.vita_crop and game.os == 'vita' then
		if tros == 'vita' then
			game.clip = "0,0,960,540"
			game.crop = 4
			lyc2{ id="zzzz.dw", width="960", height="4", color="0xff000000", y="540"} 
		else
			game.clip = "0,2,960,540"
			game.crop = 2
			lyc2{ id="zzzz.up", width="960", height="2", color="0xff000000", y="0"} 
			lyc2{ id="zzzz.dw", width="960", height="2", color="0xff000000", y="542"} 
		end
	end

	----------------------------------------
	-- debug
	if debug_flag then
		setpath("help", "debug/image/help")
	end

	----------------------------------------
	-- loading
	local v = csv.mw or {}
	if v.loading and v.saving then
		local pl = v.loading
		local ps = v.saving
		local path = get_uipath()
		lyc2{ id=(pl.id), file=(path..pl.file), clip=(pl.clip), x=(pl.x), y=(pl.y)}
		lyc2{ id=(ps.id), file=(path..ps.file), clip=(ps.clip), x=(ps.x), y=(ps.y)}
		loading_icon = true
		loading_on()
	end
	flip()
end
----------------------------------------
-- ui path / 多言語切り替え
function set_uipath()
	local ln = get_language("ui")
	local nm = init.lang[ln]
	local px = init.system.ui_path..nm
--	game.path.ui = px
	e:setMagicPath{"ui", px:sub(1, -2)}
end
----------------------------------------
-- ui path取得
function get_uipath(file, flag)
	local px = ":ui/"
	if file then
		if file:find(":") then px = "" end
			if isFile(px..file..".png")  then px = px..file..".png"
		elseif isFile(px..file..".jpeg") then px = px..file..".jpeg"
		elseif isFile(px..file..".jpg")  then px = px..file..".jpg"
		elseif flag then px = nil
		else
			px = px..file
			message("注意", file, "は存在しないか破損したui画像です")
		end
	end
	return px
end
----------------------------------------
-- 
----------------------------------------
-- エンジン動作状態を返す
function getArtemisMode(mode)
	local r  = false

	----------------------------------------
	-- 動作モード
	local md = "normal"
	if emote and emote.l2d then
		md = "live2d"
	elseif emote then
		md = "emote"
	end

	----------------------------------------
	-- modeにverが指定されている場合はversionを返す
	if mode == "ver" then
		if md == "live2d" then
			r = "Live2D"
		elseif md == "emote" then
			r = getEmoteVersion("E-mote ")
		else
			r = "r"..e:var("s.engineversion")
		end

	-- modeが指定されている場合はtrue/falseを返す
	elseif mode then
		r = md == mode

	-- 動作modeを返す
	else
		r = md
	end
	return r
end
----------------------------------------
-- ゲーム動作状態を返す
function getGameMode(mode)
	local r = "init"						-- 初期化中
	if flg then
			if flg.dlg2	then r = "system"	-- windows exit dialog
		elseif flg.dlg	then r = "dlg"		-- dialog
		elseif flg.ui	then r = "ui"		-- ui
		else				 r = "adv" end	-- ゲーム画面
	end

	-- キー入力判定
	if mode == "key" and r ~= "adv" then r = "ui"
	elseif mode == "all" then
		if  flg.waitflag then r = "wait"
		elseif flg.trans then r = "trans" end
	end
	return r
end
----------------------------------------
-- E-mote Versionを返す
function getEmoteVersion(str)
	local r = e:var("s.engineversion")
	if get_artemis("is_emote") == 1 then
		r = e:getEmoteVersion()	-- 一行目がSDKバージョン、二行目がE-mote SDKのビルド日時
		r = r:gsub("([0-9%.]+).*", "%1")
		if str then r = str..r end
	end
	return r
end
----------------------------------------
-- wasmチェック
function checkWasm()
	return game.os == "wasm"
end
----------------------------------------
-- wasmsyncチェック
function checkWasmsync()
	return game.os == "wasm" and init.game_wasmsync
end
----------------------------------------
-- 画面サイズより大きい範囲は切る
function screen_crop(id)
	tag{"lyprop", id=(id), intermediate_render="2", clip=(game.clip)}
end
----------------------------------------
