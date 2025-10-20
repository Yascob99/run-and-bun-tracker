# Run and Bun Tracker

## Table of Contents
- [General Information](#general-information)
- [Known issues/bugs](#known-issuesbugs)
- [Installation Guide](#installation-guide)
- [Other Features](#other-features)
    * [Previous/Current Run Data](#previouscurrent-run-data)
    * [Export Mons Button](#export-mons-button)
- [Future Features](#future-features)
- [Notes for Developers](#notes-for-developers)
## General Information

Run and Bun Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) used to better vistualize game information and automatically track your runs and encounters.

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/mkdasher/PokemonBizhawkLua). I also referenced the Run and Bun MGBA export script for lua and Ironmon Tracker for certain methods and important memory addresses to look for.

I sourced the sprites from [msikma's PokeSprite project](https://github.com/msikma/pokesprite/tree/master).

If you would like to contribute please let me know. I am working on this in my free time as a hobbyist. This is my first time working in lua so there may be some weird choices, inneficiencies, or bad practices.

## Controls
A+B+Start (z+x+enter bizhawk's with default keyboard bindings) - Start New Run

That's it for now.

## Known issues/bugs

- The script can take a while to load on first runs a new runs. This is due to certain functions having to run console commands due to lua not having the functionality natively. If I can get those functions working with a library then I can mitigate most of this issue.
- The Pokemon sprites can be bigger than the box. I am looking into alternative sprite sets or some way of refining this sprite set to work.
- A lot of the things I have tested are in the early parts of runs. While I expect there to be no issues, issues may arise, if they do please message me on discord or create an issue on github
- Roamers are not properly accounted for in the area encounters. This requires some extra work I have not done yet.
- When loading an existing run as a new run, there will be some inconsistencies with the evolution stage of the mon. The dupe detection should still work. Also any missed encounters will not be accounted for due to there being no way to track missed encounters that occured when the tracker was not running (this is **not** fixable)

## Installation Guide

1. Download and install prereqs for Bizhawk if you haven't already from [here](https://github.com/TASEmulators/BizHawk).

2. Download and unzip the [latest release of Run and Bun Tracker](https://github.com/Yascob99/run-and-bun-tracker/releases). It should be called run-and-bun-tracker.zip. Copy the contents of the zip folder.

3. Navigate to where you put Bizhawk. Open the Lua Folder then open the GBA folder. Paste the files you copied here.

4. If you did that correctly there should be a "run-and-bun-tracker.lua" in that directory as well as a "run-and-bun-tracker" folder.

5. Start the Emuhawk.exe back at the root folder of the Bizhawk. At the top click Tools > Lua Console.

6. In the new window that popped up click Script > Open Script. Then navigate to the "run-and-bun-tracker.lua" from earlier.

7. If you see output in your console, the script is now running! You will have to open the lua console every time. However you can just got File > Recent Scripts and choose the "run-and-bun-tracker.lua"

8. Open the rom as instructed. You can also open the rom and load your save/savestate. 

Please note that the tracker can only accurately track data if it has been used during the entire run. It will try it's best to guess on which encounters happened when, but there will likely be inconsistencies.

## Other Features

### Previous/Current Run Data
Your encounters from the current and previous runs are tracked! To find that data navigate to where the "run-and-bun-tracker.lua" is. Then open the run-and-bun-tracker folder.

The inside of this folder is the bulk of the code that makes up the tracker, however there are some files and folders you might find handy here.

After your first run a Runs.txt file will appear in the run-and-bun-tracker folder. This tracks your current attempt. If you have runs prior to the tracker you can create or edit and existing Runs.txt. It only contains the number of attempts.

Next in the attempts folder you can find all of your past attempts in folders titled after their run number. Inside of each of those files is data the tracker uses for keeping track of important data between sessions. It also has a .CSV file with your encounter. 

If you open up that CSV in any spreadsheet software it will list all of your encounters by route.

If you do run into issues with the tracker I will likely ask you to send the current attempt folder as part of the process of resolving the issue.

### Export Mons Button
You may have noticed the "Export Mons" button. Pressing this button will create a "exportedMons.txt" file in the
run-and-bun-tracker folder.

You can copy paste this into any of the [damage calculators](https://dekzeh.github.io/calc/) built for run and bun to import your party data.

I did want to initially have this copy into your clipboard, but due to limitations of lua and making it work on all oses I was unable to make that work.

## Future Features
- A lot of QOL and UI improvements. Right now the tracker is simple because I wanted to get the core functionality working. However now that that is working that will likely be my next priority after bugs.
- An options menu. I want to add more customizability of where things go. Most of what I've added could be easier to use with some user designated options.
- Web/External UI. One of the ways I could massively improve the UI would be to give the option for it to be external to the script. The UI via bizhawk is clunky and limited in resolution, additionally an external UI could be useful for seperating out parts of the UI for streaming. However I have yet to look to deeply into the viability of this, so it may not be possible or easy to impliment.
- I have thought about adding battle related functionality such as tracking stat drops/raises and estimating the AI's next move. However it would require a lot of reverse engineering of where the game stores things in ram for this mod as it does not often line up with the original version of the game. Since this can be a rather time consuming process, it will be low on my priority list.

## Notes for Developers
Since a lot of my code is borrowed from or inspired by other projects, I do not claim any ownership over this code.

A lot of the locations in ram are things I have personally located and you are free to use in other projects. Feel free to message me if you have any questions related to how the code functions, how I find that information or where the data is stored.