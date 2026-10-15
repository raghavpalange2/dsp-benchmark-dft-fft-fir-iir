%% =====================================================================
%  DSP MINI PROJECT: Comparative Benchmark of DFT, FFT, FIR and IIR
%  Requirements: MATLAB + Signal Processing Toolbox (fir1, butter, freqz,
%  filtfilt, grpdelay). Run the whole file (F5). Results go to /results.
%  =====================================================================
clear; clc; close all; rng(1);              % rng(1) => reproducible noise
outDir = 'results';
if ~exist(outDir,'dir'), mkdir(outDir); end

%% ---------------------------------------------------------------------
%  PART 1: DFT vs FFT  (runtime, RMSE, operation count)
%  Reference ("existing method") = MATLAB built-in fft
%  ---------------------------------------------------------------------
Ns = 2.^(6:12);  nN = numel(Ns);
tDFT = zeros(1,nN); tMyFFT = tDFT; tFFT = tDFT;
eDFT = zeros(1,nN); eMyFFT = tDFT;
fs1 = 1000;
for i = 1:nN
    N = Ns(i); n = (0:N-1).';
    x = sin(2*pi*50*n/fs1) + 0.5*sin(2*pi*120*n/fs1) + 0.1*randn(N,1);
    Xref = fft(x);                                   % reference
    tDFT(i)   = timeit(@() dft_naive(x));
    tMyFFT(i) = timeit(@() myfft(x));
    tFFT(i)   = timeit(@() fft(x));
    eDFT(i)   = sqrt(mean(abs(dft_naive(x) - Xref).^2));
    eMyFFT(i) = sqrt(mean(abs(myfft(x)   - Xref).^2));
end
opsDFT = Ns.^2;                     % complex multiplications, O(N^2)
opsFFT = (Ns/2).*log2(Ns);          % complex multiplications, O(N log N)

T1 = table(Ns', tDFT'*1e3, tMyFFT'*1e3, tFFT'*1e3, eDFT', eMyFFT', ...
           opsDFT', opsFFT', (tDFT./tMyFFT)', ...
  'VariableNames',{'N','DFT_ms','MyFFT_ms','BuiltinFFT_ms','RMSE_DFT', ...
                   'RMSE_MyFFT','Ops_DFT','Ops_FFT','Speedup_DFT_over_MyFFT'});
disp('TABLE 1: DFT vs FFT'); disp(T1);
writetable(T1, fullfile(outDir,'table1_dft_fft.csv'));

figure('Name','Runtime');
loglog(Ns,tDFT,'-o',Ns,tMyFFT,'-s',Ns,tFFT,'-^','LineWidth',1.5); grid on;
xlabel('N (samples)'); ylabel('Runtime (s)');
legend('Naive DFT','Own radix-2 FFT','Built-in fft','Location','northwest');
title('Runtime vs transform length'); saveas(gcf, fullfile(outDir,'fig1_runtime.png'));

figure('Name','Operations');
loglog(Ns,opsDFT,'-o',Ns,opsFFT,'-s','LineWidth',1.5); grid on;
xlabel('N'); ylabel('Complex multiplications');
legend('DFT  N^2','FFT  (N/2)log_2N','Location','northwest');
title('Operation count'); saveas(gcf, fullfile(outDir,'fig2_ops.png'));

%% ---------------------------------------------------------------------
%  PART 2: Frequency resolution (df = fs/N) and zero padding
%  Two tones 100 Hz and 105 Hz, fs = 1000 Hz
%  ---------------------------------------------------------------------
fs = 1000;
mk = @(N) sin(2*pi*100*(0:N-1)'/fs) + sin(2*pi*105*(0:N-1)'/fs);
x128  = mk(128);  x1024 = mk(1024);
X128  = abs(fft(x128));            f128  = (0:127)*fs/128;       % df = 7.81 Hz
X128z = abs(fft(x128,1024));       f1024 = (0:1023)*fs/1024;     % zero-padded
X1024 = abs(fft(x1024));                                          % df = 0.98 Hz
figure('Name','Resolution');
plot(f128(1:32),X128(1:32)/max(X128),'o-', ...
     f1024(1:210),X128z(1:210)/max(X128z),'-', ...
     f1024(1:210),X1024(1:210)/max(X1024),'-','LineWidth',1.3); grid on;
xlim([60 160]); xlabel('Frequency (Hz)'); ylabel('Normalised |X|');
legend('N=128 (df=7.8 Hz)','N=128 zero-padded to 1024','N=1024 (df=0.98 Hz)');
title('Resolution: zero padding interpolates, only more data resolves');
saveas(gcf, fullfile(outDir,'fig3_resolution.png'));

%% ---------------------------------------------------------------------
%  PART 3: Convolution - direct vs FFT-based vs built-in
%  ---------------------------------------------------------------------
Ls = 2.^(8:15);  h = fir1(254, 0.2);          % 255-tap filter
tDir = zeros(size(Ls)); tFFTc = tDir; tBuilt = tDir; eFFTc = tDir;
for i = 1:numel(Ls)
    x = randn(Ls(i),1);
    tDir(i)   = timeit(@() conv_direct(x,h(:)));
    tFFTc(i)  = timeit(@() conv_fft(x,h(:)));
    tBuilt(i) = timeit(@() conv(x,h(:)));
    eFFTc(i)  = sqrt(mean((conv_fft(x,h(:)) - conv(x,h(:))).^2));
