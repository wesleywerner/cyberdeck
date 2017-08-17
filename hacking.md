# hacking

This guide to hacking on the code for this project will hopefully be helpful to contributors and myself.

### phase one

The first phase of this project is to re-implement the original game logic, there will be no graphical parts, but there will be unit tests for checking data integrity and game logic.

### phase two

The second phase will implement the graphical interface. I intend using the Love framework for this, it is multi-platform and Lua.

The UI layout probably won't resemble the original much. Bringing the UI up to date is the main goal.

A secondary goal to consider is to provide a good experience for smaller devices, either by adjusting the same UI in-game, or by maintaining another view seperately. I prefer the latter. Since the game logic is not tied to any views, it will be very possible, and likely easier to maintain - less chance of UI regressions or bugs creeping across the two versions.

_These are first impressions on phase two, and subject to change_

### phase three

The third phase introduces new features to the game. It could even start concurrently with phase 2, if I feel like I am not coding enough already. See [new feature ideas](new feature ideas)

### functional design

I chose a model-view-controller pattern for seperating the game data from the logic, to fascilitate easier serialization for saving games, a functional design seemed to suit this well.

You can consider all source files as logic, and these modules do not reference any global data object. Instead, most modules provide a `create()` method to return a data entity. Other methods in the modules take these entities as parameters and perform their logic on them. For example, the `hardware.lua` module:

```
-- create a new chip burner, stored in local "hw"
hardware = require('hardware')
local hw = hardware:create("Chip Burner", 1)

-- later, we get the purchase price
local howmuch = hardware:getPrice(hw)
```

The entities we create will live in one table, affectionately thought of as the "db", which should live inside a single module only.

Worst case of hard-coding is limited to modules storing lookup lists to ensure data integrity. `hardware.lua` has a list of possible hardware types to ensure that we create a "chip burner" and not a "pizza oven" by mistake.

These logic modules are not factories, it is a horrible name and it won't be mentioned again.

# development environment

You will need:

* [LÖVE game framework](http://love2d.org/)
* [Lua 5.x](http://www.lua.org/)
* [Lua Rocks](https://luarocks.org/)

Just be sure your package manager has love >= 0.10.2, if not you will have to build it from source.

These commands are for apt-based systems, please adapt to them as needed.

```
# this should pull Lua5.1 in as a dependency
sudo apt-get install love luarocks
```

Install code linting and unit testing rocks:

```
sudo luarocks install luacheck && \
sudo luarocks install busted
```

# linting

Check the code syntax:

```
luacheck --no-unused-args src/*.lua
```

Check the syntax of the tests by ignoring the busted global:

```
luacheck --no-unused-args --std max+busted tests/*.lua
```

# testing

```
busted tests/*.lua
```

Check code coverage:

```
busted --coverage tests/*.lua
luacov
# check the tail for the summary
less luacov.report.out
```

For convenience this comes to the rescue:

```
alias bustit='busted tests/*.lua'
```

# notes

* The original game source can be found on [sourceforge](https://sourceforge.net/projects/decker/files/decker/Decker%201.12/). The `Help/Decker.rtf` file is particulary helpful.

* These ICE types were never implemented:
  * AST_CRASH

* These ICE abilities were never implemented:
  * hardened
  * phasing
  * trace and dump
  * trace and fry
  * killer
  * trace dump
  * trace burn

# variations from the original

* ICE names vary if they are of the hareded, phasing, crashing or lethal sub-types, these are implemented. The orignal game additionally had names lists for the combinations of lethal+hardened, lethal+phasing and lethal+crash sub-types. This is no longer the case. These combinations now simply use the "lethal" list of names.

* ICE behaviour flags "crash", "dump" and "fry" have changed to "crasher", "dumper" and "fryer".

* Originally you could not load two programs into your deck at the same time, or if you have a file transfer active, when in the matrix. This technical limitation has been removed, however you may still be limited in this fashion at a lower skill level, until you have the appropriate upgrades to allow asynchronous program loads.

### new feature ideas

These ideas are just that, subject to review and change. Basically anything that comes to mind, serious or silly.

#### replayability

The game can become a bit repetitive after a certain skill is reached. These ideas aim to address replayability:

* bring in new software as the game progresses. currently all software is available from the start.
* change contract descriptions as the game progresses.
* add new contract goals.
* add new node types with new matrix actions.
* add campaigns that follow a plot via multiple missions. these can have longer due dates: expose a political watershed before the election, or stop a mega corp from rolling out their new OS that will undermine society.
* redirect ICE to the wrong node (false alarm)
* consider: side/mini games as actions for new node types
* study at an online college to pass time, with a chance of revealing a new skill.
* choose a hacker class (warrior/stealth/white hat/black hat). each class has one ability that the others don't have.
* give XP for crashing ICE when the ICE entry node is deactivated (encourages combat)
* give XP for completing a mission without attacking or setting off any alert - cancelling an alert does not count (encourages stealth)
* stun attacks (for combat variety)
* the reflect software may be overpowered. limit it to a reasonable range.
* gateways that are locked, requiring a red, green or blue key to open.
* allow asynchronous program loading in the matrix with memory upgrades.

#### new missions

* Kill a target ICE
* kill all ICE in system
* Deactivate the I/O node that spawns ICE
* download all files in a data node or system

# questions new players might ask - or tips to become a better hacker

* a warning should be shown if the player starts a new chip project, and they don't own a chip burner.
* what is lifestyle and reputation, and how do they affect my game?
* why do I have so many types of chips (co processor, attack, defense...) in my decker? 
* when and how is my attack/defend rating modified?
* how do I heal?
* how do I turn off a red alert?
* do ICE come back after I crashed them?
* will I ever get reported to the police?
* how do I prevent the sysadmin from shutting down the system in a red alert?
* what happens if I get traced and how can I stop it?
* analyze a gateway or tapeworm before deceiving/decrypting. It reduces the ICE rating, increasing your chances.

