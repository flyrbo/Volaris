# Development Log

A quick lil log for the development of this script because 1. This was my first script in a long while and 2. I had to learn a lot of concepts and stuff to actually create this.

> **Disclaimer:** this was made for educational and testing purposes only.
> Using exploits can violate Roblox's Terms of Service and can get your
> account banned. Everything documented here was done on my own account and
> at my own risk. If you don't accept that, don't do any of this.

---

## Stage 0: Finding the game

I was playing a similar Paint an Album game and decided to see if there was one for Mangas (cuz lowkey I knew some really cool mangas with really cool cover arts and had to draw them). Thats when I saw this game. At first I thought it was AI slop because the UI elements seemed common in the industry of slop games but then as I played, I felt really wrong about this statement. I also had this urge to automate the process of walking on the green studs over and over again so I decided to use an executor (Use `Real` guys its lowkey the best exec out there rn) and hook up cobalt and dex to see whats up.

The first thing I was looking for was my own canvas. I was expecting each green stud to be located on a physical space in the workspace but I was completely wrong about this. Tbh, that would've been incredibly stupid for that to be the case to begin with since it would probably be really laggy. I quickly realised that, no matter where I looked, there was literally NO stored location for these studs. I felt like digging deeper because of this cuz I felt like I can really make a good script for this game while it being difficult to do.

## Stage 1: Sniffing server butt

My main principle and eureka moment was from getting my fucking studs reverted when I stepped on them. I realised the server was processing the validation for the stud completions and realised the server is probably handing me information of the cover someway somehow, so I started looking at the scripts I could find in RE and lo and behold (if thats how you say it).

What I found, in order:

- `ReplicatedStorage/Client/Systems/CanvasRender` is the renderer. It basically takes canvas data, draws it into a single `AssetService:CreateEditableImage`, and then displays it on a `SurfaceGui` (on my plot). It returned one image which explains the use of no parts.

- Now I checked for how the client receives the info. The server sends the data through `ReplicatedStorage/Shared/Packages/Net`. `RE/CanvasBuilt` gives the data as two flat byte buffers. Let me tell you how much of a headache I had figuring this shit out holy. Anyways in the buffer, `Layers` talks about which colour each cell belongs to, `Filled` is filled with binary for the studs, and some other info on the layer which isnt that important (still useful tho). For an Insane diff cover, thats around 426k cells per buffer (which created its own issues which ill talk about later).

- Now for the mathsy stuff thats gonna get used later (fuck me). 1 Cell is 1/3 a stud (Canvas.PixelStuds). index = `z*W + x + 1`. The brush radius comes from `Passes:GetBrushScale()` (to do even more amazing fuckassery with the movement algorithm).

- Studs are just cells where `Layers[i] == ActiveLayer` and `Filled[i] == 0` (as shown through buffer). It is redenered with `Paint.PaintMeColor`.

The biggest moment came to me (alongside the other stuff I mentioned with the game lagging) when I was looking at cobalt and seeing NO remotes being sent. I genuinely was about to crashout because I had no idea how client and server communicated, but then I clocked the server handles validation. What the client does tho is predict locally (with `CanvasRender:Predict` and `Sweep` reverting my studs back because server didnt confirm it within 3 seconds asshole). The server runs some math on the position of the HRP of your character through `RE/CanvasFills`. Since I prefer doing spoofing rather than automation (thus why I have 0 autofarm scripts created), I tried finding any vulns but obviously I couldn't (I will keep trying tho). Server handles basically everything so hitbox expands, firing fills, everything else just doesn't work.

## Stage 2: Cooking up the algorithm (+ AI)

The only idea I had was for the character to find a stud, walk to stud, find new stud, repeat. I knew this was naive but I had to have a foundation before I start. improvements can begin from there. Anyways, since I'm not a math guy whatsoever, I had no idea how to tackle this. I obviously had to learn some stuff and for that I asked AI (ChatGPT & Claude) for help. Please note this script isn't AI slop. I am using it for just learning purposes + optimising the script (explained later on). Through the AI, I had realised there are actual principles and problems regarding my situation, concepts I could learn about and use:

