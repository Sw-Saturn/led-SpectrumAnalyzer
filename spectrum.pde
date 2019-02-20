import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
 
Serial port;
 
Minim minim;
AudioInput in;
FFT fft;
float[] peaks;

/**
 * Audio vars
 */
int peak_hold_time = 1;  // how long before peak decays
int[] peak_age;  // tracks how long peak has been stable, before decaying

// how wide each 'peak' band is, in fft bins
int binsperband = 10;
int peaksize; // how many individual peak bands we have (dep. binsperband)
float gain = 40; // in dB
//float dB_scale = 0.5;  // pixels per dB

int buffer_size = 1024;  // also sets FFT size (frequency resolution)
float sample_rate = 22050;
int spectrum_height = 176; // determines range of dB shown

/**
 * Misc. settings
 */
String serial_port = "/dev/tty.usbmodem142101";
int baud_rate = 57600;
boolean enable_32 = true;
int[] freq_range_maxes= { 30,60,100,150,200,250,300,350,400,650,900,1150,1400,1650,1900,2150,2400,2650,2900,3150,3400,3650,3900,4150,4400,4650,4900, 5150,5400,5650,5900 ,6150};

//int num_levels = enable_32 ? 32 : 16;
int num_levels = 64;
int[] freq_array = new int[num_levels];
int[] last_freq = new int[num_levels];
float[] freq_height = new float[num_levels];  //avg amplitude of each freq band

int i,g;
float f;

void setup() {
  size(200, 200);

  minim = new Minim(this);
  port = new Serial(this, serial_port, baud_rate); //set baud rate
  in = minim.getLineIn(Minim.STEREO, buffer_size, sample_rate);
  in.disableMonitoring();
 
  // create an FFT object that has a time-domain buffer 
  // the same size as line-in's sample buffer
  fft = new FFT(in.bufferSize(), in.sampleRate());
  // Tapered window important for log-domain display
  fft.window(FFT.HAMMING);

  // initialize peak-hold structures
  peaksize = 1+Math.round(fft.specSize()/binsperband);
  peaks = new float[peaksize];
  peak_age = new int[peaksize];
}

void draw() {
  for(int k = 0; k < num_levels; k++){
    freq_array[k] = 0;
  }

  // perform a forward FFT on the samples in input buffer
  fft.forward(in.mix);
  
  // Frequency Band Ranges
  for (int fh = 0; fh < freq_range_maxes.length; fh++) {
    if (enable_32) {
      // Use the set of 16 frequency ranges and split them
      // evenly to create 32 ranges
      int min = fh == 0 ? 0 : freq_range_maxes[fh-1] + 1;
      int max = freq_range_maxes[fh];
      int diff = (max - min) / 2;
      
      int max1 = min + diff;
      int min2 = min + diff + 1;
      
      int fh1 = fh*2;
      int fh2 = fh*2+1;
      
      freq_height[fh1] = fft.calcAvg((float) min, (float) max1);
      freq_height[fh2] = fft.calcAvg((float) min2, (float) max);
    } else {
      int max = freq_range_maxes[fh];
      int min = fh == 0 ? 0 : freq_range_maxes[fh-1] + 1;
      freq_height[fh] = fft.calcAvg((float) min, (float) max);
    }
  }

  // Amplitude Ranges: if else tree
  for (int j = 0; j < num_levels; j++) {
         if (freq_height[j] < 200000 && freq_height[j] > 200) { freq_array[j] = 32; }
    else if (freq_height[j] <= 200 && freq_height[j] > 185)   { freq_array[j] = 31; }
    else if (freq_height[j] <= 185 && freq_height[j] > 165)   { freq_array[j] = 30; }
    else if (freq_height[j] <= 165 && freq_height[j] > 150)   { freq_array[j] = 29; }
    else if (freq_height[j] <= 150 && freq_height[j] > 135)   { freq_array[j] = 28; }
    else if (freq_height[j] <= 135 && freq_height[j] > 125)   { freq_array[j] = 27; }
    else if (freq_height[j] <= 125 && freq_height[j] > 110)   { freq_array[j] = 26; }
    else if (freq_height[j] <= 110 && freq_height[j] > 100)   { freq_array[j] = 25; }
    else if (freq_height[j] <= 100 && freq_height[j] > 90)    { freq_array[j] = 24; }
    else if (freq_height[j] <= 90 && freq_height[j] > 80)    { freq_array[j] = 23; }
    else if (freq_height[j] <= 80 && freq_height[j] > 75)    { freq_array[j] = 22; }
    else if (freq_height[j] <= 75 && freq_height[j] > 70)    { freq_array[j] = 21; }
    else if (freq_height[j] <= 70 && freq_height[j] > 65)    { freq_array[j] = 20; }
    else if (freq_height[j] <= 65 && freq_height[j] > 60)    { freq_array[j] = 19; }
    else if (freq_height[j] <= 60 && freq_height[j] > 52)    { freq_array[j] = 18; }
    else if (freq_height[j] <= 52 && freq_height[j] > 48)    { freq_array[j] = 17; }
    else if (freq_height[j] <= 48 && freq_height[j] > 45)     { freq_array[j] = 16; }
    else if (freq_height[j] <= 45 && freq_height[j] > 40)     { freq_array[j] = 15; }
    else if (freq_height[j] <= 40 && freq_height[j] > 38)     { freq_array[j] = 14; }
    else if (freq_height[j] <= 38 && freq_height[j] > 35)     { freq_array[j] = 13; }
    else if (freq_height[j] <= 35 && freq_height[j] > 32)     { freq_array[j] = 12; }
    else if (freq_height[j] <= 32 && freq_height[j] > 30)     { freq_array[j] = 11; }
    else if (freq_height[j] <= 30 && freq_height[j] > 20)     { freq_array[j] = 10; }
    else if (freq_height[j] <= 20 && freq_height[j] > 18)     { freq_array[j] = 9; }
    else if (freq_height[j] <= 18 && freq_height[j] > 15)     { freq_array[j] = 8; }
    else if (freq_height[j] <= 15 && freq_height[j] > 12)     { freq_array[j] = 6; }
    else if (freq_height[j] <= 12 && freq_height[j] > 10)     { freq_array[j] = 5; }
    else if (freq_height[j] <= 10 && freq_height[j] > 8)      { freq_array[j] = 4; }
    else if (freq_height[j] <= 8 && freq_height[j] > 5)      { freq_array[j] = 3; }
    else if (freq_height[j] <= 5 && freq_height[j] > 2)      { freq_array[j] = 2; }
    else if (freq_height[j] <= 2 && freq_height[j] >= 1)      { freq_array[j] = 1; }
    else if (freq_height[j] < 1 )                             { freq_array[j] = 0; }
  }
  
  for (i = 0; i < num_levels; i++) {
    
    if (freq_array[i] != last_freq[i]) {
      String out = i + ":" + freq_array[i] + "\n";
      println(out.trim());
      port.write(out);
      last_freq[i] = freq_array[i];
      
      if (i % 3 == 0)
        delay(3);
    }
  }
  
  delay(1); //delay for and timing
}
 
 
void stop() {
  // always close Minim audio classes when you finish with them
  in.close();
  minim.stop();
  super.stop();
}
