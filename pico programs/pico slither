import math
from machine import ADC, Pin, PWM
import utime

#Define servo motors
servo1 = PWM(Pin(15))
servo2 = PWM(Pin(16))


# Define servo pins
servo1_pin = machine.Pin(15)  # Pin GP0
servo2_pin = machine.Pin(16)  # Pin GP1

# Create PWM objects for servo control and Set PWM frequency to 50 Hz (standard for servos)
servo1_pwm = machine.PWM(servo1_pin)
servo2_pwm = machine.PWM(servo2_pin)
servo1_pwm.freq(50)
servo2_pwm.freq(50)

#important variables for the slither function
pi = 3.141519
shift = pi / 2

#servo parameters, both servos will not be exactly the same, experiment with max and min so setting to 90 zeros the servo
pwm1_max_ns = 2500
pwm1_min_ns = 550
pwm2_max_ns = 2600
pwm2_min_ns = 625

pwm1_max_u16 = (pwm1_max_ns/20000 * (65535)) #ms->16bit (2.5ms/20ms * (2^16-1))
pwm1_min_u16 = (pwm1_min_ns/20000 * (65535)) #ms->16bit(0.5ms/20ms * (2^16-1))
pwm2_max_u16 = (pwm2_max_ns/20000 * (65535)) #ms->16bit (2.5ms/20ms * (2^16-1))
pwm2_min_u16 = (pwm2_min_ns/20000 * (65535)) #ms->16bit(0.5ms/20ms * (2^16-1))

# Define function to move servos
def move_servos(servo1_duty, servo2_duty):
    servo1_pwm.duty_u16(servo1_duty)
    servo2_pwm.duty_u16(servo2_duty)

# I added a ServoWrite function to write the servo's to specific angles

def ServoWrite(Servo1Angle, Servo2Angle):
    duty1 = int((Servo1Angle / 180) * (pwm1_max_u16 - pwm1_min_u16) + pwm1_min_u16)
    duty2 = int((Servo2Angle / 180) * (pwm2_max_u16 - pwm2_min_u16) + pwm2_min_u16)
    servo1.duty_u16(duty1)
    servo2.duty_u16(duty2)
  

def Slither(speed = 1, offset = 0, amplitude = 20, runtime = 5):
    angle1 = 90 + offset
    angle2 = 90 + offset
    
    start_time = utime.ticks_ms()
    while utime.ticks_ms() - start_time < (runtime * 1000):
        
        angle1 = 90 + offset + amplitude * math.sin(speed *(utime.ticks_ms() - start_time)/(1000*pi))
        angle2 = 90 + offset + amplitude * math.sin(speed *(utime.ticks_ms() - start_time)/(1000*pi) + shift)
        
        print("angle1: " , angle1 , " angle2: " , angle2)
        
        ServoWrite(angle1,angle2)
        
        utime.sleep_ms(10)
        
    servo1.duty_u16(0)
    servo2.duty_u16(0)

# Main loop to move servos back and forth
while True:
    #Set both servo's to 0 degree's as the initial position
    utime.sleep_ms(2500)
    ServoWrite(90,90)
    utime.sleep_ms(5000)
    Slither(5, 0, 45, 30)
    #ServoWrite(90,90)
    utime.sleep_ms(2500)

'''
  ServoWrite(90,90)
  utime.sleep_ms(25)
  ServoWrite(180,180)
  utime.sleep_ms(25)
  ServoWrite(0,0)
'''  
  
'''
   j = 0
    for j in range(180):
        ServoWrite(j,j)
        if j == 180:
            j = 0
'''            