- **Travelling Salesman Problem**: The core principle talked about here is the "visit every point with the least travel". I dont want to explain the problem so if you are interested in creating autofarms or stuff like this, I recommend you research upon it. The issue with this is that as the input grows larger, the algorithm would become more and more complex to keep it optimised, or else it would hog the CPU like no other.

- **Bunching**: Considering 400k+ studs is literally impossible unless the algorithm is just a simple one, so that's why I thought about bunching up the studs. Bunching is essentially grouping the studs in a radius R (radius of the brush). This would basically replace the 400k+ studs into a workable amount, because now I won't be considering individual studs, but rather the groups of studs.

- **Nearest neighbour + 2-opt**: Basically to build a route based on nearest unvisited stops, then improving it with 2-opt. 2-opt (research more about this) takes 2 edges, reverses the middle of the path, then keep it if its more optimised. It prevents path crossing and darting around when a simple sweep can do the trick. I cap the passes so big routes dont eat fps and skip 2-opt completely if there are more than 1500 stops.

- **Rounds**: Since server handles validation, some of the studs wont get registered. I split the rounds into 2, where the first round sweeps everything up and the 2nd round cleans the unregistered studs.

- **Lawnmover coverage**: I will explain this in a later stage (Future me here: Stage 9) but basically it splits the input into parallel strips of land.

The first working version of this was already fast enough to finish covers without my help so I felt that these principles were extremely useful (though it could be further optimised)

## Stage 3: Repolishing code structure

Despite how much I loved my first script (because it was the first one ive ever made publicly), it was ass. There were so much things I could improve upon like the way I used Starlight as well as my code in general. Before I started developing this script, I felt like I had to redo the skeleton of it first (including the loader) with good practices for cheat scripts:

- Using a shared state table to reuse loops and functions rather than duping them on every execution. I did this through a getgenv() table.

- If an old instance of the script exists, destroy it before rebuilding. I do this through an unload guard.

- Doing a compat check with the executor before loading anything in. This is first done through the loader itself but further checks regarding Actor support, etc are done in good detail since some executors like to fake functions (cough cough yubx).

- All `while` loops read its bool toggle from the global state so unloading the UI will stop all logic. Connections live in one table and get disconnected together.

- I have put a fucking pcall wrap on every fucking thing I see. I swear to GOD the amount of unresolved errors I got in my old script could kill a mouse genuinely.
  
- I went coocoo trying to debug why both UI libs failed to boot WHEN IT WAS MY FUCKASS INTERNET. Anyways because of that I added like 100k lines of error handling and divertions and even using jsDelivr for the Nebula Icons lib. I also added a caching system for the libs. Credit to AI for giving me that idea.

After all of this was done, I pushed it all through ChatGPT (since claude refused) for a final improvement checklist to see what all I can do more for the script and change. I only added things that genuinely mattered since the big GPT would do more than what it is asked to do.

## Stage 4: UI Library

For the UI, I had been using **Starlight** (along with the Nebula Icon lib). Truly one of the best UI libraries there is and I cant wait for Gen2 (if its gonna drop. Also means im gonna have to update the entire script). With my previous script, I didnt really fully understand the level I could take the UI to and I planned on learning the capabilities of the library before I started making the UI itself (which is why you will notice some extra elements I didnt use in my old script). There is still a lot more that couldve been done which I am still experimenting upon. I also cant wait for Gen2 like I said before because from the sneek peaks, there are some REALLY cool features being added.

Anyways, because of the long wait between my old script and my new script, I have gotten rusty in using Starlight which was a struggle at the start. I decided to think this through along with the code structure repolish (Stage 3) so that I can use it in an efficient manner.

Something I still remembered and still happens to me is the errors the library produced me. I had no idea how to fix them but after going to the errored section of the lib itself, I had read and understood the code and fixed it with this script. The error i had while making this script was Starlight's `Destroying` handler destroying parent elements before nested elements so I just disconnected that handler and let the raw GUI destroy happen.

## Stage 5: Feature Checklist + Blatant Mode

