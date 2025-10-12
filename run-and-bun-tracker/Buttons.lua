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
	encounterSlots = 6,
		-- box_first : size of first slot text
		-- selectedslot : array of boolean values
		-- model : variable in LayoutSettings.menus
}

Buttons = {
	{
		type = ButtonType.singleButton,
		visible = function()
			return true
		end,
		text = 'Export Mons',
		box = {
			Constants.Graphics.SCREEN_WIDTH + Constants.Graphics.RIGHT_GAP  / 2 - 30,
			Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + Constants.Graphics.DOWN_GAP - 17,
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
			Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 1,
			Constants.Graphics.SCREEN_WIDTH,
			15
		}
	},
	{
		type = ButtonType.horizontalMenu,
		visible = function()
			return LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.ENCOUNTERS 
		end,
		model = 'encounters',
		box = {
			0,
			Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 17,
			Constants.Graphics.SCREEN_WIDTH,
			13
		}
	},
	{
		type = ButtonType.pokemonteamMenu,
		visible = function()
			return LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.TRAINER
		end,
		text = 'Player Data',
		team = 1,
		position = {4, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 40},
		selectable = function(slot)
			return Program.trainerPokemonTeam[slot].pkmID ~= 0
		end
	},
	{
		type = ButtonType.pokemonteamMenu,
		visible = function()
			return LayoutSettings.menus.main.selecteditem == LayoutSettings.menus.main.TRAINER and Battle.isInBattle
		end,
		text = 'Enemy Data',
		team = 2,
		position = {4, Constants.Graphics.UP_GAP + Constants.Graphics.SCREEN_HEIGHT + 120},
		selectable = function(slot)
			return Program.enemyPokemonTeam[slot].pkmID ~= 0
		end
	}
}			