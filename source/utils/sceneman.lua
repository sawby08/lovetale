--[[
    sceneman: scene manager

    scene management
    ----
    from the main script, call sceneman.update(dt) and sceneman.draw() on every update and draw, respectively
    (obviously).

    if you want to switch scene, call sceneman.switchScene(path, ...):
        - path is the require path to the lua script.
        - ... are the args to pass to the scene's load function.

    you can set sceneman.scenePrefix if all scenes are organized under a common folder, and you want to save typing.
    this scene prefix will be directly inserted before the path given in switchScene. also, sceneman.currentScene
    can be read to return the current scene. it is not advised to write to it.


    scene creation
    ----
    each scene should belong in its own script.
    to create a scene, call `sceneman.scene()`. it will return a scene object where you can then assign callbacks such
    as "load", "update(dt)", and "draw" (among others). the script must then return this scene object.


    callbacks
    ----
    you can also set names of love callbacks to each scene object. sceneman will then assign those functions to the
    respective love callback on load. you may also set sceneman.setLoveCallback(cbName, func) to override this
    process.

    there is also an alternative (and recommended) callback plan you enable by calling sceneman.enableCallbackHook()
    on application initialization. this will assign a metatable to the love table, making it so any love callbacks 
    will go through the callback of the active scene instead. you may still define callbacks in the love table. these
    raw callbacks can be called using `sceneman.rawCallback(cbName, ...)`.


    transitions
    ----
    you can switch to a scene with a transition by calling sceneman.useTransition(transitionPath, ...) before calling
    switchScene. the arguments work similarly to switchScene.

    it will use the given transition only for the next switchScene call. afterwards, it will be reset.

    there is also a sceneman.transitionPrefix that functions similarly to sceneman.scenePrefix, but for transitions.

    to create a transition, make a script and call sceneman.transition(). it will return a transition object where you
    will then assign the callbacks "load" (optional), "update(dt)", and "draw". the script must then return this
    transition object.

    additionally, each transition object will have three fields related to the current state of the transition, which
    are set before load is called:
        - oldScene: the scene that is being transitioned from. can be set to nil when the scene can be unloaded.
        - newScene: the scene that is being transitioned to. do not set.
        - done:     set to false before load is called, when set to true the transition will end on the next
                    sceneman.update call

    while the transition is in progress, scene.currentScene will be nil and scene.currentTransition will be set to the
    transition object.

    
    copyright notice
    ----
    
    Copyright 2025 pkhead

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software
    and associated documentation files (the “Software”), to deal in the Software without
    restriction, including without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or
    substantial portions of the Software.

    THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
    BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local sceneman = {}

-- placeholder functions
local function functionNoOp() end

---@class Scene
---@field load fun(args...: string)|nil
---@field unload fun()|nil
---@field update fun(dt: number)|nil
---@field draw fun()|nil
local Scene = {}
Scene.__index = Scene

Scene.load = functionNoOp
Scene.unload = functionNoOp
Scene.update = functionNoOp
Scene.draw = functionNoOp

---@class Transition
---@field load fun(args...: string)|nil
---@field update fun(dt: number)|nil
---@field draw fun()|nil
---@field oldScene Scene?
---@field newScene Scene
---@field done boolean
local Transition = {}
Transition.__index = Transition

Transition.load = functionNoOp
Transition.update = functionNoOp
Transition.draw = functionNoOp

---Let this module define a new scene. The calling module must then define callbacks in and return the scene object.
---@return Scene
function sceneman.scene()
    local scene = setmetatable({}, Scene)
    return scene
end

---Let this module define a new transition. The calling module must then define callbacks in and return the transition object.
---@return Transition
function sceneman.transition()
    local trans = setmetatable({}, Transition)
    return trans
end

local sceneLoad = nil
local transitionLoad = nil

local loveCallbacks = {}
for _, v in ipairs({
    "errorhandler",
    "lowmemory",
    "quit",
    "threaderror",

    "directorydropped",
    "displayrotated",
    "filedropped",
    "focus",
    "mousefocus",
    "resize",
    "visible",

    "keypressed",
    "keyreleased",
    "textedited",
    "textinput",

    "mousemoved",
    "mousepressed",
    "mousereleased",
    "wheelmoved",

    "gamepadaxis",
    "gamepadpressed",
    "gamepadreleased",
    "joystickadded",
    "joystickaxis",
    "joystickhat",
    "joystickpressed",
    "joystickreleased",
    "joystickremoved",

    "touchmoved",
    "touchpressed",
    "touchreleased",

    -- love 12 callbacks
    "localechanged",
    "dropbegan",
    "dropmoved",
    "dropcompleted",
    "audiodisconnected",

    "sensorupdated",
    "joysticksensorupdated",

    "exposed",
    "occluded",
}) do
    loveCallbacks[v] = true
end

local loveMt = false

local function defaultSetLoveCallback(callbackName, func)
    love[callbackName] = func
end

local function defaultSetLoveCallbackMt()
    -- no-op
end

---@type fun(callbackName: string, func: function)
---Function that is called when a scene wants to hook into a LOVE callback, excluding load, update and draw.
---If nil (the default), will hook it into the proper callback itself.
sceneman.setLoveCallback = nil

---@type fun(name: string, ...)|nil Call the raw LOVE callback. Only defined if sceneman.enableCallbackHook() was called
sceneman.rawCallback = nil

---@type Scene?
sceneman.currentScene = nil

---@type Transition?
sceneman.currentTransition = nil

---The string to prepend to scenePath when sceneman.loadScene is called.
sceneman.scenePrefix = ""

---The string to prepend to transitionPath when sceneman.useTransition is called
sceneman.transitionPrefix = ""

---Load a scene from a Lua script. It will be loaded at the next scene.update call.
---@param scenePath string The path to the scene script.
---@param ... any Arguments to pass to the scene.
function sceneman.switchScene(scenePath, ...)
    scenePath = sceneman.scenePrefix .. scenePath
    local scene = require(scenePath)

    sceneLoad = {
        scene = scene,
        args = {...}
    }
end

---Load a transition from a Lua script. It will be used for the next switchScene call.
---@param transitionPath string The path to the transition script.
---@param ... any Arguments to pass to the transition.
function sceneman.useTransition(transitionPath, ...)
    transitionPath = sceneman.transitionPrefix .. transitionPath
    local transition = require(transitionPath)

    transitionLoad = {
        transition = transition,
        args = {...}
    }
end

---Enable a callback-hooking plan that assigns a metatable to the LOVE global, allowing LOVE callback functions to be "intercepted" by the
---active scene's equivalenty-named callback function. The callback function may then call sceneman.loveCallback
---to call the original LOVE callback function.
function sceneman.enableCallbackHook()
    if loveMt then
        return
    end
    loveMt = true

    local rawCallbacks = {}

    for cbName, _ in pairs(loveCallbacks) do
        rawCallbacks[cbName] = love[cbName]
        love[cbName] = nil
    end

    setmetatable(love, {
        __index = function(t, k)
            if not loveCallbacks[k] then
                return rawget(t, k)
            end

            if sceneman.currentScene ~= nil and sceneman.currentScene[k] then
                return sceneman.currentScene[k]
            else
                return rawCallbacks[k]
            end
        end,

        __newindex = function(t, k, v)
            if loveCallbacks[k] then
                rawCallbacks[k] = v
            else
                rawset(t, k, v)
            end
        end
    })

    function sceneman.rawCallback(name, ...)
        local f = rawCallbacks[name]
        if f ~= nil then
            return f(...)
        end
    end
end

function sceneman.isCallbackHookEnabled()
    return loveMt
end

local function assignLoveCallbacks(scene)
    local setCallback = sceneman.setLoveCallback or (loveMt and defaultSetLoveCallbackMt or defaultSetLoveCallback)
    for k, v in pairs(scene) do
        if loveCallbacks[k] then
            setCallback(k, v)
        end
    end
end

---Update the current scene.
---@param dt number
function sceneman.update(dt)
    if sceneman.currentTransition ~= nil then
        sceneman.currentTransition.update(dt)

        if sceneman.currentTransition.done then
            local oldScene = sceneman.currentTransition.oldScene
            if oldScene ~= nil and oldScene.unload ~= nil then
                oldScene.unload()
            end

            sceneman.currentScene = sceneman.currentTransition.newScene
            sceneman.currentTransition = nil
        end
    elseif sceneLoad then
        -- load scene with transition
        if transitionLoad then
            ---@type Transition
            local inst = transitionLoad.transition
            sceneman.currentTransition = inst

            inst.done = false
            inst.oldScene = sceneman.currentScene
            inst.newScene = sceneLoad.scene
            inst.newScene.load(unpack(sceneLoad.args))
            inst.load(unpack(transitionLoad.args))

            transitionLoad = nil
            sceneLoad = nil
            sceneman.currentScene = nil
        
        -- load scene without transition
        else
            if sceneman.currentScene ~= nil and sceneman.currentScene.unload ~= nil then
                sceneman.currentScene.unload()
            end

            sceneman.currentScene = sceneLoad.scene
            assignLoveCallbacks(sceneman.currentScene)
            sceneman.currentScene.load(unpack(sceneLoad.args))

            sceneLoad = nil
        end
    end
        
    if sceneman.currentScene then
        sceneman.currentScene.update(dt)
    end
end

---Draw the current scene.
function sceneman.draw()
    if sceneman.currentTransition then
        sceneman.currentTransition.draw()
    elseif sceneman.currentScene then
        sceneman.currentScene.draw()
    end
end

return sceneman