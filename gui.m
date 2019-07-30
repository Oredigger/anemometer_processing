fid = fopen('anemometer_graph_data_usblocal_0_25_rotation_test_vav.tsv');
data = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1);
fclose(fid);

time_elapsed = str2double(data{1, 3});
wind_speed_data = str2double(data{1, 13});