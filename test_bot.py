import os, datetime, time, sys
from botcity.web import WebBot, Browser
from botcity.core import DesktopBot
from datetime import datetime, timedelta




#######################################
#
#      Function
#
######################################


def Function_diffdate(first_time, later_time):
    difference = later_time - first_time
    print(difference)
    return difference

def Function_CloseNavigateur(bot):
     print(" Boutonclose")
     if bot.find_until(label="Boutonclose", matching=0.97, waiting_time=10000):
        ele = bot.get_element_coords(label="Boutonclose", matching=0.97)
        print(ele)
        bot.mouse_move(x=ele[0], y=ele[1])
        bot.click()
        print(" Boutonclose Found!")


def Function_ErrorBot():
    pass

def Function_Write_Log(Msg,Fichier):
    fichier = open(Fichier, "a")
    fichier.write(Msg + "\n")
    fichier.close()


def Function_Write_OutputNagios(Status,PrintOut,Data,Fichier):
    fichier = open(Fichier, "w")
    fichier.write(Status + ":" + PrintOut + "|" + Data + "\n")
    fichier.close()
    sys.exit()

def Function_Formdata(Label,Valeur,Unit,Warn,Crit,min,max):
    return "'" + Label + "'" + "=" + str(Valeur) + str(Unit) + ";" + str(Warn) + ";" + str(Crit)  + ";" + str(min) + ";" +  str(max)

# Uncomment the line below for integrations with BotMaestro
# Using the Maestro SDK
# from botcity.maestro import *

MyPath = os.path.dirname(os.path.abspath(__file__)) 
MyRessource = MyPath + "/resources/"
LogFolder = "C:/Users/Administrateur/BotLog/"
NagiosFolder = "C:/NRPE_Bot/"
ScriptName = os.path.basename(__file__).replace('.py','')
TimeJalon = 3 
TimeJalonSecond = TimeJalon  * 60
Data = ""
Status = "OK"
PrintOut = ""

Url ="https://www.lemonde.fr/"
#######################################
#
#      Declaration Image
#
######################################

my_dict = {"Chrome": MyRessource  + "Chrome.png",
            "Chrome_Url": MyRessource  + "Chrome_Url.png",
            "Chrome_Barre_Tache": MyRessource  + "Chrome_Barre_Tache.png",
            "Boutonclose": MyRessource  + "Boutonclose.png",        
            "Le_Monde_fr": MyRessource  + "Le_Monde_fr.png"}




Function_Write_Log("------------------------------",LogFolder + ScriptName + '.log')
Function_Write_Log(str(datetime.now()) + " : Start Bot ",LogFolder + ScriptName + '.log')

bot = DesktopBot()

first_time = datetime.now()
Function_Write_Log(str(datetime.now()) + " : Verification presence image ",LogFolder + ScriptName + '.log')
for i in my_dict:
    if os.path.exists(my_dict[i]):
        bot.add_image(i, my_dict[i])
        Function_Write_Log("        OK :  "  + my_dict[i] ,LogFolder + ScriptName + '.log')
    else:
        Function_Write_Log("        ERROR :  " + my_dict[i] ,LogFolder + ScriptName + '.log')
        Status = "CRITICAL"
        PrintOut = "Fichier ressource : " + my_dict[i] + " Non trouver"


if Status == "OK" :
    StartAction = datetime.now()
    if bot.find_until(label="Chrome", matching=0.97, waiting_time=TimeJalonSecond * 1000):
        print(" Chrome Found!")
        Function_Write_Log(str(datetime.now()) + " : Chrome Found!",LogFolder + ScriptName + '.log')
        TimeAction = Function_diffdate(StartAction, datetime.now())
        Data = Function_Formdata('Chrome',TimeAction.seconds,'s',120,150,0,TimeJalonSecond) 
        ele = bot.get_element_coords(label="Chrome", matching=0.97)
        print(ele)
        bot.mouse_move(x=ele[0], y=ele[1])
        bot.double_click()
        StartAction = datetime.now()
        if bot.find_until(label="Chrome_Url", matching=0.97, waiting_time=TimeJalonSecond * 1000):
            print(" Chrome_Url Found!")
            Function_Write_Log(str(datetime.now()) + " : Chrome_Url Found!",LogFolder + ScriptName + '.log')
            ele = bot.get_element_coords(label="Chrome_Url", matching=0.97)
            print(ele)
            bot.mouse_move(x=ele[0], y=ele[1])
            bot.click()
            bot.paste(Url)
            bot.enter()
            Function_diffdate(first_time, datetime.now())
            TimeAction = Function_diffdate(StartAction, datetime.now())
            Data = Data + " " + Function_Formdata('Url renseigne',TimeAction.seconds,'s',120,150,0,TimeJalonSecond)  
            BoucleEnd = datetime.now() + timedelta(minutes = TimeJalon)

            StartAction = datetime.now()
            while True:        
                if bot.find_until(label="Le_Monde_fr", matching=0.97, waiting_time=TimeJalonSecond * 1000):
                    Function_Write_Log(str(datetime.now()) + " :  Le monde Found!",LogFolder + ScriptName + '.log')
                    print("Url "  + Url + " Found" )
                    PrintOut = "Url "  + Url + " Found" 
                    TimeAction = Function_diffdate(StartAction, datetime.now())
                    Data = Data + " " + Function_Formdata('Ouverture Le monde',TimeAction.seconds,'s',120,150,0,TimeJalonSecond) 
                    Status = "OK"
                    Function_diffdate(first_time, datetime.now())
                    Function_CloseNavigateur(bot)
                    break
                
                if datetime.now() > BoucleEnd :
                    Function_Write_Log(str(datetime.now()) + " : Le monde Not Found!",LogFolder + ScriptName + '.log')
                    print("Url "  + Url + " Not Found" )
                    PrintOut = "Url "  + Url + " Not Found" 
                    TimeAction = Function_diffdate(StartAction, datetime.now())
                    Data = Data + " " + Function_Formdata('Ouverture Le monde',TimeAction.seconds,'s',120,150,0,TimeJalonSecond)
                    Status = "CRITICAL"
                    Function_CloseNavigateur(bot)
                    break

            Function_Write_OutputNagios(Status,PrintOut,Data,NagiosFolder + ScriptName + '.log')
    else:        
        Function_Write_Log(str(datetime.now()) + " : Error Chrome not found",LogFolder + ScriptName + '.log')
        TimeAction = Function_diffdate(StartAction, datetime.now())
        Data = Function_Formdata('Chrome',TimeAction.seconds,'s',120,150,0,TimeJalonSecond) 
        print("Error Chrome not found")
        PrintOut = "Error Chrome not found"


    Function_Write_Log(str(datetime.now()) + " : End Bot ",LogFolder + ScriptName + '.log')

else:
    Function_Write_OutputNagios(Status,PrintOut,Data,NagiosFolder + ScriptName + '.log')


Function_Write_OutputNagios(Status,PrintOut,Data,NagiosFolder + ScriptName + '.log')