Before creating one feature to the next, I wanted to have a list of features I needed ot make first. These things include the `auto paint` , `speed slider`, `live stats`, `cover queue`, `anti afk`, `blatant mode`, `visuals`, etc. The way I thought of them was by just playing with the script I already had and seeing what would be nice to have. I first implemented the blatant mode because I felt like it was the easiest to do right now since I already have a framework (the standard walking mode) and I wanted something faster. The server validates based on your replicated position so it was safe to add teleports (though it might get patched in the future).

The concept was that if the next group was faster to walk to, the standard walking would initiate (since there is still a delay for the teleport to happen and register compared to the possible 52 studs/s). If its slower to walk to, then teleport to it. Although it was somewhat alright to implement in terms of difficulty, there were some difficult aspects like the dwell between TPs. Anyways, this increased the rate from around 3300 studs/min to around 15000+ studs/min if its a sparse cover.

Since it involves teleports, its clearly a blatant cheat. Other players can see you vanish and appear from one corner to the other, which is why its in a toggle and the setting for it isnt saved in the config.

## Stage 6: Cover Queue

The basic idea was to have an input where users can type in the cover they wanted and the script would validate it and add it to a queue which gets loaded once the current cover is finished. It sounded easy but got pretty challenging when you thought about how to validate.

- I first thought of using MangaDex to validate the existence of the cover but this would be extremely inneficient for the user as I would need exact series names to match. Typing "Frieren vol 2" wouldn't get validated whatsoever, so then I thought why not leverage the game's search function itself and validate the cover through that, which is what I did. I used the search remote and grabbed the table, filtered it for the vol number the user gave and wack that into the queue. Also, note that I used AI to create the regex used to isolate the vol number from the manga name itself.

- The server doesn't error or say anything when I use `RF/LoadCover` to load an already completed cover, so I had to make a watchdog that checks for 8 seconds after every load to see if the canvas appeared and, if it didnt, would skip to the next queue.

- Indexing the player gallery was done to prevent re-queueing for covers that are already completed to begin with. One mistake I made was ignoring the difficulty of the cover in the index, making it so that you wont be able to do any other difficulty of the same cover if youve done the cover before in a different difficulty. Its fixed now so yeah.

- Once the cover finishes, the script auto advances the queue (also has a "lock" to prevent double firing skipping entries).

- Added a bulk queue option to bulk add all possible covers for the specified manga.

After allat it can be left running in the background while you do whatever you want.

## Stage 7: Visuals

I got this idea when `Real` hadnt updated to the latest roblox version, so I was playing without the script and realised how annoying finding studs were. Then I thought, why dont I just add a visuals feature so players can see where studs are on the canvas without relying on the auto paint feature.

- **Rainbow Studs**: This was the first idea I had. I thought it would be easier to notice the studs if they changed colour, which was why I implemented it. There was already a feature on the game to change the colour of the studs but it used remotes and I dont want to spam it, so I found another way to do it. Like mentioned in stage 1, the studs are pixels so I hooked `CanvasRender.WriteCell` to recolour the pixels in the buffer with an unfilled state each tick and flagged it dirty so the game would upload it itself.

- **Stud Pillars**: I got this idea from the hint mechanic of the game which makes a neon pillar over a remaining stud. So because of that, I decompiled `HintMarker`, copied the pillar structure, then used that to generate over remaining studs (with a rainbow colour feature and a threshold).

