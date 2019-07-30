function varargout = graph_gui(varargin)
% GRAPH_GUI MATLAB code for graph_gui.fig
%      GRAPH_GUI, by itself, creates a new GRAPH_GUI or raises the existing
%      singleton*.
%
%      H = GRAPH_GUI returns the handle to a new GRAPH_GUI or the handle to
%      the existing singleton*.
%
%      GRAPH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAPH_GUI.M with the given input arguments.
%
%      GRAPH_GUI('Property','Value',...) creates a new GRAPH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before graph_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to graph_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help graph_gui

% Last Modified by GUIDE v2.5 18-Jul-2019 11:14:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @graph_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @graph_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before graph_gui is made visible.
function graph_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to graph_gui (see VARARGIN)

char_length = size(handles.popupmenu.String, 2);
default_file = handles.popupmenu.String(1, 1:char_length);

% Load the default file selected by the pop-up menu
data = load_data(default_file);
set_global_raw_data(data)

% Set global variables
time_elapsed = str2double(data{1, 3});
set_global_time_elapsed(time_elapsed)
wind_speed_data = str2double(data{1, 13});
set_global_wind_speed_data(wind_speed_data)
timestamp = data{1, 2};
set_global_timestamp(timestamp)

% For table
set(handles.table, 'data', [])

% Plot
t = get_global_time_elapsed;
w = get_global_wind_speed_data;
plot(t, w)
last = length(t);
xlim([t(1) 0.1 * (t(last) - t(1))])

% For the sliding mechanism
set_global_prev_slider_value(handles.slider.Value)

dcm_obj = datacursormode(handles.figure1);
set(dcm_obj, 'UpdateFcn', @myupdatefcn)

% Choose default command line output for graph_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes graph_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = graph_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
t = get_global_time_elapsed;
last = length(t);
prev_slider_value = get_global_prev_slider_value;

current_value = hObject.Value;
set(hObject, 'Value', round(current_value, 3))

if ~hObject.Value == 1
    xlim([t(1) 0.1 * (t(last) - t(1))])
    set_global_prev_slider_value(hObject.Value)
elseif hObject.Value == 1
    xlim([0.9 * (t(last) - t(1)) t(last)])
    set_global_prev_slider_value(hObject.Value)
else
    x_bounds = xlim;
    x_lower_bound = x_bounds(1);
    x_higher_bound = x_bounds(2);
    
    %axis_shift = 0.9 * abs(hObject.Value - prev_slider_value) * t(last);
    
    if (hObject.Value < prev_slider_value)
        axis_shift = 0.9 * abs(hObject.Value - prev_slider_value) * t(last);
        xlim([x_lower_bound - axis_shift x_higher_bound - axis_shift])
        set_global_prev_slider_value(hObject.Value)
    elseif (hObject.Value > prev_slider_value)
        axis_shift = 0.9 * abs(hObject.Value - prev_slider_value) * (t(last) - t(1));
        xlim([x_lower_bound + axis_shift x_higher_bound + axis_shift])
        set_global_prev_slider_value(hObject.Value)
    end
end


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
cla reset;


% --- Executes on selection change in popupmenu.
function popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject, 'Value');

char_length = size(hObject.String, 2);
file = handles.popupmenu.String(val, 1:char_length);

% Load data selected from the pop-up menu
data = load_data(file);
set_global_raw_data(data)

% Set global variables
time_elapsed = str2double(data{1, 3});
set_global_time_elapsed(time_elapsed)
wind_speed_data = str2double(data{1, 13});
set_global_wind_speed_data(wind_speed_data)
timestamp = data{1, 2};
set_global_timestamp(timestamp)

% Plot
t = get_global_time_elapsed;
w = get_global_wind_speed_data;
plot(t, w)
last = length(t);
xlim([t(1) 0.1 * (t(last) - t(1))])

% For the sliding mechanism
handles.slider.Value = 0;
set_global_prev_slider_value(handles.slider.Value)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu


% --- Executes during object creation, after setting all properties.
function popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% List all files with the extension .tsv
get_tsv_files = dir('*.tsv');
files_displayed = char();
for i = 1:size(get_tsv_files, 1)
    if i == 1
        files_displayed = get_tsv_files(i).name;
    else
        files_displayed = char(files_displayed, get_tsv_files(i).name);
    end
end
set(hObject, 'string', files_displayed)


% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process.
function process_Callback(hObject, eventdata, handles)
% hObject    handle to process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

table_data = get(handles.table, 'data'); 
interval = table_data(:, 5);

% Each row contains the start and end time for each wind speed listed in the wind
% speed category
rows = size(table_data, 1);
time_periods = string(zeros(size(table_data, 1), 2));

% Raw data from file
data = get_global_raw_data;
all_timestamp = cell2mat(data{1, 2});

