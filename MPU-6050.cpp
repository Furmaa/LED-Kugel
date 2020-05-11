// MPU-6050 Accelerometer + Gyro
// -----------------------------
//
// By arduino.cc user "Krodal".
//
// June 2012
//      first version
// July 2013
//      The 'int' in the union for the x,y,z
//      changed into int16_t to be compatible
//      with Arduino Due.
//
// Open Source / Public Domain
//
// Using Arduino 1.0.1
// It will not work with an older version,
// since Wire.endTransmission() uses a parameter
// to hold or release the I2C bus.
//
// Documentation:
// - The InvenSense documents:
//   - "MPU-6000 and MPU-6050 Product Specification",
//     PS-MPU-6000A.pdf
//   - "MPU-6000 and MPU-6050 Register Map and Descriptions",
//     RM-MPU-6000A.pdf or RS-MPU-6000A.pdf
//   - "MPU-6000/MPU-6050 9-Axis Evaluation Board User Guide"
//     AN-MPU-6000EVB.pdf
//
// The accuracy is 16-bits.
 
#include <Wire.h>
#include "MPU-6050.h"
 
int MPU6050_read(int start, uint8_t *buffer, int size)
{
  int i, n;
 
  Wire.beginTransmission(MPU6050_I2C_ADDRESS);
  n = Wire.write(start);
  if (n != 1)
    return (-10);
 
  n = Wire.endTransmission(false);    // hold the I2C-bus
  if (n != 0)
    return (n);
 
  // Third parameter is true: relase I2C-bus after data is read.
  Wire.requestFrom(MPU6050_I2C_ADDRESS, size, true);
  i = 0;
  while(Wire.available() && i<size)
  {
    buffer[i++]=Wire.read();
  }
  if ( i != size)
    return (-11);
 
  return (0);  // return : no error
}
 

int MPU6050_write(int start, const uint8_t *pData, int size)
{
  int n, error;
 
  Wire.beginTransmission(MPU6050_I2C_ADDRESS);
  n = Wire.write(start);        // write the start address
  if (n != 1)
    return (-20);
 
  n = Wire.write(pData, size);  // write data bytes
  if (n != size)
    return (-21);
 
  error = Wire.endTransmission(true); // release the I2C-bus
  if (error != 0)
    return (error);
 
  return (0);         // return : no error
}
 
int MPU6050_write_reg(int reg, uint8_t data)
{
  int error;
 
  error = MPU6050_write(reg, &data, 1);
 
  return (error);
}

// void MPU6050_order_data(accel_t_gyro_union * pData)
// {
//   uint8_t swap;
//   #define SWAP(x,y) swap = x; x = y; y = swap
 
//   SWAP (pData->reg.x_accel_h, pData->reg.x_accel_l);
//   SWAP (pData->reg.y_accel_h, pData->reg.y_accel_l);
//   SWAP (pData->reg.z_accel_h, pData->reg.z_accel_l);
//   SWAP (pData->reg.t_h, pData->reg.t_l);
//   SWAP (pData->reg.x_gyro_h, pData->reg.x_gyro_l);
//   SWAP (pData->reg.y_gyro_h, pData->reg.y_gyro_l);
//   SWAP (pData->reg.z_gyro_h, pData->reg.z_gyro_l);

// }

// void MPU6050_print_rawdata(accel_t_gyro_union * pData)
// {

//   // Print the raw acceleration values
  
//   Serial.print(F("accel x,y,z decimal: "));
//   Serial.print(pData->value.x_accel, DEC);
//   Serial.print(F(", "));
//   Serial.print(pData->value.y_accel, DEC);
//   Serial.print(F(", "));
//   Serial.print(pData->value.z_accel, DEC);
//   Serial.println(F(""));
//   Serial.print(F("accel x,y,z raw: "));
//   Serial.print(pData->value.x_accel, BIN);
//   Serial.print(F(", "));
//   Serial.print(pData->value.y_accel, BIN);
//   Serial.print(F(", "));
//   Serial.print(pData->value.z_accel, BIN);
//   Serial.println(F(""));
 
 
//   // The temperature sensor is -40 to +85 degrees Celsius.
//   // It is a signed integer.
//   // According to the datasheet:
//   //   340 per degrees Celsius, -512 at 35 degrees.
//   // At 0 degrees: -512 - (340 * 35) = -12412
 
//   Serial.print(F("temperature: "));
// //   dT = ( (double) pData->value.temperature + 12412.0) / 340.0;
//   Serial.print(pData->value.temperature, DEC);
//   Serial.print(F(" degrees Celsius"));
//   Serial.println(F(""));
 
 
//   // Print the raw gyro values.
 
//   Serial.print(F("gyro x,y,z : "));
//   Serial.print(pData->value.x_gyro, DEC);
//   Serial.print(F(", "));
//   Serial.print(pData->value.y_gyro, DEC);
//   Serial.print(F(", "));
//   Serial.print(pData->value.z_gyro, DEC);
//   Serial.println(F(""));

// }