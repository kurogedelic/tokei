-- tokei
-- view clock
-- E3 - change timezone
-- K2 - sound on/off

-- load the polyperc
engine.name = 'PolyPerc'

-- select tz number may change by  E3
selected_time_zone = 2

-- Table of world time zones
local world_time_zones = {
    { name = "UTC",     offset = 0 },
    { name = "JST/KST", offset = 9 },
    { name = "PST",     offset = -8 },
    { name = "EST",     offset = -5 },
    { name = "CST",     offset = -6 },
    { name = "GMT",     offset = 0 },
    { name = "AEST",    offset = 10 },
    { name = "BST",     offset = 1 },
    { name = "IST",     offset = 5.5 },
    { name = "CET",     offset = 1 },
    { name = "MSK",     offset = 3 },
    { name = "SGT",     offset = 8 },
    { name = "ART",     offset = -3 },
    { name = "AKST",    offset = -9 },
    { name = "HST",     offset = -10 },
    { name = "NZST",    offset = 12 }
}

-- Initialize variables
state = true
intClock = 0
half_seconds = false -- Initialize half_seconds to false


clockView = 0
dayView = 0


-- init synth
function initSynth()
    -- configure the synth --[[ 0_0 ]]--
    engine.release(1)
    engine.pw(0.5)
    engine.cutoff(1000)
end

-- Initialize function
function init()
    initSynth()

    frame()                             -- Call the frame function
    framer = metro.init(frame, 0.5, -1) -- Set up the metro to call the frame function every 30ms
    framer:start()                      -- Start the metro
end

-- Frame function to update the time and date
function frame()
    local clockOffset = world_time_zones[selected_time_zone].offset

    local s, us = _norns.get_time()
    local timestamp = s + clockOffset * 3600 -- Apply the offset to the UNIX timestamp

    -- Calculate seconds from the given UNIX timestamp
    local total_seconds = timestamp
    local current_seconds = total_seconds % 86400

    -- Calculate hours and minutes
    local hours = math.floor(current_seconds / 3600)
    local minutes = math.floor((current_seconds % 3600) / 60)
    local seconds = current_seconds % 60

    -- Format the time as "hh:mm"
    local formatted_time = string.format("%02d:%02d:%02d", hours, minutes, seconds)


    -- Check if seconds is xx:xx:00 or xx:xx:30
    if seconds % 60 == 0 or seconds % 60 == 30 then
        half_seconds = true
    else
        half_seconds = false
    end


    -- Calculate date from the UNIX timestamp
    local unix_epoch = 1970 * 365 * 24 * 60 * 60 -- Calculate the number of seconds from 1970 to the present
    local current_seconds = total_seconds % 86400
    local current_days = math.floor(total_seconds / 86400)

    -- Calculate the year, month, and day from the total days
    local years = 1970
    local months, days = 1, 1

    -- Calculate the year
    while current_days >= 365 do
        if ((years % 4 == 0 and years % 100 ~= 0) or years % 400 == 0) then
            if current_days >= 366 then
                current_days = current_days - 366
                years = years + 1
            else
                break
            end
        else
            current_days = current_days - 365
            years = years + 1
        end
    end

    -- Calculate the days in each month
    local days_in_month = { 31, 28 + ((years % 4 == 0 and years % 100 ~= 0) or years % 400 == 0 and 1 or 0), 31, 30, 31,
        30, 31, 31, 30, 31, 30, 31 }

    -- Calculate the month and day
    for i = 1, 12 do
        if current_days < days_in_month[i] then
            months = i
            days = current_days + 1
            break
        else
            current_days = current_days - days_in_month[i]
        end
    end

    -- Format the date as "yy/mm/dd"
    local formatted_days = string.format("%02d/%02d/%02d", years, months, days)

    -- Set the time and date for display
    clockView = formatted_time
    dayView = formatted_days
    --
    if state == true then
        timeTones()
    end
    redraw() -- Call the redraw function to update the screen
end

function timeTones()
    if half_seconds == true then
        engine.release(0.5)
        engine.hz(440 * 2)
    elseif half_seconds == false then
        engine.release(1)
        engine.hz(440 * 3)
    end
end

-- Redraw function to update the screen
function redraw()
    screen.clear()  -- Clear the screen
    screen.aa(0)    -- Disable anti-aliasing
    screen.level(2) -- Set the screen brightness
    screen.font_face(1)

    -- Display the time-zone
    screen.font_size(8)
    screen.move(0, 26)
    screen.text(world_time_zones[selected_time_zone].name)


    screen.level(10) -- Set the screen brightness


    -- Display the date
    screen.font_size(14)
    screen.move(0, 40)
    screen.text(dayView)

    -- Display the clock
    screen.font_size(24)
    screen.move(0, 60)
    screen.text(clockView)



    -- Display the play state
    screen.font_size(8)
    screen.move(120, 60)
    if state == true then
        screen.text(">")
    elseif state == false then
        screen.text("_")
    end

    -- Print the internal clock (optional)

    screen.update() -- Update the screen
end

function enc(n, d)
    if n == 3 then
        selected_time_zone = math.min(10, math.max(1, selected_time_zone + d))
        frame()
    end
end

function key(n, z)
    if z == 1 then
        if n == 2 then
            if state == true then
                state = false
            elseif state == false then
                state = true
            end
        end
    end
end
