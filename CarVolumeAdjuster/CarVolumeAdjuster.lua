
ConfigFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACApps) .. "/lua/CarVolumeAdjuster/" .. "settings.ini")


Sim = ac.getSim()
Car = ac.getCar(Sim.focusedCar)
-- Session = ac.getSession(Sim.currentSessionIndex)

ListOfCars = {}
ListOfCarModels = {}
AlreadyListedCars = {}

function CreateListOfCars()
    local count = 0
    repeat
        ListOfCars[count + 1] = {
            index = count,
            folderName = ac.getCarID(count),
            humanName = ac.getCarName(count),
        }


        if not AlreadyListedCars[ListOfCars[count + 1].humanName] then
            ListOfCarModels[#ListOfCarModels+1] = {
                folderName = ListOfCars[count + 1].folderName,
                humanName = ListOfCars[count + 1].humanName,
            }
            AlreadyListedCars[ListOfCars[count + 1].humanName] = true
        end

        count = count + 1
    until not ac.getCarID(count)
end
CreateListOfCars()

function UpdateAllCarsVolume()
    for i = 1,#ListOfCars do
        local carIndex = ListOfCars[i].index
        local carFolder = ListOfCars[i].folderName
        --local carName = ListOfCars[i].humanName

        local Engine = ac.getAudioVolume('engine')
        local Transmission = ac.getAudioVolume('transmission')
        local Tyres = ac.getAudioVolume('tyres')
        local Wind = ac.getAudioVolume('wind')

        local masterVolume = ConfigFile:get(carFolder, "master", 1)
        local engineVolume = ConfigFile:get(carFolder, "engine", 1)
        local transmissionVolume = ConfigFile:get(carFolder, "transmission", 1)
        local tyresVolume = ConfigFile:get(carFolder, "tyres", 1)
        local windVolume = ConfigFile:get(carFolder, "wind", 1)

        ac.setAudioVolume('engine',         masterVolume*engineVolume*Engine,               carIndex)
        ac.setAudioVolume('transmission',   masterVolume*transmissionVolume*Transmission,   carIndex)
        ac.setAudioVolume('tyres',          masterVolume*tyresVolume*Tyres,                 carIndex)
        ac.setAudioVolume('wind',           masterVolume*windVolume*Wind,                   carIndex)
    end
end
UpdateAllCarsVolume()

local Updates = 0
function script.update(dt)
    Updates = Updates + 1
    if Updates % 60 == 0 and Car.speedKmh < 10 then
        UpdateAllCarsVolume()
    end
end

for i = 1,#ListOfCarModels do
    ac.log(ListOfCarModels[i].folderName)
end

function CarTab()
    for i = 1,#ListOfCarModels do
        local carFolder = ListOfCarModels[i].folderName
        if carFolder == LastSelectedTab then

            ui.text("Main Volume")
            local oldSliderValue = ConfigFile:get(carFolder, "master", 1)
            local sliderValue = ui.slider("Master ##slider" .. SliderCounter, oldSliderValue, 0.01, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "master", sliderValue)
                NeedToSave = true
                ConfigFile:save()
            end
            SliderCounter = SliderCounter+1

            ui.button("Reset", 20, flags)
            if ui.itemClicked(0) then
                ConfigFile:set(carFolder, "master", 1)
                ConfigFile:set(carFolder, "engine", 1)
                ConfigFile:set(carFolder, "transmission", 1)
                ConfigFile:set(carFolder, "tyres", 1)
                ConfigFile:set(carFolder, "wind", 1)
                NeedToSave = true
                ConfigFile:save()
            end

            ui.text("Fine Tuning")

            local oldSliderValue = ConfigFile:get(carFolder, "engine", 1)
            local sliderValue = ui.slider("Engine ##slider" .. SliderCounter, oldSliderValue, 0.01, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "engine", sliderValue)
                NeedToSave = true
                ConfigFile:save()
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "transmission", 1)
            local sliderValue = ui.slider("Transmission ##slider" .. SliderCounter, oldSliderValue, 0.01, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "transmission", sliderValue)
                NeedToSave = true
                ConfigFile:save()
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "tyres", 1)
            local sliderValue = ui.slider("Tyres ##slider" .. SliderCounter, oldSliderValue, 0.01, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "tyres", sliderValue)
                NeedToSave = true
                ConfigFile:save()
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "wind", 1)
            local sliderValue = ui.slider("Wind ##slider" .. SliderCounter, oldSliderValue, 0.01, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "wind", sliderValue)
                NeedToSave = true
                ConfigFile:save()
            end
            SliderCounter = SliderCounter+1
            break
        end
    end
end

function TabsFunction()
    for i = 1,#ListOfCarModels do
        ui.tabItem(ListOfCarModels[i].humanName, {ui.TabBarFlags.NoTabListScrollingButtons, ui.TabBarFlags.FittingPolicyScroll}, CarTab)
        if ui.itemClicked(0) then
            LastSelectedTab = ListOfCarModels[i].folderName
            ac.log(LastSelectedTab)
        end
    end
end

function script.windowMain()
    NeedToSave = false
    SliderCounter = 0

    ui.tabBar("Cars", {}, TabsFunction)

    if NeedToSave then
        UpdateAllCarsVolume()
    end
end

ac.setWindowSizeConstraints('main', vec2(350,260), vec2(999999,260))