% Get the hour, minute, and second of a given time stamp.
function [hour, min, sec] = get_hour_min_sec(time_stamp)
    pos_colon = find(time_stamp == ':');
    hour = str2double(time_stamp(1:pos_colon(1) - 1));
    min = str2double(time_stamp(pos_colon(1) + 1:pos_colon(1) + 2));
    sec = str2double(time_stamp(pos_colon(2) + 1:pos_colon(2) + 2));
end

