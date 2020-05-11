#include "MPU-6050.h"
#include <Wire.h>
#include <Adafruit_NeoPixel.h>

#define NEO_PIN 13
#define NUMPIXELS 16
#define STEP (PI/8)

// Variables
int error;
accel_t_gyro_union accel_t_gyro;
unsigned long elapsed;
double x, y, z, alfa;
uint8_t LED, remainder;
  
// Define Neopixel strip object
Adafruit_NeoPixel pixels(NUMPIXELS, NEO_PIN, NEO_GRB + NEO_KHZ800);

void setup()
{      
  uint8_t c;
 
  Serial.begin(9600);
  Serial.println(F("InvenSense MPU-6050"));
  Serial.println(F("June 2012"));
 
  // Initialize the 'Wire' class for the I2C-bus.
  Wire.begin();
 
 
  // default at power-up:
  //    Gyro at 250 degrees second
  //    Acceleration at 2g
  //    Clock source at internal 8MHz
  //    The device is in sleep mode.
  //
 
  error = MPU6050_read (MPU6050_WHO_AM_I, &c, 1);
  Serial.print(F("WHO_AM_I : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);
 
  // According to the datasheet, the 'sleep' bit
  // should read a '1'.
  // That bit has to be cleared, since the sensor
  // is in sleep mode at power-up.
  // Clear the 'sleep' bit to start the sensor, and set clock source to 32.768 kHz reference
  MPU6050_write_reg (MPU6050_PWR_MGMT_1, 0x04);

  error = MPU6050_read (MPU6050_PWR_MGMT_1, &c, 1);
  Serial.print(F("PWR_MGMT_1 : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  // Set DLPF_CFG to 2: around 96 [Hz] filter bandwidth, 2.9 [ms] delay and 1 [kHz] sampling frequency 
  MPU6050_write_reg (MPU6050_CONFIG, 0x02);

  error = MPU6050_read (MPU6050_CONFIG, &c, 1);
  Serial.print(F("MPU6050_CONFIG : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_GYRO_CONFIG, &c, 1);
  Serial.print(F("MPU6050_GYRO_CONFIG : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_ACCEL_CONFIG, &c, 1);
  Serial.print(F("MPU6050_ACCEL_CONFIG : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_SMPLRT_DIV, &c, 1);
  Serial.print(F("MPU6050_SMPLRT_DIV : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_SELF_TEST_A, &c, 1);
  Serial.print(F("MPU6050_SELF_TEST_A : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_SELF_TEST_X, &c, 1);
  Serial.print(F("MPU6050_SELF_TEST_X : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_SELF_TEST_Y, &c, 1);
  Serial.print(F("MPU6050_SELF_TEST_Y : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  error = MPU6050_read (MPU6050_SELF_TEST_Z, &c, 1);
  Serial.print(F("MPU6050_SELF_TEST_Z : "));
  Serial.print(c,HEX);
  Serial.print(F(", error = "));
  Serial.println(error,DEC);

  // Initialize Neopixel strip object
  pixels.begin();
}
 
 
void loop()
{
  
  elapsed = millis();
 
  // Serial.println(F(""));
  // Serial.println(F("MPU-6050"));
 
  // Read the raw values.
  // Read 14 bytes at once,
  // containing acceleration, temperature and gyro.
  // With the default settings of the MPU-6050,
  // there is no filter enabled, and the values
  // are not very stable.
  error = MPU6050_read (MPU6050_ACCEL_XOUT_H, (uint8_t *) &accel_t_gyro, sizeof(accel_t_gyro));
  // Serial.print(F("Read accel, temp and gyro, error = "));
  // Serial.println(error,DEC);
 
  // Ordering sensor data: 
  // Swapping low and high bytes in memory for correct integer sequence 
  MPU6050_order_data (&accel_t_gyro);

  // Caculate test ring angle to Z axis of MPU-6050
  // zero eccentiricty assumed
  y = accel_t_gyro.value.y_accel;
  z = accel_t_gyro.value.z_accel;
  alfa = PI - atan2(y,z); // rad 0-2PI

  // Choose LEDs to light up
  LED = round(alfa/STEP+0.25);
  if (LED > 15)
  {
    LED = 0;
  }
  
  if (LED == 15)
  {
    pixels.setPixelColor(0, pixels.Color(0, 0, 0)); //off
  }
  else
  {
    pixels.setPixelColor(LED+1, pixels.Color(0, 0, 0)); //off
  }

  // pixels.clearPixels();
  pixels.setPixelColor(LED, pixels.Color(0, 150, 0)); //light green

  LED = round(alfa/STEP-0.25);
  pixels.setPixelColor(LED, pixels.Color(0, 150, 0)); //light green

  if (LED == 0)
  {
    pixels.setPixelColor(15, pixels.Color(0, 0, 0)); //off
  }
  else
  {
    pixels.setPixelColor(LED-1, pixels.Color(0, 0, 0)); //off
  }

  pixels.show();

  // Print raw data
  // MPU6050_print_rawdata (&accel_t_gyro);
  
  // Track loop time
  elapsed = millis() - elapsed;
  // Serial.print(F("Elapsed time [ms] : "));
  Serial.print(elapsed,DEC);
  Serial.print(F(" ms, angle: "));
  Serial.println(alfa*360/2/PI);

  // delay(1000);
}

// --------------------------------------------------------
// MPU6050_order_data
//
// Swap all high and low bytes in given accel_t_gyro_union reg structure
// After this, the registers values are swapped,
// so the structure name like x_accel_l does no
// longer contain the lower byte.
void MPU6050_order_data(accel_t_gyro_union * pData)
{
  uint8_t swap;
  #define SWAP(x,y) swap = x; x = y; y = swap
 
  SWAP (pData->reg.x_accel_h, pData->reg.x_accel_l);
  SWAP (pData->reg.y_accel_h, pData->reg.y_accel_l);
  SWAP (pData->reg.z_accel_h, pData->reg.z_accel_l);
  SWAP (pData->reg.t_h, pData->reg.t_l);
  SWAP (pData->reg.x_gyro_h, pData->reg.x_gyro_l);
  SWAP (pData->reg.y_gyro_h, pData->reg.y_gyro_l);
  SWAP (pData->reg.z_gyro_h, pData->reg.z_gyro_l);

}

// --------------------------------------------------------
// MPU6050_print_data
//
// Prints all data last read from MPU-6050
void MPU6050_print_rawdata(accel_t_gyro_union * pData)
{

  // Print the raw acceleration values
  
  Serial.print(F("accel x,y,z decimal: "));
  Serial.print(pData->value.x_accel, DEC);
  Serial.print(F(", "));
  Serial.print(pData->value.y_accel, DEC);
  Serial.print(F(", "));
  Serial.print(pData->value.z_accel, DEC);
  Serial.println(F(""));
  Serial.print(F("accel x,y,z raw: "));
  Serial.print(pData->value.x_accel, BIN);
  Serial.print(F(", "));
  Serial.print(pData->value.y_accel, BIN);
  Serial.print(F(", "));
  Serial.print(pData->value.z_accel, BIN);
  Serial.println(F(""));
 
 
  // The temperature sensor is -40 to +85 degrees Celsius.
  // It is a signed integer.
  // According to the datasheet:
  //   340 per degrees Celsius, -512 at 35 degrees.
  // At 0 degrees: -512 - (340 * 35) = -12412
 
  Serial.print(F("temperature: "));
//   dT = ( (double) pData->value.temperature + 12412.0) / 340.0;
  Serial.print(pData->value.temperature, DEC);
  Serial.print(F(" degrees Celsius"));
  Serial.println(F(""));
 
 
  // Print the raw gyro values.
 
  Serial.print(F("gyro x,y,z : "));
  Serial.print(pData->value.x_gyro, DEC);
  Serial.print(F(", "));
  Serial.print(pData->value.y_gyro, DEC);
  Serial.print(F(", "));
  Serial.print(pData->value.z_gyro, DEC);
  Serial.println(F(""));

}