% INITIALIZING THE ALPHABET ARRAYS
% ================================
[alphabet,targets] = prprob;

% Using the predefined Matlab default function for returning the array of 
% 26 rows and 35 columns of 
% ASCII bits to "alphabet" and identity matrix of 26x26 to targets

[R,Q] = size(alphabet);
[S2,Q] = size(targets);

%Storing sizes of matrices

% Plot alphabet & targets

% specify 1 for first element and so on

% Assigning the alphabets and target as P & T
P=alphabet;
T=targets;

% type return and press Enter

% PRE PROCESS DATA
% =================
% Preprocess data so that its mean is 0 
% and the standard deviation is 1
[alphabet_pp,meanA,stdA] = prestd(alphabet);
% !!!! Matlab sometimes shows this code to be obsolete and tells to use [alphabet_pp,PS] = mapstd
(alphabet);
P = alphabet_pp;
T = targets;

% DEFINING THE NETWORK
% ====================

% The character recognition network will have 35 TANSIG
% neurons in its hidden layer.

S1 = 200;
net = newff(minmax(P),[S1 S2],{'tansig' 'logsig'},'traingd');
net = init(net);
% S2 was already defined earlier as column size of target array
% type return and press Enter
% TRAIN THE NETWORK 
% ==================
% The network is initially trained without noise for a maximum of 5000 
% epochs or until the network sum-squared error falls beneath 0.1.

net.performFcn = 'sse';        % Sum-Squared Error performance function
net.trainParam.goal = 1e-3;     % Sum-squared error goal. Change this to modify SSE goal
net.trainParam.show = 20;      % Frequency of progress displays (in epochs).
net.trainParam.epochs = 5000;  % Maximum number of epochs to train.
net.trainParam.mc = 0.95;      % Momentum constant.
net.trainParam.lr = 0.01;

[net,tr] = train(net,P,T);

O = sim(net,P);
C = full(compet(O));

% compet is a neural transfer function. Transfer functions calculate 
% a layer's output from its net input.
% returns the S-by-Q matrix A with a 1 in each column where the 
% same column of N has its maximum value, and 0 elsewhere.

Error = sse(C-T)/(2*Q)

% Plotting the error

%figure
%imagesc(O)
%figure
%imagesc(C)

% type return and press Enter
%keyboard

% CORRECT WEIGHT AND BiAS INITIALIZATION 
%=======================================

net.IW{1,1} = 1e-3*randn(S1,R);
% Input layer weight

net.b{1}    = 1e-3*randn(S1,1);

net.LW{2,1} = 1e-3*randn(S2,S1); 

% Specify weight from layer 2 to 1

net.b{2}    = 1e-3*randn(S2,1);

[net,tr] = train(net,P,T);

O = sim(net,P);
C = full(compet(O));

Error = sse(C-T)/(2*Q)

%figure
%imagesc(O)
%figure
%imagesc(C)

% Making a copy of the network for future use


% type return and press Enter


% TRAINING THE NETWORK WITH NOISE
% ===============================
% Now we train the network without noise. We modify the target vector so 
% that it includes a mapping of 2 noise free alphabet inputs and 2 noise included alphabet inputs

% Noisy vectors have noise of standard deviation 0.1 and 0.2 added to them

% We have also reduced the number of epochs to 300 and increased the error goalto 0.6 to allow for a 
% higher margin of error so that the network trains faster with noisy elements also

netn = net;
netn.trainParam.goal = 1e-5;
netn.trainParam.epochs = 450;
TN = [targets targets targets targets];

for pass = 1:15
P = [alphabet, alphabet,(alphabet + randn(R,Q)*0.1), (alphabet + randn(R,Q)*0.2)];
PN = trastd(P,meanA,stdA);
%Pre-processing: trastd preprocesses the network training set using 
% the mean and standard deviation that were previously computed by prestd
  % !!!Sometimes Matlab shows warning and tells to use:
  % [PN] = mapstd('apply', P, PS);
[netn,tr] = train(netn,PN,TN);
load('C:\Users\Ghazi\Desktop\Final\Zdata1.mat');
[netn,tr] = train(netn,Zdata1,T);
load('C:\Users\Ghazi\Desktop\Final\Zdata2.mat');
load('C:\Users\Ghazi\Desktop\Final\tdata2.mat');
[netn,tr] = train(netn,Zdata2,tdata2);
load('C:\Users\Ghazi\Desktop\Final\Zdata3.mat');
[netn,tr] = train(netn,Zdata3,T);
end
% We have trained for 10 passes 
% type return and press Enter


% TRAIN THE SECOND NETWORK WITHOUT NOISE
% =======================================
% The second network is now retrained without noise to
% insure that it correctly categorizes non-noizy letters.

P = alphabet_pp;
T = targets;
% Re-initialize arrays back to their original values
netn.trainParam.epochs = 700;
[netn,tr] = train(netn,P,T);
% netn.trainParam.epochs = 900;
% [netn,tr] = train(netn,P,T);

%TIME FOR TESTING OCR
%=================================================

I=imread('C:\Users\Ghazi\Desktop\Final\OCR4.jpg');

%EXTRACTING THE IMAGE DATA
%=========================
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
imshow(I)
hold on;
for cnt=1:numblob
rectangle('position',Ibox(:,cnt),'edgecolor','r');
blobCentroid = Iprops(cnt).Centroid;		% Get centroid.
text(blobCentroid(1), blobCentroid(2)+110, num2str(cnt), 'FontSize', fontSize, 'FontWeight', 'Bold');
end
hold off;
prompt = 'Please enter the blob number ';
blobnumb = input(prompt)
thisBlobsBoundingBox = Iprops(blobnumb).BoundingBox;
cropImage = imcrop(I, thisBlobsBoundingBox);
imshow(cropImage);


[processImage, newmap] = imresize(cropImage, [7 5]);
imshow(processImage)
processImage=imsharpen(processImage);
imshow(processImage)
Ifinx1=rgb2gray(processImage);
Ifinx1=double(Ifinx1);
Ifinx2=(Ifinx1/255);
Ifinx2=Ifinx2';
Ifinx3=reshape(Ifinx2,35,1);
for k=1:35
Ifinx3(k,1)=0.5+(0.5-Ifinx3(k,1));
end

OCRalpha = Ifinx3;
plotchar(OCRalpha);
keyboard
%Remove the semi-colon to show the plot inside
A2 = sim(netn,OCRalpha);
A2 = compet(A2);
%Plotting them below
answer = find(compet(A2) == 1);
plotchar(alphabet(:,answer));
load('C:\Users\Ghazi\Desktop\Final\AlphabetImages.mat');
imshow(AlphabetImages{1,answer});
