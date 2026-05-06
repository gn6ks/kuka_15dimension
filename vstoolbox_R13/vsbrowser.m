function varargout = vsbrowser(varargin)
% VSBROWSER Application M-file for vsbrowser.fig
%    FIG = VSBROWSER launch vsbrowser GUI.
%    VSBROWSER('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 31-Aug-2002 01:15:15

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(fig,'Name','Visual Servoing Browser v0.1');
    
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    uiload;
    
    handles.c = c;
    handles.T0c = T0c;
    handles.p = p;
    handles.T0o = T0o;
    
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = refresh_pushbutton_Callback(h, eventdata, handles, varargin)

redrawfig(handles);


% --------------------------------------------------------------------
function varargout = load_pushbutton_Callback(h, eventdata, handles, varargin)

uiload;
    
handles.c = c;
handles.T0c = T0c;
handles.p = p;
handles.T0o = T0o;
    
guidata(h, handles);

% --------------------------------------------------------------------
function varargout = save_pushbutton_Callback(h, eventdata, handles, varargin)

c = handles.c;
T0c = handles.T0c;
p = handles.p;
T0o = handles.T0o;

uisave({'c','T0c','p','T0o'});

% --------------------------------------------------------------------
function varargout = edit_dx_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = incx_pushbutton_Callback(h, eventdata, handles, varargin)

dx = eval(get(handles.edit_dx,'string'));
dt = ht('xyz',dx,0,0);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = decx_pushbutton_Callback(h, eventdata, handles, varargin)

dx = eval(get(handles.edit_dx,'string'));
dt = ht('xyz',-dx,0,0);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = edit_dy_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = incy_pushbutton_Callback(h, eventdata, handles, varargin)

dy = eval(get(handles.edit_dy,'string'));
dt = ht('xyz',0,dy,0);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = decy_pushbutton_Callback(h, eventdata, handles, varargin)

dy = eval(get(handles.edit_dy,'string'));
dt = ht('xyz',0,-dy,0);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = edit_dz_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = incz_pushbutton_Callback(h, eventdata, handles, varargin)

dz = eval(get(handles.edit_dz,'string'));
dt = ht('xyz',0,0,dz);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = decz_pushbutton_Callback(h, eventdata, handles, varargin)

dz = eval(get(handles.edit_dz,'string'));
dt = ht('xyz',0,0,-dz);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = edit_wx_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = incwx_pushbutton_Callback(h, eventdata, handles, varargin)

dwx = eval(get(handles.edit_wx,'string'));
dt = ht('xrot',dwx);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = decwx_pushbutton_Callback(h, eventdata, handles, varargin)

dwx = eval(get(handles.edit_wx,'string'));
dt = ht('xrot',-dwx);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = edit_wy_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = incwy_pushbutton_Callback(h, eventdata, handles, varargin)

dwy = eval(get(handles.edit_wy,'string'));
dt = ht('yrot',dwy);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = decwy_pushbutton_Callback(h, eventdata, handles, varargin)

dwy = eval(get(handles.edit_wy,'string'));
dt = ht('yrot',-dwy);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = edit_wz_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = incwz_pushbutton_Callback(h, eventdata, handles, varargin)

dwz = eval(get(handles.edit_wz,'string'));
dt = ht('zrot',dwz);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function varargout = decwz_pushbutton_Callback(h, eventdata, handles, varargin)

dwz = eval(get(handles.edit_wz,'string'));
dt = ht('zrot',-dwz);
frame = get(handles.frame_popupmenu,'Value');
if frame==1     % camera frame
    handles.T0c = handles.T0c * dt;
else            % object frame
    handles.T0c = handles.T0o * dt * inverse(handles.T0o) * handles.T0c;
end
guidata(h,handles);
redrawfig(handles);

% --------------------------------------------------------------------
function redrawfig(handles)

subplot(handles.axes1);
view(handles.c,handles.T0c,handles.p,handles.T0o);
subplot(handles.axes2);
plot(handles.T0c);
hold on;
plot(handles.c,handles.T0c);
plot(handles.T0o);
plot(handles.p,handles.T0o);
hold off;
axis equal;
drawnow;

% --------------------------------------------------------------------
function varargout = frame_popupmenu_Callback(h, eventdata, handles, varargin)