- **Compass arrow**: Another idea I had when I wanted to know where to even look for that 1 remaining stud everytime I do a cover. I wanted to start simple with the functioning mechanic before stylising the icon itself, which is why it looks so shit (just an arrow). The sprite is put into a 64x64 EditableImage on a SurfaceGui, then wired its rotation. I had some troubles at first like the image's right axis being in the part's forward direction on the top face, making it perpendicular which caused the player to circle the stud rather than going to it, or when the arrow got stuck pointing to an already painted stud. Anyways its all fixed now so yeah. I need to rework the sprite next with something cool (if you couldn't tell from the logo, I have 0 skill in design).

- **Tracers**: The classic ESP lines which used the executor's Drawing lib. Nothing complicated to note here tbh because I had the location values to use.

Most of these visuals have a threshold equipped to them so that it doesnt freeze the client upon activation.

## Stage 8: Improvements and Optimisations

After getting done with the features, I decided to improve everything, especially the algorithm. I looked at the current code and figured out what I could and should change.

- **Quadratic Grouping**: Because of this issue, big colours costed over a second, so I rewrote it to consider the canvas with grids, then compared it to the old version and had an around 17 times improvement in speed.

- **2-opt**: now scales its pass count with the route size and gives up on huge routes so the fps wont take a toll.

- **Fixing the game itself**: With the way it was made, the game pumps around 1.6 MB worth of canvas data to the GPU every frame with a full rescan of its pending-fill table. I capped both of those by wrapping the renderer's methods with a new one and that seemed to do the trick.

- **Misc Tab**: I lied, there were more features I made like a general walkspeed separate from the painting speed and an anti afk because the game still kicks you out (done through standard getconnections as well as a VirtualUser fallback if the exec doesnt support the first way).

- **Staff Watch + Server Hop**: Scans and watches player joins, checking `GetRoleInGroup(33388672)` against the roles to evade from "important" players to one of the 10 emptiest servers.

## Stage 9: Reworking Movement Algorithm (Lawnmower + Actors)

When I tell you this fuckass algorithm brought me pain and despair I meant every word of it. I, by no means, am a professional in these types of things. The amount of stuff I had to learn was ridiculous because I dont do CS like that + Im shit at maths. After all of the fixes I made, the last visible flaw was the delay between rounds. Every round rescanned the whole canvas (around 90ms for 414k cells) before replanning. The best approach I had (and still have. I am still trying to optimise this as I type this stage of the log out) is to stop rescanning and use another tracking method. I associate the remaining studs with a row and column density histogram. As I fill the canvas up with cum, the script checks with the server to see if the stud count they have supports the script's prediction, and if not, the script will do the rescan then and fix it.

This essentially spaced dense regions into lawnmower bands that are spaced exactly one brush diameter apart. Every fragment is scored by covered cells/s and the whole plan is done up front so that the execution would never need to pause to think. Blatant mode has the same logic just with TPs added into the mix.

This is still subject to change. I am still not as happy as I want to be with the current algorithm. I will push further changes in later versions so yeah.

Future me here. Yes I still havent uploaded the script. Yes I am still improving the algorithm. Fuck you. So I watched it run a few times and there were some issues with efficiency. 1. It would leave an area half finished before going somewhere else. 2. It would go for studs further away first before coming back to closer studs when it wouldve been better if it were done in reverse. 3. Colours with a lot of studs in rows were done so bad omg. The guy went zig zag instead of like finishing each row before moving onto the next.

Along with the grids, I have also decided to use rectangles. Yes. So basically, I group them up in rectangles and then score the route based on if they complete the rectangle before moving on (basically acts as a priority). Thats basically it tbh it doesnt sound too complicated. This fixed most of the issues. The other stuff needed their own fixes but yeah I still have actors to talk about so ill keep it short for this stage.

So after I felt like I did everything I could, I went to `Real`'s docs and checked through all the functions it provides and saw `Actors`. Bro when I tell you the amount of cum that just leaked out from the thought of scaling the routes parallely (if thats a word). Anyways, I rewrote the planner and made it run on Actors. If the exec doesnt support it, it just defaults back to the previous model. The Actor then ships the finished plan back through comm channels while the main thread just walks. I actually faced some issues with Actors because its my first time using it. `require()` inside an Actor returns a completely separate module instance (fuck you). The 2nd issue was that buffers cant cross `run_on_actor` varargs at all so I had to ship buffers as strings from main to actor thread (via `buffer.tostring` and `buffer.fromstring`) and ship plain cell lists from the reverse.

Anyways, im still gonna be improving this but yeah its just a skill issue on my end. I have a lot I could improve upon if I just knew how.

## Stage 10: Reflection

I think its done pretty well so far so yeah. The reason why I am making this log is so that people can have the opportunity to learn themselves and see what kinda struggles were imposed on me during this. It is also here for people who want to modify the code for themselves (so that they get a better understanding).

Some ideas that I want to implement later are, diagonal bands, smarter sprinkle scoring, and a webhook integration for all the bums out there.

---

*Built for fun, documented so the next person doesn't have to do
everything from scratch.*
