#Libraries for WIFI
import network
import socket
from time import sleep
import machine

#Libraries for Servos
import math
from machine import ADC, Pin, PWM
import utime

# Yes, these could be in another file.
ssid = 'NinerWiFi-Guest'
password = ''

#Define servo motors
servo1 = PWM(Pin(15))
servo2 = PWM(Pin(16))

# Define servo pins
servo1_pin = machine.Pin(15)  # Pin GP0
servo2_pin = machine.Pin(16)  # Pin GP1

led = machine.Pin("LED", machine.Pin.OUT)

# Create PWM objects for servo control and Set PWM frequency to 50 Hz (standard for servos)
servo1_pwm = machine.PWM(servo1_pin)
servo2_pwm = machine.PWM(servo2_pin)
servo1_pwm.freq(50)
servo2_pwm.freq(50)

#important variables for the slither function
pi = 3.141519
shift = pi / 2

#servo parameters, both servos will not be exactly the same, experiment with max and min so setting to 90 zeros the servo
pwm1_max_ns = 2550
pwm1_min_ns = 550
pwm2_max_ns = 2500
pwm2_min_ns = 535

pwm1_max_u16 = (pwm1_max_ns/20000 * (65535)) #ms->16bit (2.5ms/20ms * (2^16-1))
pwm1_min_u16 = (pwm1_min_ns/20000 * (65535)) #ms->16bit(0.5ms/20ms * (2^16-1))
pwm2_max_u16 = (pwm2_max_ns/20000 * (65535)) #ms->16bit (2.5ms/20ms * (2^16-1))
pwm2_min_u16 = (pwm2_min_ns/20000 * (65535)) #ms->16bit(0.5ms/20ms * (2^16-1))

def set_params(min1, max1, min2, max2):
    pwm1_max_ns = max1
    pwm1_min_ns = min1
    pwm2_max_ns = max2
    pwm2_min_ns = min2
    
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
  

def Slither(speed = 5, offset = 0, amplitude = 20, runtime = 5):
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
    
def connect():
    #Connect to WLAN
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid)
    while wlan.isconnected() == False:
        print('Waiting for connection...')
        sleep(1)
    ip = wlan.ifconfig()[0]
    print(f'Connected on {ip}')
    led.value(True)
    return ip
    
def open_socket(ip):
    # Open a socket
    address = (ip, 80)
    connection = socket.socket()
    connection.bind(address)
    connection.listen(1)
    return connection

def webpage():
    #Template HTML
    html = f"""
            <!DOCTYPE html>
            <html>
            <head>
            <title>Robot Control</title>
            </head>
            <center><b>
            <form action="./slither">
            <input type="submit" value="Slither" style="height:120px; width:120px" />
            <input type="text" name="speed_com" placeholder="Speed" />
            <input type="text" name="offset_com" placeholder="Positive-Left, Negative-Right" />
            <input type="text" name="amp_com" placeholder="Max Servo Angle Displacement" />
            <input type="text" name="sec_com" placeholder="Seconds" />
            </form>
            <table><tr>
            <td><form action="./min">
            <input type="submit" value="Test Min" style="height:120px; width:120px" />
            </form></td>
            <td><form action="./reset">
            <input type="submit" value="Reset" style="height:120px; width:120px" />
            </form></td>
            <td><form action="./max">
            <input type="submit" value="Test Max" style="height:120px; width:120px" />
            </form></td>
            </tr></table>
            <form action="./setservos">
            <input type="submit" value="Set Servos" style="height:120px; width:120px" />
            <input type="text" name="Set Servo 1" placeholder="Servo 1 Angle (0-180)" />
            <input type="text" name="Set Servo 2" placeholder="Servo 2 Angle (0-180)" />
            </form>
            
            <form action="./setpwms">
            <input type="submit" value="Set PWMs" style="height:120px; width:120px" />
            <input type="text" name="servo1_pwm_min" placeholder="Servo 1 PWM Min" />
            <input type="text" name="servo1_pwm_max" placeholder="Servo 1 PWM Max" />
            <input type="text" name="servo2_pwm_min" placeholder="Servo 2 PWM Min" />
            <input type="text" name="servo2_pwm_max" placeholder="Servo 2 PWM Max" />
            </form>
             
            </body>
            </html>
            """
    return str(html)

def serve(connection):
    #Start web server
    while True:
        client = connection.accept()[0]
        request = client.recv(1024)
        request = str(request)
        try:
            request = request.split()[1]
        except IndexError:
            pass
        if '/slither?' in request:
            params = request.split('?')[-1]
            params = params.split('&')
            speed_com = int(params[0].split('=')[-1])
            offset_com = int(params[1].split('=')[-1])
            amp_com = int(params[2].split('=')[-1])
            sec_com = int(params[3].split('=')[-1])
            Slither(speed_com, offset_com, amp_com, sec_com)
        elif request =='/min?':
            ServoWrite(0,0)
        elif request =='/reset?':
            ServoWrite(90,90)
        elif request =='/max?':
            ServoWrite(180,180)
        elif '/setservos?' in request:
            params = request.split('?')[-1]
            params = params.split('&')
            servo1_angle = int(params[0].split('=')[-1])
            servo2_angle = int(params[1].split('=')[-1])
            ServoWrite(servo1_angle, servo2_angle)
        elif '/setpwms?' in request:
            params = request.split('?')[-1]
            params = params.split('&')
            Smin1 = int(params[0].split('=')[-1])
            Smax1 = int(params[1].split('=')[-1])
            Smin2 = int(params[2].split('=')[-1])
            Smax2 = int(params[3].split('=')[-1])
            set_params(Smin1, Smax1, Smin2, Smax2)
        html = webpage()
        client.send(html)
        client.close()

try:
    ip = connect()
    connection = open_socket(ip)
    serve(connection)
except KeyboardInterrupt:
    machine.reset()
