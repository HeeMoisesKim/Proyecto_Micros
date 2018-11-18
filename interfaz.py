# -*- coding: cp1252 -*-
import kivy

from kivy.app   import App
from kivy.uix.gridlayout import GridLayout
from kivy.uix.boxlayout import BoxLayout
from kivy.properties import StringProperty,ObjectProperty,NumericProperty
from kivy.uix.textinput import TextInput
from kivy.clock import Clock
import pkgutil
import serial
import time
package =serial
#for importers,modname,ispkg in pkgutil.iter_modules(package._path_):
#    print ("Found submodule %s (is a package: %s)" % (modname,ispkg))
UART= serial.Serial(port='COM13',baudrate=9600,bytesize=serial.EIGHTBITS,parity=serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,timeout=0)
valor=''
event=''
event2=''
event3=''
event4=''
event5=''
i=0
lista=[]
class Separador(BoxLayout):
    valor_1 = StringProperty('0')
    valor_2 = StringProperty('0')
    valor_3 = StringProperty('0')
    valor_4 = StringProperty('0')
    valor_5 = StringProperty('0')
    valor_6 = StringProperty('0')
    valor_7 = StringProperty('0')
    valor_8 = StringProperty('0')
    valor_serial =NumericProperty()
    valor_serial2=NumericProperty()
    valor_serial3=NumericProperty()
    valor_serial4=NumericProperty()
    display=ObjectProperty()
    selector=StringProperty('0')
    a=StringProperty('0')

    def Pot(self):
        global event3
        global event5
        event3 = Clock.schedule_interval(self.contar_2,0.001)
        event5 = Clock.schedule_interval(self.contar_1,0.001)
        self.selector='0'
        UART.write(chr(220))
        print chr(220)

    def PC(self):
        global event3
        global event5
        global event2
        event3.cancel()
        event5.cancel()
        self.selector='1'
        self.valor_1='N\A'
        self.valor_3='N\A'
        self.valor_5='N\A'
        self.valor_7='N\A'
        UART.write(chr(200))
        print chr(200)
    
    def __init__(self):
        global event2
        global event3
        global event4
        global event5
        super(Separador,self).__init__()
        event5 = Clock.schedule_interval(self.contar_1,0.001)
        event3 = Clock.schedule_interval(self.contar_2,0.001)
        event2 = Clock.schedule_interval(self.refresh_clk,0.025)
        event4 = Clock.schedule_interval(self.mostrarVal,0.025)

    def contar_1(self,dt):
        entrada=(str(UART.read()))
        if entrada == b'':
            pass
        try:   
            if ord(entrada) == 3:
                self.valor_serial=ord(UART.read())
                self.valor_serial2=ord(UART.read())
                self.valor_serial3=ord(UART.read())
                self.valor_serial4=ord(UART.read())
                UART.flushInput()
            else:
                pass
        except:
            print 'M'
        #self.valor_serial=(str(int(self.valor_serial+1)))
        #self.valor_serial2=(str(int(self.valor_serial+2)))
        #self.valor_serial3=(str(int(self.valor_serial+3)))
        #self.valor_serial4=(str(int(self.valor_serial+4)))
        self.valor_1=(str((float(self.valor_serial)*5)/255))
        self.valor_3=(str((float(self.valor_serial2)*5)/255))
        self.valor_5=(str((float(self.valor_serial3)*5)/255))
        self.valor_7=(str((float(self.valor_serial4)*5)/255))
    
    def contar_2(self,dt):
         self.valor_2 = str((int(self.valor_serial)*180/150))
         self.valor_4 = str((int(self.valor_serial2)*180/150))
         self.valor_6 = str((int(self.valor_serial3)*180/150))
         self.valor_8 = str((int(self.valor_serial4)*180/150))

    def refresh_clk(self,dt):
        global event2
        #UART.write(chr(self.valor_2))
        #UART.write(chr(self.valor_4))
        #UART.write(chr(self.valor_6))
        #UART.write(chr(self.valor_8))
        if self.selector == '1':
            #if ord(UART.read()) == 3:
                UART.write(chr(int(self.valor_2)))
                time.sleep(0.005)
                UART.write(chr(int(self.valor_4)))
                time.sleep(0.005)
                UART.write(chr(int(self.valor_6)))
                time.sleep(0.005)
                UART.write(chr(int(self.valor_8)))
                time.sleep(0.005)
                UART.write(chr(03))
                print(self.valor_2)
                print(self.valor_4)
                print(self.valor_6)
                print(self.valor_8)
            #else:
                pass
        else:
            UART.write(chr(220))
            pass
    def guardarVal(self,dt):
        if self.selector == '0':
            archivo = open('datos.txt','a')
            archivo.write(str(self.valor_serial)+',')
            archivo.write(str(self.valor_serial2)+',')
            archivo.write(str(self.valor_serial3)+',')
            archivo.write(str(self.valor_serial4)+',')
            archivo.close()
        else:
            pass

    def mostrarVal(self,dt):
        global i
        global lista
        if self.selector == '1':
            lista = []
            archivo = open('datos.txt','r')
            line = archivo.readlines()
            if line ==[]:
                hola = '0'
            else:
                hola = line[0]
            base = hola.split(',')
            x=i+4
            if x<len(base):
                for i in range (i,x):
                    lista.append(base[i])
                i=x
            else:
                for i in range (i,x):
                    lista.append('85')
                i=0      
            archivo.close()
            self.valor_2= lista[0]
            self.valor_4= lista[1]
            self.valor_6= lista[2]
            self.valor_8= lista[3]
        else:
            pass
    def start(self):
        global event
        if self.selector == '0':
            event = Clock.schedule_interval(self.guardarVal,0.001)
        else:
            pass

    def stop(self):
        global event
        if self.selector == '0':
            event.cancel()
        else:
            pass

    def pausa(self):
        global event2
        global event4
        if self.selector == '1':
            event2.cancel()
            event4.cancel()
        else:
            pass
        
    def play (self):
        global event2
        global event4
        if self.selector == '1':
            event2 = Clock.schedule_interval(self.refresh_clk,0.025)
            event4 = Clock.schedule_interval(self.mostrarVal,0.025)
        else:
            pass

    def clear(self):
        archivo = open('datos.txt','w')
        archivo.write('')
        archivo.close
        
    
class MainApp(App):
    def build (self):
        return Separador()

if __name__ == '__main__':
    MainApp().run()

#La mayoria de los que dicen self.algo son strings
#la cosa es que recibe el valor del angulo y lo muestra, pero el angulo que
#recibe ya esta entre 0 y 180, hay que hacer la conversion para tener un valor
#de 180 y pasarlo a lo que tenes de 13 a 51