end
T2 = table(Ls', tDir'*1e3, tFFTc'*1e3, tBuilt'*1e3, eFFTc', ...
  'VariableNames',{'L','DirectLoop_ms','FFTconv_ms','BuiltinConv_ms','RMSE_FFTconv'});
disp('TABLE 2: Convolution'); disp(T2);
writetable(T2, fullfile(outDir,'table2_convolution.csv'));
figure('Name','Conv');
loglog(Ls,tDir,'-o',Ls,tFFTc,'-s',Ls,tBuilt,'-^','LineWidth',1.5); grid on;
xlabel('Signal length L'); ylabel('Runtime (s)');
legend('Direct loop','FFT-based','Built-in conv','Location','northwest');
title('Convolution runtime (255-tap filter)');
saveas(gcf, fullfile(outDir,'fig4_convolution.png'));

%% ---------------------------------------------------------------------
%  PART 4: FIR vs IIR on identical test signals
%  Signal A: synthetic (50 Hz + 80 Hz wanted; 300 Hz tone + noise unwanted)
%  Signal B: real audio (MATLAB's built-in 'handel' recording) + noise
%  ---------------------------------------------------------------------
% --- Signal A
fsA = 1000; tA = (0:2*fsA-1)'/fsA;
xcA = sin(2*pi*50*tA) + 0.5*sin(2*pi*80*tA);
xnA = xcA + 0.5*sin(2*pi*300*tA) + 0.2*randn(size(tA));
% --- Signal B
S = load('handel'); yB = S.y(1:2^15); fsB = S.Fs;
yB = yB/max(abs(yB));
xcB = yB; xnB = yB + 0.05*randn(size(yB));

TA = eval_filters(xcA, xnA, fsA, 120,  'Synthetic');
TB = eval_filters(xcB, xnB, fsB, 1000, 'Handel audio');
T3 = [TA; TB];
disp('TABLE 3: FIR vs IIR'); disp(T3);
writetable(T3, fullfile(outDir,'table3_fir_iir.csv'));

% --- Frequency responses (synthetic design)
Wn = 120/(fsA/2);
bF = fir1(50,Wn,hamming(51));  [bI,aI] = butter(4,Wn);
[HF,f] = freqz(bF,1,2048,fsA); HI = freqz(bI,aI,2048,fsA);
figure('Name','FreqResp');
subplot(2,1,1);
plot(f,20*log10(abs(HF)),f,20*log10(abs(HI)),'LineWidth',1.4); grid on;
ylim([-100 5]); xlabel('Hz'); ylabel('dB');
legend('FIR (order 50, Hamming)','IIR (Butterworth, order 4)');
title('Magnitude response');
subplot(2,1,2);
[gF,~] = grpdelay(bF,1,2048,fsA); [gI,~] = grpdelay(bI,aI,2048,fsA);
plot(f,gF,f,gI,'LineWidth',1.4); grid on; xlim([0 250]);
xlabel('Hz'); ylabel('samples'); title('Group delay (FIR constant, IIR varies)');
saveas(gcf, fullfile(outDir,'fig5_freq_response.png'));

% --- Filtered output plot
yF = filter(bF,1,xnA); yF = [yF(26:end); zeros(25,1)];   % remove 25-sample delay
yI = filtfilt(bI,aI,xnA);
figure('Name','TimeDomain');
idx = 1:300;
plot(tA(idx),xnA(idx),'Color',[.7 .7 .7]); hold on;
plot(tA(idx),xcA(idx),'k','LineWidth',1.3);
plot(tA(idx),yF(idx),'--','LineWidth',1.2);
plot(tA(idx),yI(idx),':','LineWidth',1.6); grid on;
legend('Noisy','Clean (reference)','FIR output','IIR (zero-phase)');
xlabel('Time (s)'); title('Filtering result (first 0.3 s)');
saveas(gcf, fullfile(outDir,'fig6_time_domain.png'));

%% ---------------------------------------------------------------------
%  PART 5: Accuracy vs computation trade-off (order sweep, synthetic signal)
%  ---------------------------------------------------------------------
firOrd = [10 20 30 50 80 120];  iirOrd = [2 3 4 5 6 8];
rF = zeros(size(firOrd)); tF = rF; opF = rF;
rI = zeros(size(iirOrd)); tI = rI; opI = rI;
skip = 200;
for i = 1:numel(firOrd)
    b = fir1(firOrd(i),Wn,hamming(firOrd(i)+1)); d = firOrd(i)/2;
    y = filter(b,1,xnA); y = y(d+1:end);  r = xcA(1:numel(y));
    rF(i) = sqrt(mean((y(skip:end)-r(skip:end)).^2));
    tF(i) = timeit(@() filter(b,1,xnA));  opF(i) = 2*firOrd(i)+1;
end
for i = 1:numel(iirOrd)
    [b,a] = butter(iirOrd(i),Wn);
    y = filtfilt(b,a,xnA);  % zero-phase: fair comparison with delay-compensated FIR
    rI(i) = sqrt(mean((y(skip:end-skip)-xcA(skip:end-skip)).^2));
    tI(i) = timeit(@() filtfilt(b,a,xnA));  opI(i) = 2*(4*iirOrd(i)+1);
end
T4 = [table(repmat("FIR",numel(firOrd),1),firOrd',rF',tF'*1e3,opF', ...
        'VariableNames',{'Type','Order','RMSE','Runtime_ms','OpsPerSample'}); ...
      table(repmat("IIR",numel(iirOrd),1),iirOrd',rI',tI'*1e3,opI', ...
        'VariableNames',{'Type','Order','RMSE','Runtime_ms','OpsPerSample'})];
disp('TABLE 4: Accuracy vs computation'); disp(T4);
writetable(T4, fullfile(outDir,'table4_tradeoff.csv'));
figure('Name','Tradeoff');
semilogy(opF,rF,'-o',opI,rI,'-s','LineWidth',1.5); grid on;
xlabel('Operations per output sample'); ylabel('RMSE vs clean signal');
legend('FIR (delay-compensated)','IIR (zero-phase, filtfilt)'); title('Accuracy-computation trade-off');
saveas(gcf, fullfile(outDir,'fig7_tradeoff.png'));

disp('Done. Tables (CSV) and figures (PNG) saved in the results folder.');

%% =====================================================================
%  LOCAL FUNCTIONS (must stay at the END of the script)
%  =====================================================================
function X = dft_naive(x)
% Direct DFT from the definition, O(N^2)
    x = x(:); N = numel(x); n = (0:N-1).'; X = zeros(N,1);
    for k = 0:N-1
        X(k+1) = sum(x .* exp(-1j*2*pi*k*n/N));
    end
end

function X = myfft(x)
% Recursive radix-2 decimation-in-time FFT, O(N log N); N must be 2^m
    x = x(:); N = numel(x);
    if N == 1, X = x; return; end
    Xe = myfft(x(1:2:end));  Xo = myfft(x(2:2:end));
    w  = exp(-1j*2*pi*(0:N/2-1).'/N);
    X  = [Xe + w.*Xo; Xe - w.*Xo];
end

function y = conv_direct(x,h)
% Direct-form linear convolution with explicit loops, O(L*M)
    L = numel(x); M = numel(h); y = zeros(L+M-1,1);
    for k = 1:M
        y(k:k+L-1) = y(k:k+L-1) + h(k)*x;
    end
end

function y = conv_fft(x,h)
% Linear convolution via FFT (zero-pad to avoid circular wrap-around)
    Nf = 2^nextpow2(numel(x)+numel(h)-1);
    y  = real(ifft(fft(x,Nf).*fft(h,Nf)));
    y  = y(1:numel(x)+numel(h)-1);
end

function T = eval_filters(xc,xn,fs,fc,label)
% Same protocol for every signal: low-pass at fc, FIR(50, Hamming) vs
% Butterworth IIR(4). RMSE measured against the clean signal.
    Wn = fc/(fs/2);  Nf = 50; d = Nf/2; skip = 200;
    bF = fir1(Nf,Wn,hamming(Nf+1));  [bI,aI] = butter(4,Wn);
    yF  = filter(bF,1,xn);  yF = [yF(d+1:end); zeros(d,1)];   % delay-compensated
    yIc = filter(bI,aI,xn);                                    % causal IIR
    yIz = filtfilt(bI,aI,xn);                                  % zero-phase IIR
    r = @(y) sqrt(mean((y(skip:end-d)-xc(skip:end-d)).^2));
    rt = @(f) timeit(f)*1e3;
    [HF,f] = freqz(bF,1,4096,fs);  HI = freqz(bI,aI,4096,fs);
    st = f >= 1.5*fc;  pb = f <= 0.8*fc;
    attF = max(20*log10(abs(HF(st))));  attI = max(20*log10(abs(HI(st))));
    ripF = max(20*log10(abs(HF(pb))))-min(20*log10(abs(HF(pb))));
    ripI = max(20*log10(abs(HI(pb))))-min(20*log10(abs(HI(pb))));
    Signal = repmat(string(label),3,1);
    Filter = ["FIR-50 Hamming";"IIR Butter-4 (causal)";"IIR Butter-4 (filtfilt)"];
    RMSE = [r(yF); r(yIc); r(yIz)];
    Runtime_ms = [rt(@() filter(bF,1,xn)); rt(@() filter(bI,aI,xn)); ...
                  rt(@() filtfilt(bI,aI,xn))];
    OpsPerSample = [2*Nf+1; 4*4+1; 2*(4*4+1)];
    StopbandMax_dB = [attF; attI; attI];
    PassbandRipple_dB = [ripF; ripI; ripI];
    LinearPhase = ["Yes";"No";"Yes (offline)"];
    T = table(Signal,Filter,RMSE,Runtime_ms,OpsPerSample, ...
              StopbandMax_dB,PassbandRipple_dB,LinearPhase);
end
