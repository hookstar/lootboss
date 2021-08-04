--Copyright © 2018, KTPIRI
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of lootBoss nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL KTPIRI BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'lootBoss'
_addon.author = 'KTPIRI'
_addon.version = '1.0.1'
_addon.commands = {'lootboss','lb'}

--get the file path and launch the bot
file_path = debug.getinfo(1, 'S')
file_path = string.gsub(file_path.source, 'lootboss.lua', '')
file_path = file_path:sub(2)
windower.execute(file_path .. 'lootbot.bat')

--requires
res             = require('resources')
packets         = require('packets')
strings         = require('strings')
local files     = require('files')
local wishList  = require('data.wishList')
local bigKills  = require('data.bigKills')

--globals
dropMessage     = {}
treasurePool    = {}
playerName      = {}
activeEncounter = false
debugMode       = false
items           = res.items

--force scrubs the pool data on zone
windower.register_event('zone change', function(new_id, old_id)
    if new_id then
        scrub_pool()
        activeEncounter = false
        debugMode = false
    end
end);

--catch the action message for big kills only
windower.register_event('action message', function(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
    if message_id == 6 or message_id == 20 then
        if bigKills:contains(target_id) or debugMode == true then
            mobName = windower.ffxi.get_mob_name(target_id)
            encounterEnd = os.time()
            encounter = os.difftime(encounterEnd, encounterStart)
            seconds_to_clock()
            activeEncounter = false
            screenshot()
        end
    end
end);

--handle incoming packets
windower.register_event('incoming chunk', function(id, data)
--handle packets to time the enncounter
    if id == 0x00E then
        local engaged = packets.parse('incoming', data)
        if bigKills:contains(engaged.NPC) or debugMode == true then
            if engaged.Status == 01 then
                encounter_time()
            end
        end
    end

--handle packets to catch treasure pool items and manage tables based on wishlist
    if id == 0x0D2 then
        local treasure = packets.parse('incoming', data)
        local itemID = treasure.Item
        local itemIndex = treasure.Index
        if wishList:contains(itemID) or debugMode == true then
            check_data(itemIndex)
            table.insert(treasurePool, {Index=treasure.Index, ID=items[itemID].en})
        end
    end

--handle packets to catch the drop data as a player gets it
    if id == 0x0D3 then
        local player = packets.parse('incoming', data)
        --only one drop at a time here
        if player.Drop == 01 then
            playerName = {Index=player.Index, Winner=player['Highest Lotter Name']}
            stack_data()
            scrub_winner()
        elseif player.Drop == 02 then
            playerName = {Index=player.Index, Winner=player['Highest Lotter Name']}
            for index, data in ipairs(treasurePool) do
                for key, value in pairs(data) do
                    if value == playerName.Index then
                        table.remove(treasurePool, index)
                        windower.add_to_chat(7, 'lootBoss: floored item removed!')
                        scrub_winner()
                    end
                end
            end
        end
    end
end);

--take screenshot and copy the name for later
function screenshot()
    tmp = os.date("*t")
    screenshotName = string.format('img_%04d%02d%02d_%02d%02d%02d', tmp.year, tmp.month, tmp.day, tmp.hour, tmp.min, tmp.sec)
    windower.send_command("screenshot png hide")
    coroutine.schedule(send_screenshot, 1)
end;

--send the screenshot name to file
function send_screenshot()
    local exists = files.exists('killcam.txt')
    if exists ~= false then
        f=io.open(file_path .. "killcam.txt","a")
        f:write(encounter .. " " .. mobName .. " " .. screenshotName .. ".png\n")
        f:close()
    else
        f = files.new('killcam.txt')
        f:write(encounter .. " " .. mobName .. " " .. screenshotName .. ".png\n")
    end
end;

--check for duplicate index in treasure pool and remove
function check_data(duplicate)
    for index, data in ipairs(treasurePool) do
        for key, value in pairs(data) do
            if value == duplicate then
                table.remove(treasurePool, index)
                windower.add_to_chat(7, 'lootBoss: duplicate index scrubbed!')
            end
        end
    end
end;

--match ID and Winner. Scrubs the Pool data of items removed from treasure list
function stack_data()
    for index, data in ipairs(treasurePool) do
        for key, value in pairs(data) do
            if value == playerName.Index then
                local name = ('[' ..playerName.Winner.. ']')
                local length = 16 - (string.len(name))
                local whiteSpace = string.rep(' ', length)
                dropMessage = (name .. whiteSpace .. '>> \t ' ..treasurePool[index].ID.. '!')
                send_winner()
                table.remove(treasurePool, index)
            end
        end
    end
end;

--send stacked drop message to file
function send_winner()
    local exists = files.exists('dropreport.txt')
    if exists ~= false then 
        f=io.open(file_path .. "dropreport.txt","a")
        f:write(dropMessage .. "\n")
        f:close()
    else
        f = files.new('dropreport.txt')
        f:write(dropMessage .. "\n")
    end
end;

--trigger for encounter time
function encounter_time()
    if activeEncounter == false then
        activeEncounter = true
        windower.add_to_chat(7, 'lootBoss: ****Encounter Started!****')
        encounterStart = os.time()
    end
    if activeEncounter == true then end
end;

--sets encounter time to format h:mm:ss
function seconds_to_clock()
    hour = string.format("%d", math.floor(encounter/3600));
    mins = string.format("%02d", math.floor(encounter/60 - (hour*60)));
    secs = string.format("%02d", math.floor(encounter - hour*3600 - mins *60));
    encounter = hour..":"..mins..":"..secs
end

--force scrub Winner
function scrub_winner()
    playerName = {}
end;

--force scrub Pool
function scrub_pool()
    treasurePool = {}
end;

--call for testing and to see Pool data
function show_table()
    for index, data in ipairs(treasurePool) do
        for key, value in pairs(data) do
            print('\t', key, value)
        end
    end
end;

--commands for testing
windower.register_event('addon command', function(command)
    if command == 'scrub' then --forces the loot out of the pool. Shouldnt need this unless something is really wrong.
        scrub_pool()
        scrub_winner()
    elseif command == 'debug' then --skips the list check and sends everything to Discord. Resets on zone.
        if debugMode == false then
            debugMode = true
            windower.add_to_chat(7, 'lootBoss: debugMode is now On')
        elseif debugMode == true then
            debugMode = false
            windower.add_to_chat(7, 'lootBoss: debugMode is now Off')
        end
    end
end);
