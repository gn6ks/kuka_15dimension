function [sys, x0, str, ts] = CamView(t,x,u,flag,ax,st,ms,em)
%CamView S-function that acts as an X-Y scope using MATLAB plotting functions.
%   This M-file is designed to be used in a Simulink S-function block.
%   It draws a line from the previous input point, which is stored using
%   discrete states, and the current point.  It then stores the current
%   point for use in the next invocation.
%
%   See also CamViewS, LORENZS.

%   Copyright 1990-2001 The MathWorks, Inc.
%   $Revision: 1.37 $
%   Andrew Grace 5-30-91.
%   Revised Wes Wang 4-28-93, 8-17-93, 12-15-93
%   Revised Craig Santos 10-28-96

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts] = mdlInitializeSizes(ax,st);
    SetBlockCallbacks(gcbh);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys = mdlUpdate(t,x,u,flag,ax,st,ms,em);

  %%%%%%%%%
  % Start %
  %%%%%%%%%
  case 'Start'
    LocalBlockStartFcn

  %%%%%%%%
  % Stop %
  %%%%%%%%
  case 'Stop'
    LocalBlockStopFcn

  %%%%%%%%%%%%%%
  % NameChange %
  %%%%%%%%%%%%%%
  case 'NameChange'
    LocalBlockNameChangeFcn

  %%%%%%%%%%%%%%%%%%%%%%%%
  % CopyBlock, LoadBlock %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case { 'CopyBlock', 'LoadBlock' }
    LocalBlockLoadCopyFcn

  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock'
    LocalBlockDeleteFcn

  %%%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%%
  case 'DeleteFigure'
    LocalFigureDeleteFcn

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 3, 9 }
    sys = [];

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    if ischar(flag),
      errmsg=sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg=sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

end

% end CamView

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(ax,st)

if length (ax)~=4
  error(['Axes limits must be defined.'])
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0 = [];

str = [];

%
% initialize the array of sample times, note that in earlier
% versions of this scope, a sample time was not one of the input
% arguments, the varargs checks for this and if not present, assigns
% the sample time to -1 (inherited)
%
ts = [st 0];

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,flag,ax,st,ms,em)

%
% always return empty, there are no states...
%
sys = [];

%
% Locate the figure window associated with this block.  If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetCamViewFigure(gcbh);
if ~ishandle(FigHandle),
   return
end

%figure(FigHandle);
n = length(u) / 2;
p = reshape(u,2,n);
%
% Get UserData of the figure.
%
ud = get(FigHandle,'UserData');
set(ud.CamAxes, ...
    'Xlim', ax(1:2),...
    'Ylim', ax(3:4),...
    'NextPlot','add',...
    'CameraUpVector', [0 -1 0],...
    'YDir', 'reverse');
%'XAxisLocation','bottom',...
%    'YAxisLocation','left');
%axis ij;
%axis equal;
%if isempty(ud.CamPlot),
%    set(FigHandle,'NextPlot','add');
%    ud.CamPlot = zeros(1,n)
%    for i=1:n
%        get(ud.CamAxes);
%        ud.CamPlot(i) = plot(p(1,i),p(2,i),...
%        '.','MarkerSize',15,'EraseMode','background')
%    end
%else
    for i=1:n
        x = p(1,i);
        y = p(2,i);
        set(ud.CamPlot(i),'XData',x,'YData',y,...
            'MarkerSize',ms,'EraseMode',em,'Visible','on');
    end
%end

% plot the input lines
%set(ud.XYLine,...
 %   'Xdata',x_data,...
 %   'Ydata',y_data,...
 %   'LineStyle','-');
set(ud.CamTitle,'String','Camera View');
set(FigHandle,'Color',get(FigHandle,'Color'));

%
% update the X/Y stored data points
%
set(FigHandle,'UserData',ud);
drawnow

% end mdlUpdate

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% XY Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn

%
% get the figure associated with this block, create a figure if it doesn't
% exist
%
FigHandle = GetCamViewFigure(gcbh);
if ~ishandle(FigHandle),
  FigHandle = CreateCamViewFigure;
end
ud=get(FigHandle,'UserData');
for i=1:25
    set(ud.CamPlot(i),'Erasemode','normal');
    set(ud.CamPlot(i),'XData',[],'YData',[]);
    set(ud.CamPlot(i),'XData',0,'YData',0,'Erasemode','none','Visible','off');
end
%ud.CamPlot = [];
%ud = get(FigHandle,'UserData');
%ud.XData = [];
%ud.YData = [];
set(FigHandle,'UserData',ud);

% end LocalBlockStartFcn

