#Shreyas Sudhakar
#ME 545 Project 1 - Calculating Thermodynamic Properties
#2018

#Initialize
using PyCall
using ExcelReaders
using Plots
using Statistics #Needed to calculate mean
@pyimport scipy as sp
@pyimport xlwings as xl
@pyimport scipy.interpolate as int
@pyimport CoolProp.CoolProp as CP

#Import steam table
xls = openxl("SteamTables.xlsx") #open excel steam table file
satProps = readxlsheet(xls, "Saturation Table") #read in properties as an array

#Import water table
waterProps = readxlsheet(xls, "Water Table")

#Task A - Create functions that return thermodynamic properties based on appropriate inputs.
function saturationPressure(temperature)
    CP.PropsSI("P","T",temperature,"Q",0.0,"Water")
end

function liquidVolume(temperature) #vf
    D = CP.PropsSI("D","T",temperature,"Q",0.0,"Water")
    1/D
end

function vaporVolume(temperature) #vg
    D = CP.PropsSI("D","T",temperature,"Q",1,"Water")
    1/D
end

function saturationTemperature(pressure)
    CP.PropsSI("T","P",pressure,"Q",0.0,"Water")
end

function saturationTemperatureIsobars(entropy,pressure) #function that takes entropy as our X value, pressure as our constant pressure line value, outputs temperature as Y value
    CP.PropsSI("T","P",pressure,"S",entropy,"Water")
end

function liquidEnthalpy(temperature)  #hf
    CP.PropsSI("H","T",temperature,"Q",0.0,"Water")
end

function vaporEnthalpy(temperature)  #hg
    CP.PropsSI("H","T",temperature,"Q",1,"Water")
end

function liquidEntropy(temperature)  #sf
    CP.PropsSI("S","T",temperature,"Q",0.0,"Water")
end

function vaporEntropy(temperature) #sg
    CP.PropsSI("S","T",temperature,"Q",1,"Water")
end

function volume(temperature, pressure) #v
    D = CP.PropsSI("D","T",temperature,"P",pressure,"Water")
    1/D
end

function enthalpy(temperature, pressure) #h
    CP.PropsSI("H","T",temperature,"P",pressure,"Water")
end

function entropy(temperature, pressure) #s
    CP.PropsSI("S","T",temperature,"P",pressure,"Water")
end
#Task B - Compare the function values to the baseline steam tables provided in the assignment by calculating the least squares error for each property.
#This code could be made more elegant by utilizing a nested for loop that pulls the header columns from the excel sheet and queries appropriately named functions

#P
P_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 2]
    estimated = saturationPressure(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(P_errors,error) #append the new value for error
end

P_error = mean(P_errors)

#vf
vf_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 3]
    estimated = liquidVolume(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(vf_errors,error) #append the new value for error
end

vf_error = mean(vf_errors)

#vg
vg_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 4]
    estimated = vaporVolume(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(vg_errors,error) #append the new value for error
end

vg_error = mean(vg_errors)

#hf
hf_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 5]
    estimated = liquidEnthalpy(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(hf_errors,error) #append the new value for error
end

hf_error = mean(hf_errors)

#hg
hg_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 6]
    estimated = vaporEnthalpy(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(hg_errors,error) #append the new value for error
end

hg_error = mean(hg_errors)

#sf
sf_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 7]
    estimated = liquidEntropy(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(sf_errors,error) #append the new value for error
end

sf_error = mean(sf_errors)

#sg
sg_errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 8]
    estimated = vaporEntropy(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(sg_errors,error) #append the new value for error
end

sg_error = mean(sg_errors)

#v
v_errors = [] #initialize errors array to store least square error
for row = 2:length(waterProps[2:end,1])
    original = waterProps[row, 3]
    estimated = volume(waterProps[row, 1],waterProps[row, 2])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(v_errors,error) #append the new value for error
end

v_error = mean(v_errors)

#h
h_errors = [] #initialize errors array to store least square error
for row = 2:length(waterProps[2:end,1])
    original = waterProps[row, 4]
    estimated = enthalpy(waterProps[row, 1],waterProps[row, 2])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(h_errors,error) #append the new value for error
end

h_error = mean(h_errors)

#s
s_errors = [] #initialize errors array to store least square error
for row = 2:length(waterProps[2:end,1])
    original = waterProps[row, 5]
    estimated = entropy(waterProps[row, 1],waterProps[row, 2])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(s_errors,error) #append the new value for error
end

s_error = mean(s_errors)
# Task 3 - Plot a water temperature-entropy diagram with isobaric lines for pressures of 0.10,0.5,1.0,5,10,30,45,80,110,150,200, and 210.6 bar.

#create saturation line
pressures = 0.04:1:220
saturationLine = zeros(2*length(pressures), 2) #create an array for the saturation line, use 2 times pressure length because we are going to create a saturation liquid and saturation vapor line
for p = 1:length(pressures)
    T = saturationTemperature(pressures[p]*1e5) #calculate our temperature in bar
    saturationLine[p, :] = [liquidEntropy(T), T] #include the liquid entropy at the temperature and temprature as y value
end
for p = 1:length(pressures)
    T = saturationTemperature(pressures[p]*1e5) #calculate our temperature in bar
    saturationLine[p+length(pressures), :] = [vaporEntropy(T), T] #include the vapor entropy at the temperature and temprature as y value, want to run from the middle of our saturation line table to the very end
end

s = sortslices(saturationLine, dims=1) #want one continuous line, so we are sorting. This wouldnt matter if we did a scatterplot

#using Plots package to plot the saturation line
gr()
plot(s[1:end, 1], s[1:end, 2], label=["Saturation Line"],
    fill=(0, 0.5, :gray,),
    ylabel = "Temperature (K)",
    xlabel = "Entropy (J/(kg*K))")

#Plotting isobars
isobars = [0.10e5;0.5e5;1.0e5;5e5;10e5;30e5;45e5;80e5;110e5;150e5;200e5;210.6e5]
entropies = 1000:100:9200

for i = 1:length(isobars)
    pressure = isobars[i]
    temperatures = []
    for s in 1:length(entropies)
        push!(temperatures, saturationTemperatureIsobars(entropies[s],pressure))
    end
    plot!(entropies, temperatures, label=(string(pressure/1e5)*" bar")) #exclamation point appends this plot over the existing plot
end
gui()

plot!(0,4000) #Hack: plot a single point, for some reason graph does not regenerate unless this is called
