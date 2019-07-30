function [mean_category, std_category] = process_data(data, category, time_periods, label)
    % Check input size
    if (size(category, 1) ~= size(time_periods, 1))
        return;
    else
        length_category = size(category, 1);
    end

    % Categorizing each data type
    time_stamp = cell2mat(data{1, 2});
    wind_speed_data = str2double(data{1, 13});
    
    % Initialize 
    mean_category = zeros(length_category, 1);
    std_category = zeros(length_category, 1);

    % The first column of a row in time_periods corresponds to the start
    % time. The second column of a row in time_periods corresponds to the
    % end time
    time_stamp_length = length(time_stamp);
    end_idx = 1;
    for i = 1:length_category
        start_idx = end_idx;
        flag_start = 0;
        flag_end = 0;
        
        [hour_start, min_start, sec_start] = get_hour_min_sec(char(time_periods(i, 1)));
        [hour_end, min_end, sec_end] = get_hour_min_sec(char(time_periods(i, 2)));
        
        for j = end_idx:time_stamp_length - 1
            [hour_before, min_before, sec_before] = get_hour_min_sec(time_stamp(j, :));
            [hour_after, min_after, sec_after] = get_hour_min_sec(time_stamp(j + 1,:));
            if (hour_start >= hour_before && hour_after >= hour_start && ...
                min_start >= min_before && min_after >= min_start && ...
                sec_start > sec_before && sec_after >= sec_start)
                start_idx = j + 1;
                flag_start = 1;
            elseif (hour_end >= hour_before && hour_after >= hour_end && ...
                    min_end >= min_before && min_after >= min_end && ...
                    sec_end >= sec_before && sec_after >= sec_end)
                end_idx = j;
                flag_end = 1;
            end
            if (flag_start && flag_end)
                break
            end
        end
        time_stamp(start_idx:end_idx, :)
        mean_category(i) = mean(wind_speed_data(start_idx:end_idx));
        std_category(i) = std(wind_speed_data(start_idx:end_idx));
        time_stamp(start_idx:end_idx, :)
    end

    % Plotting
    figure
    turbulence_intensity = std_category ./ mean_category;
    %plot(category, mean_category, category, std_category)
    plot(category, mean_category, '*', category, 10*turbulence_intensity, '*')
    legend('Mean', 'Turbulence')
    %errorbar(category, mean_category, std_category)
    ylabel('Actual wind velocity (m/s)') 
    
    if (strcmp(label, 'angle'))
        xlabel('Tested angle orientation (deg)')
    elseif (strcmp(label, 'wind'))
        xlabel('Tested wind velocity (m/s)')
    end
end

