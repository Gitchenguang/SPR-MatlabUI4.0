function varargout = SetMeaFinalAngle(varargin)
% SETMEAFINALANGLE MATLAB code for SetMeaFinalAngle.fig
%      SETMEAFINALANGLE, by itself, creates a new SETMEAFINALANGLE or raises the existing
%      singleton*.
%
%      H = SETMEAFINALANGLE returns the handle to a new SETMEAFINALANGLE or the handle to
%      the existing singleton*.
%
%      SETMEAFINALANGLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETMEAFINALANGLE.M with the given input arguments.
%
%      SETMEAFINALANGLE('Property','Value',...) creates a new SETMEAFINALANGLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SetMeaFinalAngle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SetMeaFinalAngle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SetMeaFinalAngle

% Last Modified by GUIDE v2.5 15-Jan-2016 10:16:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SetMeaFinalAngle_OpeningFcn, ...
                   'gui_OutputFcn',  @SetMeaFinalAngle_OutputFcn, ...
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


% --- Executes just before SetMeaFinalAngle is made visible.
function SetMeaFinalAngle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SetMeaFinalAngle (see VARARGIN)

% Choose default command line output for SetMeaFinalAngle
handles.output = hObject;

mainGuiInput = find(strcmp(varargin, 'SPR_SystemUI'));
PushButton_Handle = varargin{mainGuiInput+1};
% Obtain handles using GUIDATA with the caller's handle 
SPR_SystemUI = guidata(PushButton_Handle);
% Set the edit text to the String of the main GUI's button
set( handles.edit1,'String',get( SPR_SystemUI.PushMeaFinalAngle , 'UserData' ) );

% Choose default command line output for SetMeaInitialAngle
handles.output = hObject;
handles.SPR_SystemUI = SPR_SystemUI;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SetMeaFinalAngle wait for user response (see UIRESUME)
uiwait(handles.figure);


% --- Outputs from this function are returned to the command line.
function varargout = SetMeaFinalAngle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SPR_SystemUI = handles.SPR_SystemUI;
MeaFinalAngle = str2num(get(handles.edit1,'String'));
if ~isnumeric( MeaFinalAngle ) ||( MeaFinalAngle > 90 || MeaFinalAngle < 0)
    msgbox('错误：请输入0-90之间的整数','设置错误','error');
else 
    set( SPR_SystemUI.PushMeaFinalAngle, 'UserData' , MeaFinalAngle );
    uiresume(handles.figure);
end


% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure);


% --- Executes when user attempts to close figure.
function figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(hObject);
