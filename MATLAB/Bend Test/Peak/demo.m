% Load data
load results.dat

% We expect five peaks/valleys in the results trace
halfwidth = max(size(results))/20;

% Find peaks and valleys
P = findvalleys([1:size(results)], -results, Inf, -Inf, halfwidth, halfwidth, 3);
peaks = P(:,2);
P = findvalleys([1:size(results)], results, -Inf, -Inf, halfwidth, halfwidth, 3);
valleys = P(:,2);

% Display results
plot(results, 'b');
hold on;
for i=1:size(peaks)
   plot([peaks(i) peaks(i)], [min(results) max(results)],'r');
end
for i=1:size(valleys)
   plot([valleys(i) valleys(i)], [min(results) max(results)],'m');
end
hold off
grid on