%
%=============================================================================
% LocalBlockStopFcn
% At the end of the simulation, set the line's X and Y data to contain
% the complete set of points that were acquire during the simulation.
% Recall that during the simulation, the lines are only small segments from
% the last time step to the current one.
%=============================================================================
%
function LocalBlockStopFcn

FigHandle=GetCamViewFigure(gcbh);
if ishandle(FigHandle),
  %
  % Get UserData of the figure.
  %
 % ud = get(FigHandle,'UserData');
 % set(ud.XYLine,...
 %     'Xdata',ud.XData,...
 %     'Ydata',ud.YData,...
 %     'LineStyle','-');

end

% end LocalBlockStopFcn

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the Graph scope block.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% get the figure associated with this block, if it's valid, change
% the name of the figure
%
FigHandle = GetCamViewFigure(gcbh);
if ishandle(FigHandle),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the XYGraph block's LoadFcn and CopyFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetCamViewFigure(gcbh,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the XY Graph block'DeleteFcn.  Delete the block's figure window,
% if present, upon deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% Get the figure handle associated with the block, if it exists, delete
% the figure.
%
FigHandle=GetCamViewFigure(gcbh);
if ishandle(FigHandle),
  delete(FigHandle);
  SetCamViewFigure(gcbh,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the XY Graph figure window's DeleteFcn.  The figure window is
% being deleted, update the XY Graph block's UserData to reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetCamViewFigure(ud.Block,-1)

% end LocalFigureDeleteFcn

%
%=============================================================================
% GetCamViewFigure
% Retrieves the figure window associated with this S-function XY Graph block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetCamViewFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetCamViewFigure

%
%=============================================================================
% SetCamViewFigure
% Stores the figure window associated with this S-function XY Graph block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetCamViewFigure(block,FigHandle)

if strcmp(get_param(bdroot,'BlockDiagramType'),'model'),
  if strcmp(get_param(block,'BlockType'),'S-Function'),
    block=get_param(block,'Parent');
  end

  set_param(block,'UserData',FigHandle);
%  fprintf('SetCamViewFigure OK: FigHandle=%d\n',FigHandle);
end

% end SetCamViewFigure

%
%=============================================================================
% CreateCamViewFigure
% Creates the figure window associated with this S-function XY Graph block.
%=============================================================================
%
function FigHandle=CreateCamViewFigure

%
% the figure doesn't exist, create one
%
FigHandle = figure('Units',          'pixel',...
                   'Position',       [100 100 400 300],...
                   'Name',           get_param(gcbh,'Name'),...
                   'Tag',            'SIMULINK_CAMVIEW_FIGURE',...
                   'NumberTitle',    'off',...
                   'IntegerHandle',  'off',...
                   'DeleteFcn',      'CamView([],[],[],''DeleteFigure'')');
%                   'Toolbar',        'none',...
%                   'Menubar',        'none',...
%                   'DeleteFcn',      'CamView([],[],[],''DeleteFigure'')');
%
% store the block's handle in the figure's UserData
%
ud.Block=gcbh;

%
% create various objects in the figure
%
ud.CamAxes   = axes;
%ud.CamPlot   = [];  % plot(0,0,'EraseMode','None');
set(ud.CamAxes,...
    'Visible','on',...
    'NextPlot','add',...
    'CameraUpVector', [0 -1 0],...
    'YDir', 'reverse');
ud.CamPlot=zeros(1,25);
for i=1:25
        ud.CamPlot(i) = plot(0,0,...
        '.','Visible','off');
end
%ud.XYXlabel = xlabel('X Axis');
%ud.XYYlabel = ylabel('Y Axis');
ud.CamTitle  = get(ud.CamAxes,'Title');
%ud.XData    = [];
%ud.YData    = [];

%
% Associate the figure with the block, and set the figure's UserData.
%
SetCamViewFigure(gcbh,FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateCamViewFigure

%
%=============================================================================
% SetBlockCallbacks
% This sets the callbacks of the block if it is not a reference.
%=============================================================================
%
function SetBlockCallbacks(block)

%
% the actual source of the block is the parent subsystem
%
block=get_param(block,'Parent');

%
% if the block isn't linked, issue a warning, and then set the callbacks
% for the block so that it has the proper operation
%
if strcmp(get_param(block,'LinkStatus'),'none'),
  warnmsg=sprintf(['The CamView scope ''%s'' should be replaced with a ' ...
                   'new version from the Visual Servoing library'],...
                   block);
  warning(warnmsg);

  callbacks={
    'CopyFcn',       'CamView([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'CamView([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'CamView([],[],[],''LoadBlock'')' ;
    'StartFcn',      'CamView([],[],[],''Start'')' ;
    'StopFcn'        'CamView([],[],[],''Stop'')' 
    'NameChangeFcn', 'CamView([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks
