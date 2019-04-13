% Using CIS (Continuous Interleaved Sampling) strategy of cochlear implant 
% to process the audio YannyLaurel.wav

% ElectrodesInfo.txt, each row stands for an electrode, frequency range

clear
FileName_Signal = 'yannylaurel.wav';
[OriginalSignal,fs] = audioread(FileName_Signal);
OriginalSignal = OriginalSignal';
ElectrodesInfo = dlmread('ElectrodesInfo.txt');
pps = 1000; % pulses per second
nsample_1 = length(OriginalSignal);
nsample_2 = fix(fs/pps);

%% ten electrodes
% sinewave as carrier
t = (0:nsample_1-1)/fs;
Sinwave = zeros(10,length(t));
for i = 1:10
    n = 2*i-1;
    fc = (ElectrodesInfo(n,5)+ElectrodesInfo(n+1,6))/2;
    Sinwave(i,:) = sin(2*pi*fc*t+(i-1)*2*pi/10);% different onset phase
end

% narrow-band as carrier
BroadBNoise = rand(1,nsample_1);
NB_noise = zeros(10,nsample_1);
for i = 1:10
    n = 2*i-1;
    b = fir1(512,[ElectrodesInfo(n,5)/(fs/2) , ElectrodesInfo(n+1,6)/(fs/2)], hamming(512+1));
    nb_temp = filter(b,1,BroadBNoise);
    NB_noise(i,:) = nb_temp(end-nsample_1+1:end);
end

CI_Sin = zeros(1,nsample_1);
CI_NBNoise = zeros(1,nsample_1);
energy = zeros(10,fix(length(OriginalSignal)/nsample_2)+1); 
for i = 1:10
    n = 2*i-1;
    b = fir1(512,[ElectrodesInfo(n,5)/(fs/2) , ElectrodesInfo(n+1,6)/(fs/2)], hamming(512+1));
    Signal_SubBand = filter(b,1,OriginalSignal);
    Envelope_SubBand = abs(hilbert(Signal_SubBand));
    CI_Sin = CI_Sin + Envelope_SubBand.*Sinwave(i,:);
    CI_NBNoise = CI_NBNoise + Envelope_SubBand.*NB_noise(i,:);
    energy(i,:) = Envelope_SubBand(1:nsample_2:end);
end

scale = 1.4;
FileName_CI_Sin = [FileName_Signal(1:end-4),'_Sin(CIS)_10','.mp4'];
FileName_CI_NBNoise = [FileName_Signal(1:end-4),'_NBNoise(CIS)_10','.mp4'];

audiowrite(FileName_CI_Sin,CI_Sin/(scale*max(abs(CI_Sin))),fs);
audiowrite(FileName_CI_NBNoise,CI_NBNoise/(scale*max(abs(CI_NBNoise))),fs);


%% twenty electrodes
% sinewave as carrier
t = (0:nsample_1-1)/fs;
Sinwave = zeros(20,length(t));
for i = 1:20
    n = i;
    fc = (ElectrodesInfo(n,5)+ElectrodesInfo(n,6))/2;
    Sinwave(i,:) = sin(2*pi*fc*t+(i-1)*2*pi/10);% different onset phase
end

% narrow-band as carrier
BroadBNoise = rand(1,nsample_1);
NB_noise = zeros(20,nsample_1);
for i = 1:20
    n = i;
    b = fir1(512,[ElectrodesInfo(n,5)/(fs/2) , ElectrodesInfo(n,6)/(fs/2)], hamming(512+1));
    nb_temp = filter(b,1,BroadBNoise);
    NB_noise(i,:) = nb_temp(end-nsample_1+1:end);
end

CI_Sin = zeros(1,nsample_1);
CI_NBNoise = zeros(1,nsample_1);
energy = zeros(20,fix(length(OriginalSignal)/nsample_2)+1); 
for i = 1:20
    n = i;
    b = fir1(512,[ElectrodesInfo(n,5)/(fs/2) , ElectrodesInfo(n,6)/(fs/2)], hamming(512+1));
    Signal_SubBand = filter(b,1,OriginalSignal);
    Envelope_SubBand = abs(hilbert(Signal_SubBand));
    CI_Sin = CI_Sin + Envelope_SubBand.*Sinwave(i,:);
    CI_NBNoise = CI_NBNoise + Envelope_SubBand.*NB_noise(i,:);
    energy(i,:) = Envelope_SubBand(1:nsample_2:end);
end

scale = 1.4;
FileName_CI_Sin = [FileName_Signal(1:end-4),'_Sin(CIS)_20','.mp4'];
FileName_CI_NBNoise = [FileName_Signal(1:end-4),'_NBNoise(CIS)_20','.mp4'];

audiowrite(FileName_CI_Sin,CI_Sin/(scale*max(abs(CI_Sin))),fs);
audiowrite(FileName_CI_NBNoise,CI_NBNoise/(scale*max(abs(CI_NBNoise))),fs);

