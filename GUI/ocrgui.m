function varargout = ocrgui(varargin)
% OCRGUI MATLAB code for ocrgui.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ocrgui_OpeningFcn, ...
                   'gui_OutputFcn',  @ocrgui_OutputFcn, ...
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
end



% --- Executes just before ocrgui is made visible.
function ocrgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ocrgui (see VARARGIN)

% Choose default command line output for ocrgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes ocrgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = ocrgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    handles.output=hObject;
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path] = uigetfile('*.jpg','Select any image');
chosenfile = [path file];
handles.inputimage = imread(chosenfile);
I=handles.inputimage;
fontSize = 14;	% Used to control size of "blob number" labels put atop the image.
Igray=rgb2gray(I);
Ibw=im2bw(Igray,graythresh(Igray));
Iedge=edge(uint8(Ibw));
se=strel('square',2);
Iedge2=imdilate(Iedge,se);
Ifill=imfill(Iedge2,'holes');
[Ilabel, numblob]=bwlabel(Ifill);
Iprops=regionprops(Ilabel);
Ibox=[Iprops.BoundingBox];
Ibox=reshape(Ibox,[4 numblob]);
axes(handles.axes1);
imshow(I)
hold on
for cnt=1:numblob
rectangle('position',Ibox(:,cnt),'edgecolor','r');
blobCentroid = Iprops(cnt).Centroid;		% Get centroid.
text(blobCentroid(1), blobCentroid(2), num2str(cnt),'Color',[1 0 0],'FontSize', fontSize, 'FontWeight', 'Bold');
end
hold off;
handles.iprops=Iprops;
guidata(hObject,handles)
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
     handles.output=hObject;
     x = inputdlg('Enter space-separated blob numbers:',...
             'Blob Numbers', [1 50]);
data = str2num(x{:});
handles.blobnumx=data;
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AlphabetImages={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
blobarrayinput=handles.blobnumx;
blobarraysize=size(handles.blobnumx);
tempsize=blobarraysize(2);
answermatrix=zeros(1,tempsize);
for blobcnt=1:tempsize
    
blobnumb = blobarrayinput(blobcnt);
Iprops=handles.iprops;
I=handles.inputimage;
thisBlobsBoundingBox = Iprops(blobnumb).BoundingBox;
cropImage = imcrop(I, thisBlobsBoundingBox);
axes(handles.axes2);
imshow(cropImage)

[processImage, newmap] = imresize(cropImage, [7 5]);
% imshow(processImage)
processImage=imsharpen(processImage);
% imshow(processImage)
Ifinx1=rgb2gray(processImage);

axes(handles.axes3);
imshow(Ifinx1)

Ifinx1=double(Ifinx1);
Ifinx2=(Ifinx1/255);
Ifinx2=Ifinx2';
Ifinx3=reshape(Ifinx2,35,1);
for k=1:35
Ifinx3(k,1)=0.5+(0.5-Ifinx3(k,1));
end

OCRalpha = Ifinx3;

axes(handles.axes4);
plotchar(OCRalpha);
netn=handles.loadnet;
%Remove the semi-colon to show the plot inside
A2 = sim(netn,OCRalpha);
A2 = compet(A2);
%Plotting them below
answer = find(compet(A2) == 1);
answermatrix(1,blobcnt)=(AlphabetImages{1,answer});
end
% plotchar(alphabet(:,answer));
finale=char(answermatrix);
set(handles.text6, 'String', finale);
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
     handles.output=hObject;
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenet pathnet] = uigetfile('*.mat','Input a Neural Network MAT File');
chosennetfile = [pathnet filenet];
load(chosennetfile);
netn=fintrain1;
handles.loadnet=netn;
guidata(hObject,handles)
end


function edit1_Callback(hObject, eventdata, handles)
    handles.output=hObject;
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
handles.blobnum=str2double(get(hObject,'String')); % returns contents of edit1 as a double
guidata(hObject,handles)
end

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
end
