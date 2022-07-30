clear;

[msg_ascii, segment_count] = get_ascii("./message_to_be_encoded.txt");
[music, window_length, Fs] = get_music("./source_music.wav", segment_count);

idx = 1; amp = 0.25;
t = 0 : 1/Fs : window_length/Fs - 1/Fs;
ramp_up   = linspace(0, 1, length(t)/3);
ramp_none = linspace(1, 1, length(t)/3);
ramp_down = linspace(1, 0, length(t)/3);
amplitudeEnvelope = [ramp_up, ramp_none, ramp_down];

for i = 1 : segment_count

	if i == 1
		freq = 15000;
	else
		freq = 16000 + msg_ascii(i - 1) * 20;
	end

	% create signal
	sig = amp * sin(2*pi*freq*t);
	sig = sig .* amplitudeEnvelope;

	% embed signal
	lim_idx = idx - 1 + window_length;
	music(idx:lim_idx) = music(idx:lim_idx) + sig';

	% move to the next window
	idx = idx + window_length;
end

audiowrite("message_with_music.wav", music, Fs);

disp(" ");
disp("*** Completed ***");
disp(" ");

function [msg_ascii, segment_count] = get_ascii(fname)
	fid = fopen(fname, "r");
	msg = fgetl(fid);
	fclose(fid);

	disp(strcat("Message: ", msg));
	msg_ascii = double(pad(msg, 280));
	segment_count = length(msg_ascii) + 1;
end

function [music, window_length, Fs] = get_music(fname, segment_count)
	[stereo, Fs] = audioread(fname);
	mono = (stereo(:,1) + stereo(:,2)) / 2;
	filtered = lowpass(mono, 13000, Fs);

	arr_length = length(filtered);
	pad_amt = ceil(arr_length/segment_count) * segment_count - arr_length;

	music = padarray(filtered, pad_amt, 'post');
	window_length = length(music) / segment_count;
	disp(strcat("Window Length: ", num2str(window_length)));
end