for i = 1:rows
    time_periods(i, 1) = string(all_timestamp(table_data(i, 3), :));
    time_periods(i, 2) = string(all_timestamp(table_data(i, 4), :));
end
               % ["17:23:00", "17:24:00"; ... 
               % "17:26:15", "17:27:15"; ...
               % "17:29:20", "17:30:25"; ...
               % "17:33:05", "17:34:13"; ...
               % "17:36:30", "17:37:31"; ...
               % "17:39:40", "17:40:41"; ...
               % "17:42:35", "17:43:38"; ...
               % "17:46:39", "17:47:42"; ... 
               % "17:49:21", "17:50:25"; ...
               % "17:59:05", "18:00:05"];

str = get(handles.uibuttongroup2.SelectedObject, 'String');
if strcmp(str, 'Rotation Test')
    process_data(data, interval, time_periods, 'angle')
elseif strcmp(str, 'Wind Tunnel Test')
    process_data(data, interval, time_periods, 'wind')
else
    process_data(data, interval, time_periods, '')
end


% --- Executes on button press in create_interval.
function create_interval_Callback(hObject, eventdata, handles)
% hObject    handle to create_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
d = datacursormode(handles.figure1);
vals = getCursorInfo(d);
if size(vals, 2) <= 1
    size(vals, 2)
    disp('Need more points!')
    return
elseif size(vals, 2) >= 3
    disp('Too many points!')
    return
else
    if isnan(str2double(get(handles.interval_name, 'String')))
        disp('Fix your interval name')
        return
    end
    data = get(handles.table, 'data');
    total_size = size(data, 1) + 1;
    update_data = zeros(total_size, 5); 
    update_data(1:size(data, 1), :) = data(1:size(data, 1), :); 
    if vals(1).Position(1) > vals(2).Position(1)
        update_data(total_size, :) = [vals(2).Position(1), vals(1).Position(1), vals(2).DataIndex, vals(1).DataIndex, str2double(get(handles.interval_name, 'String'))];
    else
        update_data(total_size, :) = [vals(1).Position(1), vals(2).Position(1), vals(1).DataIndex, vals(2).DataIndex, str2double(get(handles.interval_name, 'String'))];
    end
    set(handles.table, 'data', update_data)
    d.removeAllDataCursors()
end


function interval_name_Callback(hObject, eventdata, handles)
% hObject    handle to interval_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of interval_name as text
%        str2double(get(hObject,'String')) returns contents of interval_name as a double


% --- Executes during object creation, after setting all properties.
function interval_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delete_interval.
function delete_interval_Callback(hObject, eventdata, handles)
% hObject    handle to delete_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rows_to_remove = get_global_unique_rows;
all_rows = 1:size(handles.table.Data, 1);
keep_rows = setdiff(all_rows, rows_to_remove);
data = get(handles.table, 'data');
set(handles.table, 'data', data(keep_rows, :))


% --- Executes when selected cell(s) is changed in table.
function table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
unique_rows = unique(eventdata.Indices(:, 1));
set_global_unique_rows(unique_rows)


% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function txt = myupdatefcn(empt, event_obj)
% Customizes text of data tips
timestamp = get_global_timestamp;
pos = get(event_obj, 'Position');
index = get(event_obj, 'DataIndex');
[hour, min, sec] = get_hour_min_sec(char(timestamp(index)));
disp('')
txt = {['Time Elapsed: ', num2str(pos(1))], ...
       ['Velocity: ', num2str(pos(2))], ...
	   ['Hour: ', num2str(hour)], ...
       ['Minute: ', num2str(min)], ...
       ['Second: ', num2str(sec)] ...
      };
   
      
function data = load_data(filename)
% Load the files here
fid = fopen(filename);
data = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1);
fclose(fid);


% --- Global variable functions are defined here.
function set_global_time_elapsed(x)
global time_elapsed
time_elapsed = x;


function r = get_global_time_elapsed
global time_elapsed
r = time_elapsed;


function set_global_timestamp(x)
global timestamp
timestamp = x;


function r = get_global_timestamp
global timestamp
r = timestamp;

function set_global_raw_data(x)
global raw_data
raw_data = x;


function r = get_global_raw_data
global raw_data
r = raw_data;


function set_global_wind_speed_data(x)
global wind_speed_data
wind_speed_data = x;


function r = get_global_wind_speed_data
global wind_speed_data
r = wind_speed_data;


function set_global_prev_slider_value(x)
global prev_slider_value
prev_slider_value = x;


function r = get_global_prev_slider_value
global prev_slider_value
r = prev_slider_value;


function set_global_unique_rows(x)
global unique_rows
unique_rows = x;


function r = get_global_unique_rows
global unique_rows
r = unique_rows;
