function BpodErrorSound()
ErrorSound = wavread('BpodError.wav');
try
sound(ErrorSound, 44100);
catch
end