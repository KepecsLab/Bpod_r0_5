function BpodErrorSound()
ErrorSound = audioread('BpodError.wav');
try
sound(ErrorSound, 44100);
catch
end