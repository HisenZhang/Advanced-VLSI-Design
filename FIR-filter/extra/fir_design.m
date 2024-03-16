function Hd = untitled
%UNTITLED Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 23.2 and DSP System Toolbox 23.2.
% Generated on: 15-Mar-2024 18:56:38

% Equiripple Lowpass filter designed using the FIRPM function.

% All frequency values are normalized to 1.

N     = 100;    % Order
Fpass = 0.2;    % Passband Frequency
Fstop = 0.23;   % Stopband Frequency
Wpass = 1;      % Passband Weight
Wstop = 10000;  % Stopband Weight
dens  = 20;     % Density Factor

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, [0 Fpass Fstop 1], [1 1 0 0], [Wpass Wstop], {dens});
Hd = dfilt.dffir(b);
% Set the arithmetic property.
set(Hd, 'Arithmetic', 'fixed', ...
    'CoeffWordLength', 16, ...
    'CoeffAutoScale', true, ...
    'Signed',         true, ...
    'InputWordLength', 16, ...
    'inputFracLength', 15, ...
    'FilterInternals',  'FullPrecision');
denormalize(Hd);

%% 

h = Hd.Numerator;

% Number of taps in the filter
N = length(h);

% Level of parallelism, L = 3 for example
L = 3;

% Initialize cell arrays to hold the sub-filter coefficients
h_sub = cell(1, L);

% Divide the coefficients among the L sub-filters
for i = 1:L
    h_sub{i} = h(i:L:end);
end

% Display the coefficients for each sub-filter
for i = 1:L
    fprintf('Sub-filter %d coefficients:\n', i);
    disp(h_sub{i});
end

% [EOF]