function [audioOut,audioFs] = vocoderFunc(par,electrodogram)
% scan input parameters adding necessary default values
defaultParNames = {'captFs','nCarriers','elecFreqs','spread','neuralLocsOct','nNeuralLocs','MCLmuA','TmuA','tAvg','audioFs','tPlay','tauEnvMS','nl','resistorVal'};
defaultParValues = {200000,20,[],[],[],100,[],[],.005,48000,[],10,5,2};

for i = 1:length(defaultParNames)
    if ~isfield(par,defaultParNames{i})
        par.(defaultParNames{i}) = defaultParValues{i};
    end
end

%% scale and preprocess electrodogram data
scale2MuA = 1000/par.resistorVal
electrodeAmp = electrodogram
nElec = size(electrodogram,1);
elData = electrodeAmp*scale2MuA
captTs = 1/captFs


%% compute electrode locations in terms of frequency
if isesmpty(par.elecFreqs)
    elecFreqs = logspace(log10(381.5),log10(5046.4),nElec);
else
    if nElec ~= length(par.elecFreqs)
        error('# of electrode frequencys does not match recorded data!')
    else
        elecFreqs = par.elecFreqs;
    end
end
   
%% electric field spread curve
if isempty(par.spread)
    elecPlacement = ones(1,nElec);
    load 'spread.mat'
    spread.fOct = fOct;
    spread.amp = voltage;
else
    elecPlacement = spread.elecPlacement;
    for i = 1:length(spread.curve)
        spread(i).fOct = spread.curve(i).fOct;
        spread(i).amp = spread.curve(i).amp;
    end
end
%% Octave location of neural populations
if isempty(par.neuralLocsOct)
    neuralLocsOct = [log2(linspace(150,850,40)) linspace(log2(870),log2(8000),260)];
else
    neuralLocsOct = par.neuralLocsOct;
end

if isempty(par.nNeuralLocs)
    nNeuralLocs = 300;
else
    nNeuralLocs = par.nNeuralLocs;
end

neuralLocsOct = interp1(1:length(neuralLocsOct),neuralLocsOct,linspace(1,length(neuralLocsOct),nNeuralLocs));

%% tauEnvMS
if isempty(par.tauEnvMS)
    tauEnvMS = 10;
else
    tauEnvMS = par.tauEnvMS;
end

taus = tauEnvMS/1000;
alpha = exp(-1/(taus*captFs));

%% MCL and T Levels in MuA
if isempty(par.MCLmuA)
    MCLmuA = 500*ones(1,nElec)*1.2;
else
    if length(par.MCLmuA == nElec)
        MCLmuA = par.MCLmuA*1.2;
    elseif length(par.MCLmuA == 1)
        MCLmuA = par.MCLmuA*ones(1,nElec)*1.2;
    else
        error('wrong number of MCL levels')
    end
end

if isempty(par.TmuA)
    TmuA = 500*ones(1,nElec);
else
    if length(par.TmuA == nElec)
        TmuA = par.TmuA;
    elseif length(par.TmuA == 1)
        TmuA = par.TmuA*ones(1,nElec);
    else
        error('wrong number of T levels')
    end
end
%% time frame to average neural activity
% If too high: smeared, if too low: low frequencies not reconstructed by
% window

if isempty(par.tAvg)
    tAvg = ceil(.005/captTs)*captTs;
else
    tAvg = ceil(par.tAvg/captTs)*captTs;
end
mAvg = round(tAvg/captTs);
blkSize = mAvg;

%% audio sample frequency of output
if isempty(par.audioFs)
    audioFs = ceil(tAvg*44100)/tAvg;
else
    audioFs = ceil(tAvg*par.audioFs)/tAvg;
end
audioTs = 1/audioFs;
nAvg = round(tAvg/audioTs);
tWin = 2*tAvg;
nFFT = round(tWin/audioTs);

%% length of audio



end

