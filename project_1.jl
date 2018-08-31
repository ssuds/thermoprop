#Shreyas Sudhakar
#ME 545 Project 1 - Calculating Thermodynamic Properties
#2018

#Initialize
using PyCall
using ExcelReaders
using Plots
@pyimport scipy as sp
@pyimport xlwings as xl
@pyimport scipy.interpolate as int
@pyimport CoolProp.CoolProp as CP

#Import steam table
xls = openxl("SteamTables.xlsx") #open excel steam table file
satProps = readxlsheet(xls, "Saturation Table") #read in properties as an array

#Task A - Create functions that return thermodynamic properties based on appropriate inputs.
function saturationPressure(temperature)
    CP.PropsSI("P","T",temperature,"Q",0.0,"Water")
end

function saturationTemperature(pressure)
    CP.PropsSI("T","P",pressure,"Q",0.0,"Water")
end

function saturationTemperatureIsobars(entropy,pressure) #function that takes entropy as our X value, pressure as our constant pressure line value, outputs temperature as Y value
    CP.PropsSI("T","P",pressure,"S",entropy,"Water")
end

function liquidEntropy(temperature)  #sf
    CP.PropsSI("S","T",temperature,"Q",0.0,"Water")
end

function vaporEntropy(temperature) #sg
    CP.PropsSI("S","T",temperature,"Q",1,"Water")
end

#Task B - Compare the function values to the baseline steam tables provided in the assignment by calculating the least squares error for each property.
errors = [] #initialize errors array to store least square error
for row = 2:length(satProps[2:end,1])
    original = satProps[row, 2]
    estimated = saturationPressure(satProps[row, 1])
    error = ((original -estimated)/original)^2 # Calculate least square error
    push!(errors,error) #append the new value for error
end

print(errors)

# Task 3 - Plot a water temperature-entropy diagram with isobaric lines for pressures of 0.10,0.5,1.0,5,10,30,45,80,110,150,200, and 210.6 bar.
#Use water properties to find enthalpy using 2d interpolation for the last part of the project
waterProps = readxlsheet(xls, "Water Table")
waterS = int.interp2d(waterProps[2:end,1], waterProps[2:end,2], waterProps[2:end, 5])

waterS(300, 10000)[1] #Interpolate entropy

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

#Plotting isobars

#10e5 isobar
pressure = 10e5
entropies = 1000:100:9200
temperatures = []
for s in 1:length(entropies)
    push!(temperatures, saturationTemperatureIsobars(entropies[s],pressure))
end

#using Plots package to plot the saturation line
gr()
plot(s[1:end, 1], s[1:end, 2],
    fill=(0, 0.5, :gray),
    ylabel = "Temperature (K)",
    xlabel = "Entropy (J/(kg*K))")
gui()

plot!(entropies, temperatures) #exclamation point appends this plot over the existing plot
