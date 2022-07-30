clear;

fs = 44100; bits = 16; channel = 1; duration = 33;
recorder = audiorecorder(fs, bits, channel);
recordblocking(recorder, duration);
y = getaudiodata(recorder);
disp("Finished recording. Decoding now.")

msg = "";
window_length = 4530;

% Find the start signal
for idx = 1 : length(y) - window_length

	freq = get_frequency(idx, y, fs, window_length);

	if round(freq, -1) > 15000
		break
	end
end
disp(strcat("Found start signal at position: ", num2str(idx)))

% Missed the start signal. Hence, it is a character.
if freq > 16000
	character = get_character(freq);
	msg = msg + character;
	disp(strcat("False Positive. That was not a start signal. It was the character '", character, "'." ))
end

idx = idx + 3397;

% Get the rest of the message
for j = 1 : 280

	idx = idx + window_length;

	freq = get_frequency(idx, y, fs, window_length);
	character = get_character(freq);
	msg = msg + character;
end

write_to_file(msg, "decoded_message.txt");

disp(" ");
disp("*** Completed ***");
disp(" ");

function freq = get_frequency(idx, music, fs, window_length)

	seg_y = music(idx : idx - 1 + window_length);
	abs_y = abs(fft(seg_y, 2 ^ nextpow2(length(seg_y))));
	[amp, pos] = max(abs_y(1 : length(abs_y/2)));

	freq = pos * fs / length(abs_y);
end

function character = get_character(freq)
	round_off_freq = floor(freq / 20) * 20;
	character = char((round_off_freq - 16000) / 20);
end

function write_to_file(msg, fname)
	disp(strcat("Message: ", msg))
	fid = fopen(fname,'w');
	fprintf(fid,'%s', msg);
	fclose(fid);
end