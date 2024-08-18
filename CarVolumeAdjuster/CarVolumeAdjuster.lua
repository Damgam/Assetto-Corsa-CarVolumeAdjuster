
ConfigFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACApps) .. "/lua/CarVolumeAdjuster/" .. "settings.ini")


Sim = ac.getSim()
Car = ac.getCar(Sim.focusedCar)
-- Session = ac.getSession(Sim.currentSessionIndex)

ListOfCars = {}
ListOfCarModels = {}
AlreadyListedCars = {}

local lastCamera

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
        local Surfaces = ac.getAudioVolume('surfaces')
        local Dirt = ac.getAudioVolume('dirt')
        local Wind = ac.getAudioVolume('wind')
        local Opponents = ac.getAudioVolume('opponents')

        local masterVolume = ConfigFile:get(carFolder, "master", 1)
        local engineVolume = ConfigFile:get(carFolder, "engine", 1)
        local transmissionVolume = ConfigFile:get(carFolder, "transmission", 1)
        local tyresVolume = ConfigFile:get(carFolder, "tyres", 1)
        local windVolume = ConfigFile:get(carFolder, "wind", 1)
        local opponentsVolume = ConfigFile:get(carFolder, "opponents", 1)

        local engineVolumeExterior = ConfigFile:get(carFolder, "engineexterior", 1)
        local engineVolumeInterior = ConfigFile:get(carFolder, "engineinterior", 1)

        local tyresVolumeExterior = ConfigFile:get(carFolder, "tyresexterior", 1)
        local tyresVolumeInterior = ConfigFile:get(carFolder, "tyresinterior", 1)

        if ac.isInteriorView() then
            Engine = Engine*engineVolumeInterior
            Transmission = Transmission*engineVolumeInterior
            Tyres = Tyres*tyresVolumeInterior
            Surfaces = Surfaces*tyresVolumeInterior
            Dirt = Dirt*tyresVolumeInterior
        else
            Engine = Engine*engineVolumeExterior
            Transmission = Transmission*engineVolumeExterior
            Tyres = Tyres*tyresVolumeExterior
            Surfaces = Surfaces*tyresVolumeExterior
            Dirt = Dirt*tyresVolumeExterior
        end

        ac.setAudioVolume('engine',         masterVolume*engineVolume*Engine,               carIndex)
        ac.setAudioVolume('transmission',   masterVolume*transmissionVolume*Transmission,   carIndex)
        ac.setAudioVolume('tyres',          masterVolume*tyresVolume*Tyres,                 carIndex)
        ac.setAudioVolume('surfaces',       masterVolume*tyresVolume*Surfaces,                 carIndex)
        ac.setAudioVolume('dirt',           masterVolume*tyresVolume*Dirt,                 carIndex)
        ac.setAudioVolume('wind',           masterVolume*windVolume*Wind,                   carIndex)
        ac.setAudioVolume('opponents',      masterVolume*opponentsVolume*Opponents,         carIndex)
    end
end
UpdateAllCarsVolume()

local Updates = 0
function script.update(dt)
    Updates = Updates + 1
    if Updates % 60 == 0 and Car.speedKmh < 10 then
        UpdateAllCarsVolume()
    end
    if lastCamera ~= ac.isInteriorView() then
        ac.log("Camera Changed", lastCamera)
        lastCamera = ac.isInteriorView()
        UpdateAllCarsVolume()
    end
end

for i = 1,#ListOfCarModels do
    ac.log(ListOfCarModels[i].folderName)
end

function CarTab()
    for i = 1,#ListOfCarModels do
        local carFolder = ListOfCarModels[i].folderName
        ConfigFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACApps) .. "/lua/CarVolumeAdjuster/" .. "settings.ini")
        if carFolder == LastSelectedTab then

            ui.text("Main Volume")
            local oldSliderValue = ConfigFile:get(carFolder, "master", 1)
            local sliderValue = ui.slider("Master ##slider" .. SliderCounter, oldSliderValue, 0.01, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "master", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            ui.button("Reset", 20, flags)
            if ui.itemClicked(0) then
                ConfigFile:set(carFolder, "master", 1)
                ConfigFile:set(carFolder, "engine", 1)
                ConfigFile:set(carFolder, "engineinterior", 1)
                ConfigFile:set(carFolder, "engineexterior", 1)
                ConfigFile:set(carFolder, "transmission", 1)
                ConfigFile:set(carFolder, "tyres", 1)
                ConfigFile:set(carFolder, "tyresinterior", 1)
                ConfigFile:set(carFolder, "tyresexterior", 1)
                ConfigFile:set(carFolder, "wind", 1)
                ConfigFile:set(carFolder, "opponents", 1)
                ConfigFile:save()
                UpdateAllCarsVolume()
                ConfigFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACApps) .. "/lua/CarVolumeAdjuster/" .. "settings.ini")
            end

            ui.text("Fine Tuning")

            local oldSliderValue = ConfigFile:get(carFolder, "opponents", 1)
            local sliderValue = ui.slider("Opponents ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                ac.debug("oldSliderValue", oldSliderValue)
                ac.debug("sliderValue", sliderValue)
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "opponents", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "engine", 1)
            local sliderValue = ui.slider("Engine ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "engine", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "transmission", 1)
            local sliderValue = ui.slider("Transmission ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "transmission", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "tyres", 1)
            local sliderValue = ui.slider("Tyres/Surfaces ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "tyres", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "wind", 1)
            local sliderValue = ui.slider("Wind ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "wind", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            ui.text("Camera Multipliers - Applied on top of Fine Tuning values")
            
            local oldSliderValue = ConfigFile:get(carFolder, "engineinterior", 1)
            local sliderValue = ui.slider("Engine/Transmission Interior ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "engineinterior", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "engineexterior", 1)
            local sliderValue = ui.slider("Engine/Transmission Exterior ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "engineexterior", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "tyresinterior", 1)
            local sliderValue = ui.slider("Tyres/Surfaces Interior ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "tyresinterior", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            local oldSliderValue = ConfigFile:get(carFolder, "tyresexterior", 1)
            local sliderValue = ui.slider("Tyres/Surfaces Exterior ##slider" .. SliderCounter, oldSliderValue, 0.001, 2)
            if oldSliderValue ~= sliderValue then
                oldSliderValue = sliderValue
                ConfigFile:set(carFolder, "tyresexterior", sliderValue)
                if ui.itemEdited() then
                    NeedToSave = true
                end
            end
            SliderCounter = SliderCounter+1

            if NeedToSave then
                ConfigFile:save()
                UpdateAllCarsVolume()
            end
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
    SliderCounter = 0
    ui.tabBar("Cars", {}, TabsFunction)
    NeedToSave = false
end

ac.setWindowSizeConstraints('main', vec2(400,400), vec2(999999,400))