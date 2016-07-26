function[ ] = plotAdjVideo(fld, strs, opts, mygrid )
% Make a video through time of mapped field
% Inputs: 
%
%       fld : 3d gcmfaces fld, 3rd dim assumed to be in time
%       strs: data type with fields: 
%           xlbl : x axis label
%           time : unit of time, appended onto xlbl as t-i (time) 
%           clbl : colorbar label 
%           vidName : name of video object
%       opts: data type with fields: 
%           logFld : plot log of field (default 0)
%           caxLim: colorbar scale
%           saveVideo: default = 0
%           figType: long or wide(default)
% -------------------------------------------------------------------------


% Sift through options
if ~isa(fld,'gcmfaces'), convert2gcmfaces(fld); end

if nargin < 2
    xlbl='';
    time='';
    clbl='';
    vidName = '';
else
    xlbl = strs.xlbl;
    time = strs.time; 
    clbl = strs.clbl;
    vidName = strs.vidName;
end

if nargin < 3
    logFld = 1;
    caxLim = 0;
    saveVideo = 0; 
    mmapOpt = 5;
    figType = 'wide';
else
    logFld = opts.logFld;
    caxLim = opts.caxLim;
    saveVideo = opts.saveVideo;
    mmapOpt = opts.mmapOpt;
    figType = opts.figType; 
end

if nargin < 4
    establish_mygrid;
end

% Prepare ranges for logarithmic plotting
if logFld
    [fld] = calcLogField(fld,mygrid);
end;
    
% Prep video object
if saveVideo
    vidObj = VideoWriter(vidName); 
    set(vidObj,'FrameRate',2)
    open(vidObj);
end

% Open up a figure
if ~strcmp(figType,'long')
    figureW;
else
    figureL;
end

% Prepare ranges
vv=.25:.25:1;
colscale = [10^-3*vv 10^-2*vv 10^-1*vv 1*vv];
ctick = [-colscale(end:-1:1), 0 colscale];
Ntick = length(ctick); 

if Ntick==33
    colbarticks = [-1:8/Ntick:-8/Ntick 0 9/Ntick:8/Ntick:1];
    colbarlbl = [-1 -.1 -.01 -.001 0 .001 .01 .1 1];
else
    colbarticks = [-1:8/Ntick:-8/Ntick, 0, 8/Ntick:8/Ntick:1];
    colbarlbl = [-1, -0.1, -0.01, 0 , 0.01, 0.1, 1];%*10^-caxLim;
end
fld=convert2gcmfaces(fld)*10^caxLim;
binFld = fld;
for i = 1:Ntick
    if i == 1
        bin = fld < ctick(i);
        binFld(bin) = ctick(i);
    elseif i == Ntick
        bin = fld >= ctick(i);
        binFld(bin) = ctick(i);
    else
        bin = fld >= ctick(i-1) & fld < ctick(i);
        binFld(bin) = (ctick(i-1)+ctick(i))*.5;
    end
end
binFld=convert2gcmfaces(binFld);
fld=convert2gcmfaces(fld);

% Do the plotting 
c=gcf();
for n=size(fld.f1,3):-1:1
    
    figure(c),m_map_atl(binFld(:,:,n),mmapOpt)%,{'myCaxis',myCaxis});
    hc=colorbar;
%     keyboard
    set(hc,'ytick',colbarticks,'yticklabel',colbarlbl);
    caxis([-1 1])
    colormap(redblue(Ntick));
    xlabel([xlbl sprintf('t-%d %s',size(fld.f1,3)-n,time)])
    ylabel(hc,sprintf('x 10^{-%d}\n%s',caxLim,clbl),'rotation',0,'position',[4 .2 0]);
    if saveVideo 
        currFrame=getframe(c);
        writeVideo(vidObj,currFrame); 
    end
end

if saveVideo, close(vidObj); end
close;
end
