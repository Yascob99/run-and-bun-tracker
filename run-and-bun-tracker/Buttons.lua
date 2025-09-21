-- Button attributes:
	-- type : button Type
	-- visible() : when the button is visible / active on screen

ButtonType = {
	singleButton = 0,
		-- text : button text
		-- box : total size of the button
		-- backgroundcolor : {1,2} background color
		-- textcolor : text color
		-- onclick : function triggered when the button is clicked.
	horizontalMenu = 1,
		-- model : variable in LayoutSettings.menus
		-- box : total size of the menu
	horizontalMenuBar = 2,
		-- model : variable in LayoutSettings.menus
		-- box : total size of the menu
		-- visibleitems : total amount of visible items
		-- firstvisible : first visible item
	verticalMenu = 3,
		-- model : variable in LayoutSettings.menus
		-- box_first : size of first element of menu
	pokemonteamMenu = 4,
		-- team : player index
		-- text : title text
		-- position : {X,Y} of top-left
	rngViewButtons = 5,
		-- position() : {X,Y} of top-left (function since it varies)
		-- buttonsize : size of rng view buttons
	encounterSlots = 6,
		-- box_first : size of first slot text
		-- selectedslot : array of boolean values
		-- model : variable in LayoutSettings.menus
	pickupData = 7,
		-- box_first : place of first element
	catchData = 8
		-- enabled() : array of enabled items
		-- text : array of item text
		-- data() : array of data
		-- box_first : size of first element of menu
		-- onclick(i) : function triggered when the button is clicked
}

Buttons = {
	{
		type = ButtonType.singleButton,
		visible = function()
			return true
		end,
		text = 'Export Mons',
		box = {
			GraphicConstants.SCREEN_WIDTH + GraphicConstants.RIGHT_GAP  / 2 - 30,
			GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + GraphicConstants.DOWN_GAP - 17,
			60,
			13
		},
		backgroundcolor = {0xFF00AAFF, 0xFF000055},
		textcolor = 0xFF00AAFF,
		onclick = function()
			FileManager.exportCurrentMons("exportedMons.txt")
			return
		end
	},
	{
		type = ButtonType.horizontalMenu,
		visible = function()
			return true
		end,
		model = 'main',
		box = {
			0,
			GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + 1,
			GraphicConstants.SCREEN_WIDTH,
			15
		}
	},
	{
		type = ButtonType.pokemonteamMenu,
		visible = function()
			return LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.TRAINER
		end,
		text = 'Player Data',
		team = 1,
		position = {4, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + 40}
	},
	{
		type = ButtonType.pokemonteamMenu,
		visible = function()
			return LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.TRAINER
		end,
		text = 'Enemy Data',
		team = 2,
		position = {4, GraphicConstants.UP_GAP + GraphicConstants.SCREEN_HEIGHT + 120}
	},
	
		onclick = function(i)
			forms.destroyall()
			if i == 1 then
				Forms.formhandle = forms.newform(250, 130, 'Change Pokemon')
				Forms.dropdownhandle = forms.dropdown(Forms.formhandle, PokemonData.name, 75, 15, 80, 30)
				forms.button(Forms.formhandle, 'Accept', Forms.onChangeCatchPokemonClick, 75, 50, 80, 30)
			elseif i == 2 then
				Forms.formhandle = forms.newform(250, 130, 'Change Cur. HP')
				Forms.texthandle = forms.textbox(Forms.formhandle, Program.catchdata.curHP, 80, 30, 'UNSIGNED', 75, 15)
				forms.button(Forms.formhandle, 'Accept', Forms.onChangeCatchCurHPClick, 75, 50, 80, 30)
			elseif i == 3 then
				Forms.formhandle = forms.newform(250, 130, 'Change Max. HP')
				Forms.texthandle = forms.textbox(Forms.formhandle, Program.catchdata.maxHP, 80, 30, 'UNSIGNED', 75, 15)
				forms.button(Forms.formhandle, 'Accept', Forms.onChangeCatchMaxHPClick, 75, 50, 80, 30)
			elseif i == 4 then
				Forms.formhandle = forms.newform(250, 130, 'Change status')
				Forms.dropdownhandle = forms.dropdown(Forms.formhandle, PokemonData.status, 75, 15, 80, 30)
				forms.button(Forms.formhandle, 'Accept', Forms.onChangeCatchStatusClick, 75, 50, 80, 30)
			elseif i == 5 then
				Forms.formhandle = forms.newform(250, 130, 'Change Ball')
				Forms.dropdownhandle = forms.dropdown(Forms.formhandle, {'Master Ball', 'Ultra Ball', 'Great Ball', 'Poke Ball', 'Safari Ball'}, 75, 15, 80, 30)
				forms.button(Forms.formhandle, 'Accept', Forms.onChangeCatchBallClick, 75, 50, 80, 30)
			end
		end
	}			