-- Copyright (c) 2022-2023 Oneline/D.Borovsky
-- All rights reserved
SSRTimer = {};

local timestamp = 0;
local timers = {};

SSRTimer.add_ms = function (f, interval, loop) -- interval in millis
    local timer = {};
    timer.callback = f;
    timer.interval = interval;
    timer.timestamp = getTimeInMillis() + timer.interval;
    timer.loop = loop;
    table.insert(timers, timer);
end

SSRTimer.add_s = function (f, interval, loop) -- interval in seconds
    SSRTimer.add_ms(f, interval * 1000, loop);
end

SSRTimer.add_m = function (f, interval, loop) -- interval in minutes
    SSRTimer.add_ms(f, interval * 60000, loop);
end

if isServer() then
    SSRTimer.loop = function ()
        timestamp = getTimeInMillis();
        for i=#timers, 1, -1 do
            if timestamp > timers[i].timestamp then
                timers[i].callback();
                if timers[i].loop then
                    timers[i].timestamp = getTimeInMillis() + timers[i].interval;
                else
                    table.remove(timers, i);
                end
            end
        end
    end
    Events.EveryOneMinute.Add(SSRTimer.loop);
else
    local index = 1;
    SSRTimer.loop = function ()
        timestamp = getTimeInMillis();
        if timers[index] then
            if timestamp > timers[index].timestamp then
                timers[index].callback();
                if timers[index].loop then
                    timers[index].timestamp = getTimeInMillis() + timers[index].interval;
                else
                    table.remove(timers, index);
                    return;
                end
            end
            index = index + 1;
        else
            index = 1;
        end
    end
    Events.OnTick.Add(SSRTimer.loop);
end