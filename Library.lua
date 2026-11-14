local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Floats = nil,
    Overlay = nil,

    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    PreviousTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},
    KeybindMenu = nil,

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Context Menu \\--
    ContextMenus = {}, 

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Pop Out \\--
    PopOutSnapDistance = 80,
    PopOutDragThreshold = 8,
    PopOutHoldTime = 0.15,

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
    Scales = {},
    ScalesOffset = {},

    --// Mouse \\--
    OriginalMouseIconEnabled = UserInputService.MouseIconEnabled,
    ShowCursorBinding = string.sub(tostring({}), 10),

    --// Image Manager \\--
    ImageManager = CustomImageManager,

    --// Misc \\--
    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        --// Window Snapping \\--
        Snapping = false,
        SnapDistance = 28,
        SnapMargin = 8,
        SnapAvoidCoreGui = true,

        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,

        CornerRadius = 4,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Font = Enum.Font.Code,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false,
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom",
        TabButtonsStyle = {
            Gap = 0,
            Padding = 0,
            CornerRadius = 0,
            Indicator = false,
            IndicatorWidth = 2,
            IndicatorHeight = 20,
        },
    },
    Groupbox = {
        Side = 1,
        Name = "Groupbox",
        IconName = nil,
        Description = nil,
        Visible = true,
        Collapsed = false,
        DisableCollapsing = false,
        MaxHeight = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Tabbox = {
        Side = 1,
        Name = nil,
        MaxHeight = nil,
        PopOut = true,
        MaxPopOutHeight = nil,
        PopOutWidth = nil,
    },
    Settings = {
        Width = nil,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,
        AlwaysOnTop = true,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,
        KeepDisabledValuePosition = false,
        AutoWidth = false,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Resizable = true,

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}
local SideIndex = {
    left = 1,
    right = 2,
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

local function GetTextStrokeColor(): Color3
    local Color = Library.Scheme.FontColor
    return (Color.R * 0.299 + Color.G * 0.587 + Color.B * 0.114) > 0.5 and Library.Scheme.DarkColor or Library.Scheme.WhiteColor
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or
        Input.UserInputType == Enum.UserInputType.MouseButton2 or
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function IsSequentialArray(Table: { [any]: any })
    for Key in Table do
        if typeof(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then
            return false
        end
    end

    return true
end

local function IsDropdownDivider(Value: any): boolean
    return typeof(Value) == "table" and Value.DropdownDivider == true
end

function Library:DropdownDivider(Title: string?)
    return { DropdownDivider = true, Title = Title }
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end

local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

--// Fuzzy Search \\--
local function LowerText(Text: string): string
    return (Text:lower():gsub("[\195\206\208][\128-\191]", function(Char)
        local Code = utf8.codepoint(Char)
        if (Code >= 0xC0 and Code <= 0xDE and Code ~= 0xD7) or (Code >= 0x391 and Code <= 0x3AB) or (Code >= 0x410 and Code <= 0x42F) then
            return utf8.char(Code + 32)
        elseif Code >= 0x400 and Code <= 0x40F then
            return utf8.char(Code + 80)
        end

        return Char
    end))
end

local function FuzzyScore(Text: string, Search: string): (boolean, number)
    if Search == "" then
        return true, 0
    end
    if Text == "" then
        return false, 0
    end

    --// Fast path: literal substring match (also the best possible score) \\--
    local ExactIdx = Text:find(Search, 1, true)
    if ExactIdx then
        local PrevChar = ExactIdx > 1 and Text:sub(ExactIdx - 1, ExactIdx - 1) or ""
        local AtBoundary = ExactIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

        return true, 1e5 - ExactIdx + (AtBoundary and 500 or 0) + (Search:len() * 5)
    end

    --// Fallback: fuzzy, in-order, non-consecutive character matching \\--
    local TextChars, SearchChars = {}, {}
    for Char in Text:gmatch(utf8.charpattern) do table.insert(TextChars, Char) end
    for Char in Search:gmatch(utf8.charpattern) do table.insert(SearchChars, Char) end

    local TextLen, SearchLen = #TextChars, #SearchChars
    if SearchLen > TextLen then
        return false, 0
    end

    local SearchIdx = 1
    local Score = 0
    local RunLength = 0
    local LastMatchIdx = 0

    for TextIdx = 1, TextLen do
        if SearchIdx > SearchLen then
            break
        end

        if TextChars[TextIdx] == SearchChars[SearchIdx] then
            local PrevChar = TextIdx > 1 and TextChars[TextIdx - 1] or ""
            local AtBoundary = TextIdx == 1 or PrevChar:match("[%s%p_]") ~= nil

            RunLength = (LastMatchIdx == TextIdx - 1) and (RunLength + 1) or 1
            Score += 1 + (AtBoundary and 6 or 0) + math.min(RunLength - 1, 5) * 3

            LastMatchIdx = TextIdx
            SearchIdx += 1
        end
    end

    if SearchIdx <= SearchLen then
        return false, 0 --// Not every Search character was found, in order
    end

    Score -= (LastMatchIdx - SearchLen) * 0.05 --// Slightly favour tighter matches
    return true, Score
end

local function NormalizeSearch(Search: string): string
    return (Search:gsub("%s+", ""))
end

local function TryFuzzyMatch(Text: any, Search: string): (boolean, number)
    if typeof(Text) ~= "string" or Text == "" then
        return false, 0
    end

    return FuzzyScore(LowerText(Text), Search)
end

local function FuzzyMatchScore(Text: any, Search: string): number
    if typeof(Text) ~= "string" or Text == "" then
        return 0
    end

    local Normalized = NormalizeSearch(LowerText(Text))
    local Matched, Score = FuzzyScore(Normalized, Search)
    if not Matched then
        return 0
    end

    if Normalized == Search then
        Score += 1000
    end

    return Score
end

local function MatchesSearch(ElementInfo, Search: string, ForceMatch: boolean?): boolean
    if not ElementInfo then
        return false
    end
    if ForceMatch then
        return true
    end

    if TryFuzzyMatch(ElementInfo.Text, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.Tooltip, Search) then
        return true
    end
    if TryFuzzyMatch(ElementInfo.DisabledTooltip, Search) then
        return true
    end

    --// Optional: search inside Dropdown value lists, so e.g. searching a specific option name reveals the Dropdown that contains it \\--
    if typeof(ElementInfo.Values) == "table" then
        local Checked = 0
        for Key, Value in ElementInfo.Values do
            Checked += 1
            if Checked > 200 then
                break
            end

            if IsDropdownDivider(Value) then
                continue
            end

            if TryFuzzyMatch(Value, Search) or (typeof(Value) ~= "string" and TryFuzzyMatch(tostring(Value), Search)) then
                return true
            end
            if typeof(Key) == "string" and TryFuzzyMatch(Key, Search) then
                return true
            end
        end
    end

    return false
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

function Library:UpdateAddons(Parent)
    if not Parent or not Parent.Addons then
        return
    end

    for _, Addon in Parent.Addons do
        Addon:Update()
    end
end

local function CheckDepbox(Box, Search, ForceVisible: boolean?)
    local VisibleElements = 0
    local BestScore = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Base.Visible = false
            end
            if MatchesSearch(ElementInfo.SubButton, Search, ForceVisible) and ElementInfo.SubButton.Visible then
                Visible = true
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and MatchesSearch(ElementInfo, Search, ForceVisible) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
            BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        local DepVisible, DepScore = CheckDepbox(Depbox, Search, ForceVisible)
        VisibleElements += DepVisible
        if DepScore > BestScore then
            BestScore = DepScore
        end
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements, BestScore
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        RestoreDepbox(Depbox)
    end

    Box.Holder.Visible = Box.Visible
    if Box.Visible then
        Box:Resize()
    end
end

--// Pop Out
function SyncPopOutVisibility(Box: any)
    if not Box.PopOutFloat then
        return
    end

    Box.PopOutFloat.Visible = Box.BoxHolder.Visible ~= false and Box.Visible ~= false
end

local function RegisterPopOutClone(Source: Instance, Clone: Instance)
    local SourceProps = Library.Registry[Source]
    if SourceProps then
        local CloneProps = {}
        for Property, Index in SourceProps do
            if Property ~= "FontFace" then
                CloneProps[Property] = Index
            end
        end
        if next(CloneProps) then
            Library.Registry[Clone] = CloneProps
        end
    end

    local SourceChildren = Source:GetChildren()
    local CloneChildren = Clone:GetChildren()
    for Index = 1, math.min(#SourceChildren, #CloneChildren) do
        RegisterPopOutClone(SourceChildren[Index], CloneChildren[Index])
    end
end

local function DimPopOutClone(Root: GuiObject)
    for _, Descendant in Root:QueryDescendants("TextLabel, TextButton, TextBox") do
        Descendant.TextTransparency = math.max(Descendant.TextTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("ImageLabel, ImageButton") do
        Descendant.ImageTransparency = math.max(Descendant.ImageTransparency, 0.45)
    end

    for _, Descendant in Root:QueryDescendants("GuiButton") do
        Descendant.Active = false
        Descendant.AutoButtonColor = false
    end
end

local function IsScreenPointOutsideMain(Point: Vector2): boolean
    local MainFrame = Library.Window and Library.Window.MainFrame
    if not MainFrame or not Library.Toggled or not MainFrame.Visible then
        return true
    end

    return not Library:MouseIsOverFrame(MainFrame, Point)
end

local function GetTopFloatAt(Point: Vector2): GuiObject?
    local Best: GuiObject? = nil
    local BestOrder = -math.huge
    local Floats = Library.Floats

    for _, Surface in Library.DraggableElements do
        if not Surface or not Surface.Parent or not Surface.Visible then
            continue
        end
        if Floats and Surface.Parent ~= Floats then
            continue
        end
        if not Library:MouseIsOverFrame(Surface, Point) then
            continue
        end

        local SiblingIndex = tonumber(select(2, pcall(function() return Surface:GetSiblingIndex() end))) or 0
        local Order = Surface.ZIndex * 100000 + SiblingIndex
        if Order >= BestOrder then
            BestOrder = Order
            Best = Surface
        end
    end

    return Best
end

local function GetPopOutBodyMaxHeight(Box: any, Reserved: number): number
    local Float = Box.PopOutFloat
    local ScreenGui = Library.ScreenGui
    if not Float or not ScreenGui then
        return math.huge
    end

    local Gap = 12 * Library.DPIScale
    local MaxBottom = ScreenGui.AbsolutePosition.Y + ScreenGui.AbsoluteSize.Y - Gap
    local Available = math.min(MaxBottom - Float.AbsolutePosition.Y, ScreenGui.AbsoluteSize.Y * 0.9)
    local ScreenMax = math.max(0, Available / Library.DPIScale - Reserved)

    local CustomMax = Box.PopOutMaxHeight
    if typeof(CustomMax) == "number" then
        return math.min(ScreenMax, math.max(0, CustomMax))
    end

    return ScreenMax
end

--// Search
local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return false, 0
    end

    local HasVisible = false
    local BestScore = 0

    --// If the Tab itself matches Search (by name/description), don't filter out its contents -- pull everything in the Tab along with it \\--
    local TabMatches = TryFuzzyMatch(Tab.Name, Search) or TryFuzzyMatch(Tab.Description, Search)
    BestScore = math.max(BestScore, FuzzyMatchScore(Tab.Name, Search), FuzzyMatchScore(Tab.Description, Search))

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        --// Optional: matching the Groupbox's own name/description reveals every element inside it, without needing each one to match too
        local GroupboxMatches = TabMatches or (TryFuzzyMatch(Groupbox.Name, Search) or TryFuzzyMatch(Groupbox.Description, Search))
        BestScore = math.max(BestScore, FuzzyMatchScore(Groupbox.Name, Search), FuzzyMatchScore(Groupbox.Description, Search))

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                --// Check if any of the Buttons Name matches with Search
                local Visible = false
                if MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
                else
                    ElementInfo.Base.Visible = false
                end

                if MatchesSearch(ElementInfo.SubButton, Search, GroupboxMatches) and ElementInfo.SubButton.Visible then
                    Visible = true
                    BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.SubButton.Text, Search))
                else
                    ElementInfo.SubButton.Base.Visible = false
                end

                ElementInfo.Holder.Visible = Visible
                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text and MatchesSearch(ElementInfo, Search, GroupboxMatches) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
                BestScore = math.max(BestScore, FuzzyMatchScore(ElementInfo.Text, Search))
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            local DepVisible, DepScore = CheckDepbox(Depbox, Search, GroupboxMatches)
            VisibleElements += DepVisible
            if DepScore > BestScore then
                BestScore = DepScore
            end
        end

        --// Update Groupbox Size and Visibility if found any element
        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}
        local SubTabScores = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            --// Optional: matching a Tabbox sub-tab's own name reveals every element inside it, without needing each one to match too
            local SubTabMatches = TabMatches or TryFuzzyMatch(SubTab.Name, Search)
            local SubScore = FuzzyMatchScore(SubTab.Name, Search)
            BestScore = math.max(BestScore, SubScore)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    --// Check if any of the Buttons Name matches with Search
                    local Visible = false
                    if MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.Base.Visible = false
                    end

                    if MatchesSearch(ElementInfo.SubButton, Search, SubTabMatches) and ElementInfo.SubButton.Visible then
                        Visible = true
                        local ElementScore = FuzzyMatchScore(ElementInfo.SubButton.Text, Search)
                        SubScore = math.max(SubScore, ElementScore)
                        BestScore = math.max(BestScore, ElementScore)
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end

                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                --// Check if Search matches Element's Name and if Element is Visible
                if ElementInfo.Text and MatchesSearch(ElementInfo, Search, SubTabMatches) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                    local ElementScore = FuzzyMatchScore(ElementInfo.Text, Search)
                    SubScore = math.max(SubScore, ElementScore)
                    BestScore = math.max(BestScore, ElementScore)
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                local DepVisible, DepScore = CheckDepbox(Depbox, Search, SubTabMatches)
                VisibleElements[SubTab] += DepVisible
                SubScore = math.max(SubScore, DepScore)
                BestScore = math.max(BestScore, DepScore)
            end

            SubTabScores[SubTab] = SubScore
        end

        local BestSubTab = nil
        local BestSubScore = -1

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                local SubScore = SubTabScores[SubTab] or 0
                if SubScore > BestSubScore then
                    BestSubScore = SubScore
                    BestSubTab = SubTab
                end
            end
        end

        local ActiveSubTab = Tabbox.ActiveTab
        local ActiveSubVisible = ActiveSubTab and (VisibleElements[ActiveSubTab] or 0) > 0
        local ActiveSubScore = ActiveSubTab and (SubTabScores[ActiveSubTab] or -1) or -1

        if ActiveSubVisible and ActiveSubScore >= BestSubScore then
            ActiveSubTab:Resize()
        elseif BestSubTab then
            BestSubTab:Show()
        end

        --// Update Tabbox Visibility if any visible
        Tabbox.BoxHolder.Visible = VisibleTabs > 0
        SyncPopOutVisibility(Tabbox)
    end

    return HasVisible, BestScore
end

local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            RestoreDepbox(Depbox)
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
        SyncPopOutVisibility(Groupbox)
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
        SyncPopOutVisibility(Tabbox)
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToSearch = {}
    for _, Tab in Library.Tabs do
        if typeof(Tab) == "table" and not Tab.IsKeyTab and not Tab.IsCustomTab and not Tab.HasSubTabs then
            table.insert(TabsToSearch, Tab)
        end
    end

    for _, Tab in TabsToSearch do
        ResetTab(Tab)
    end

    local Search = NormalizeSearch(LowerText(SearchText))
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local BestTab = nil
    local BestScore = -1
    local ActiveScore = -1
    local ActiveHasVisible = false
    local CurrentTab = Library.ActiveTab and (Library.ActiveTab.ActiveSubTab or Library.ActiveTab)

    for _, Tab in TabsToSearch do
        local HasVisible, Score = ApplySearchToTab(Tab, Search)
        if not HasVisible then
            continue
        end

        if Tab == CurrentTab then
            ActiveHasVisible = true
            ActiveScore = Score
        end
        if Score > BestScore then
            BestScore = Score
            BestTab = Tab
        end
    end

    if not Library.GlobalSearch then
        for _, Tab in TabsToSearch do
            if Tab ~= BestTab then
                ResetTab(Tab)
            end
        end
    end

    local StayOnActive = ActiveHasVisible and ActiveScore >= BestScore
    if StayOnActive and Library.ActiveTab then
        Library.ActiveTab:RefreshSides()
    elseif BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end

            local Current = Library.ActiveTab and (Library.ActiveTab.ActiveSubTab or Library.ActiveTab)
            if Current ~= BestTab then
                BestTab:Show()
            elseif Library.ActiveTab then
                Library.ActiveTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
            Option:RefreshPool()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
    return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
    FontFace: Font?,
    Text: string?,
    Custom: boolean?,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(IconName: string): Icon?
    if not FetchIcons or not Icons then
        return nil
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    return if Success then Icon else nil
end

function Library:GetCustomIcon(IconName: string): any
    if not IconName then
        return nil
    end

    if tonumber(IconName) then
        IconName = string.format("rbxassetid://%s", tostring(IconName))
    end

    if IsCustomAssetIcon(IconName, true) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    elseif IsValidCustomIcon(IconName) then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    return nil
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Icon Instances \\--
local IconTextProperties = { ImageColor3 = "TextColor3", ImageTransparency = "TextTransparency" }
local IconSharedProperties = { "Name", "AnchorPoint", "Position", "Size", "SizeConstraint", "LayoutOrder", "ZIndex", "Visible", "Rotation", "ImageColor3", "ImageTransparency" }

local function IconProperties(ClassName: string, Properties: { [string]: any }): { [string]: any }
    if ClassName ~= "TextLabel" and ClassName ~= "TextButton" then
        return Properties
    end

    local Mapped: { [string]: any } = {}
    for Property, Value in Properties do
        Mapped[IconTextProperties[Property] or Property] = Value
    end

    return Mapped
end

local function IsFontIcon(Icon: Icon?): boolean
    return Icon ~= nil and Icon.FontFace ~= nil
end

local function ImageContent(Icon: Icon?): { [string]: any }
    return {
        Image = Icon and Icon.Url or "",
        ImageRectOffset = Icon and Icon.ImageRectOffset or Vector2.zero,
        ImageRectSize = Icon and Icon.ImageRectSize or Vector2.zero,
    }
end

local function SetIconProperties(Target: GuiObject, Properties: { [string]: any })
    FillInstance(IconProperties(Target.ClassName, Properties), Target)
end

local function TweenIcon(Target: GuiObject, Properties: { [string]: any }): Tween
    local Tween = TweenService:Create(Target, Library.TweenInfo, IconProperties(Target.ClassName, Properties))
    Tween:Play()

    return Tween
end

function Library:CreateIcon(Icon: Icon?, Properties: { [string]: any }?, IsButton: boolean?): GuiObject
    local IsFont = IsFontIcon(Icon)
    local ClassName = (if IsFont then "Text" else "Image") .. (if IsButton then "Button" else "Label")

    local Merged: { [string]: any } = {
        BackgroundTransparency = 1,
        ImageColor3 = Color3.new(1, 1, 1),
    }

    if not IsFont then
        Merged.ScaleType = Enum.ScaleType.Fit
    end

    if Properties then
        for Property, Value in Properties do
            Merged[Property] = Value
        end
    end

    return Library:ApplyIcon(New(ClassName, IconProperties(ClassName, Merged)), Icon)
end

function Library:ApplyIcon(Target: GuiObject, Icon: Icon?): GuiObject
    local IsFont = IsFontIcon(Icon)
    local IsText = Target:IsA("TextLabel") or Target:IsA("TextButton")

    if IsFont ~= IsText then
        local Theme = Library.Registry[Target] or {}
        local Properties: { [string]: any } = { Parent = Target.Parent }

        for _, Property in IconSharedProperties do
            local Source = if IsText then IconTextProperties[Property] or Property else Property
            Properties[Property] = if Theme[Source] ~= nil then Theme[Source] else (Target :: any)[Source]
        end

        local Replacement = Library:CreateIcon(Icon, Properties, Target:IsA("GuiButton"))
        Library:RemoveFromRegistry(Target)
        Target:Destroy()

        return Replacement
    end

    if IsFont and Icon then
        FillInstance({
            FontFace = Icon.FontFace,
            RichText = false,
            Text = Icon.Text,
            TextScaled = true,
        }, Target)

        if not Target:FindFirstChild("IconPadding") then
            New("UIPadding", {
                Name = "IconPadding",
                PaddingLeft = UDim.new(-0.5, -0.5),
                PaddingRight = UDim.new(-0.5, 0),
                Parent = Target,
            })
        end
    else
        FillInstance(ImageContent(Icon), Target)
    end

    return Target
end

--// DEPRECATED
function Library:ApplyLucideIcon(ImageGui: ImageLabel | ImageButton, Icon: Icon, Rotation: number?)
    warn("Obsidian:ApplyLucideIcon is deprecated, please use Obsidian:CreateIcon or Obsidian:ApplyIcon instead.")

    ImageGui.Rotation = Rotation or ImageGui.Rotation
    FillInstance(ImageContent(Icon), ImageGui)
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(Gui: ScreenGui, Enabled: boolean)
    if not Gui then
        return
    end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Gui, "OnTopOfCoreBlur", Enabled)
        elseif setscriptable then
            setscriptable(Gui, "OnTopOfCoreBlur", true)
            Gui.OnTopOfCoreBlur = Enabled
            setscriptable(Gui, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    task.defer(function()
        if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
            return
        end

        Library:RemoveFromRegistry(Instance)
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Floats and Overlays
local Floats = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 10,
    Active = false,
    Parent = ScreenGui,
})

local Overlay = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20,
    Active = false,
    Parent = ScreenGui,
})

Library.Floats = Floats
Library.Overlay = Overlay

--// Cursor
local Cursor
local CursorCross
local InnerCross = {}
local CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(1, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })

    CursorCross = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        Parent = Cursor,
    })

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -2, 0, 1),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 1,
        Parent = CursorCross,
    })
    table.insert(InnerCross, New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 1, 1, -2),
        ZIndex = 2,
        Parent = CursorCross,
    }))

    CursorCustomImage = Library:CreateIcon(nil, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 3,
        Visible = false,
        Parent = Cursor,
    })
end

local function RestoreMouseIcon()
    pcall(function() 
        RunService:UnbindFromRenderStep(Library.ShowCursorBinding)
        RunService.RenderStepped:Wait()
    end)

    UserInputService.MouseIconEnabled = Library.OriginalMouseIconEnabled
    if Cursor then Cursor.Visible = false end
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 200,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Icons \\--
local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon, PopOutIcon, CloseIcon, SettingsIcon
function Library:SetIconModule(module: IconModule)
    FetchIcons = true
    Icons = module

    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
    PopOutIcon = Library:GetIcon("square-arrow-down-left")
    CloseIcon = Library:GetIcon("x")
    SettingsIcon = Library:GetIcon("settings")
end

local OnlineFetchIcons, OnlineIcons = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/notpoiu/Molto/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
do
    if OnlineFetchIcons and OnlineIcons then
        OnlineIcons.SetProvider("lucide")
        Library:SetIconModule(OnlineIcons)
    else
        OnlineFetchIcons, OnlineIcons = pcall(function()
            return (loadstring(
                game:HttpGet("https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/refs/heads/main/source.lua")
            ) :: () -> IconModule)()
        end)
        
        if OnlineFetchIcons and OnlineIcons then
            Library:SetIconModule(OnlineIcons)
        end
    end
end

--// Lib Functions \\--
Library.Cursor = {}

function Library.Cursor:ResetCross()
    for _, Inner in InnerCross do
        Library.Registry[Inner].BackgroundColor3 = "WhiteColor"
        Inner.BackgroundColor3 = Library.Scheme.WhiteColor
    end
end

function Library.Cursor:ResetIcon()
    CursorCross.Visible = true
    CursorCustomImage.Visible = false
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
    SetIconProperties(CursorCustomImage, { ImageColor3 = Color3.new(1, 1, 1) })
end

function Library.Cursor:ResetCursor()
    Library.Cursor:ResetCross()
    Library.Cursor:ResetIcon()
end

function Library.Cursor:ChangeCrossColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    for _, Inner in InnerCross do
        Inner.BackgroundColor3 = Color
        Library.Registry[Inner].BackgroundColor3 = nil
    end
end

function Library.Cursor:ChangeIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library.Cursor:ResetIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCross.Visible = false
    CursorCustomImage = Library:ApplyIcon(CursorCustomImage, Icon)
    CursorCustomImage.Visible = true
end

function Library.Cursor:ChangeIconColor(Color: Color3)
    assert(typeof(Color) == "Color3", "Color3 expected.")
    SetIconProperties(CursorCustomImage, { ImageColor3 = Color })
end

function Library.Cursor:ChangeIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

--// DEPRECATED
function Library:ChangeCursorCrossColor(Color: Color3)
    warn("Obsidian:ChangeCursorCrossColor is deprecated, please use Obsidian.Cursor:ChangeCrossColor instead.")
    Library.Cursor:ChangeCrossColor(Color)
end

--// DEPRECATED
function Library:ResetCursorCross()
    warn("Obsidian:ResetCursorCross is deprecated, please use Obsidian.Cursor:ResetCross instead.")
    Library.Cursor:ResetCross()
end

--// DEPRECATED
function Library:ChangeCursorIcon(ImageId: string)
    warn("Obsidian:ChangeCursorIcon is deprecated, please use Obsidian.Cursor:ChangeIcon instead.")
    Library.Cursor:ChangeIcon(ImageId)
end

--// DEPRECATED
function Library:ChangeCursorIconColor(Color: Color3)
    warn("Obsidian:ChangeCursorIconColor is deprecated, please use Obsidian.Cursor:ChangeIconColor instead.")
    Library.Cursor:ChangeIconColor(Color)
end

--// DEPRECATED
function Library:ChangeCursorIconSize(Size: UDim2)
    warn("Obsidian:ChangeCursorIconSize is deprecated, please use Obsidian.Cursor:ChangeIconSize instead.")
    Library.Cursor:ChangeIconSize(Size)
end

--// DEPRECATED
function Library:ResetCursorIcon()
    warn("Obsidian:ResetCursorIcon is deprecated, please use Obsidian.Cursor:ResetIcon instead.")
    Library.Cursor:ResetIcon()
end

--// Colors \\--
function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Scale = Library.DPIScale
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size * Scale
    if Width then
        Params.Width = Width * Scale
    else
        Params.Width = workspace.CurrentCamera.ViewportSize.X - 32
    end

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return math.ceil(Bounds.X / Scale), math.ceil(Bounds.Y / Scale)
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
    local GuiSize = Frame.AbsoluteSize

    local FramePos = ParentFrame.AbsolutePosition
    local FrameSize = ParentFrame.AbsoluteSize

    return GuiPos.X >= FramePos.X
        and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
        and GuiPos.Y >= FramePos.Y
        and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize

    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize

        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end

    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6

    local CurrentX = Start.X
    local CurrentY = Start.Y

    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end

    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end

        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end

        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding

            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end

            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end

    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

--// Window Snapping \\--
local function GetCoreGuiInset(): (Vector2, Vector2)
    local Success, TopLeft, BottomRight = pcall(function()
        return GuiService:GetGuiInset()
    end)

    if Success and TopLeft and BottomRight then
        return TopLeft, BottomRight
    end

    return Vector2.zero, Vector2.zero
end

local function GetSnapEdges(ElemSize: Vector2, ViewportSize: Vector2, Margin: number, AvoidCoreGui: boolean)
    local SafeMin, SafeMax = Vector2.zero, ViewportSize

    if AvoidCoreGui then
        local TopLeftInset, BottomRightInset = GetCoreGuiInset()
        SafeMin = TopLeftInset
        SafeMax = ViewportSize - BottomRightInset
    end

    local TargetsX = {
        LeftEdge = SafeMin.X + Margin,
        Center = SafeMin.X + (SafeMax.X - SafeMin.X - ElemSize.X) / 2,
        RightEdge = SafeMax.X - ElemSize.X - Margin,
    }
    local TargetsY = {
        TopEdge = SafeMin.Y + Margin,
        Center = SafeMin.Y + (SafeMax.Y - SafeMin.Y - ElemSize.Y) / 2,
        BottomEdge = SafeMax.Y - ElemSize.Y - Margin,
    }

    return TargetsX, TargetsY
end

local function GetClosestSnapTarget(Value: number, Targets: { [string]: number }, Distance: number): (number?, string?)
    local ClosestName, ClosestValue, ClosestDist = nil, nil, Distance

    for Name, Target in Targets do
        local Dist = math.abs(Value - Target)
        if Dist <= ClosestDist then
            ClosestDist = Dist
            ClosestName = Name
            ClosestValue = Target
        end
    end

    return ClosestValue, ClosestName
end

local function GetSnapGuideOffset(Name: string, SnappedValue: number, ElemDimension: number): number
    if Name == "RightEdge" or Name == "BottomEdge" then
        return SnappedValue + ElemDimension
    elseif Name == "Center" then
        return SnappedValue + ElemDimension / 2
    end

    return SnappedValue -- LeftEdge / TopEdge
end

function Library:MakeDraggable(
    UI: GuiObject,
    DragFrame: GuiObject,
    IgnoreToggled: boolean?,
    IsMainWindow: boolean?,
    SnapConfig: { Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean? }?
)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    local SnapGuideX, SnapGuideY

    local function GetSnapGuides()
        if not SnapGuideX then
            SnapGuideX = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 2, 1, 0),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        if not SnapGuideY then
            SnapGuideY = New("Frame", {
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Visible = false,
                ZIndex = 10000,
                Parent = ScreenGui,
            })
        end

        return SnapGuideX, SnapGuideY
    end

    local function HideSnapGuides()
        if SnapGuideX then
            SnapGuideX.Visible = false
        end
        if SnapGuideY then
            SnapGuideY.Visible = false
        end
    end

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            HideSnapGuides()

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            local NewX = FramePos.X.Offset + Delta.X
            local NewY = FramePos.Y.Offset + Delta.Y

            if SnapConfig and SnapConfig.Enabled then
                local ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local Distance = SnapConfig.Distance or 28
                local Margin = SnapConfig.Margin or 8

                local AbsX = FramePos.X.Scale * ViewportSize.X + NewX
                local AbsY = FramePos.Y.Scale * ViewportSize.Y + NewY

                local ElemSize = UI.AbsoluteSize
                local TargetsX, TargetsY = GetSnapEdges(ElemSize, ViewportSize, Margin, SnapConfig.AvoidCoreGui ~= false)
                local SnappedX, SnappedXName = GetClosestSnapTarget(AbsX, TargetsX, Distance)
                local SnappedY, SnappedYName = GetClosestSnapTarget(AbsY, TargetsY, Distance)

                if SnappedX then
                    NewX = SnappedX - FramePos.X.Scale * ViewportSize.X
                end
                if SnappedY then
                    NewY = SnappedY - FramePos.Y.Scale * ViewportSize.Y
                end

                local GuideX, GuideY = GetSnapGuides()
                GuideX.Visible = SnappedX ~= nil
                if SnappedX then
                    GuideX.Position = UDim2.fromOffset(GetSnapGuideOffset(SnappedXName, SnappedX, ElemSize.X), 0)
                end

                GuideY.Visible = SnappedY ~= nil
                if SnappedY then
                    GuideY.Position = UDim2.fromOffset(0, GetSnapGuideOffset(SnappedYName, SnappedY, ElemSize.Y))
                end
            end

            UI.Position = UDim2.new(FramePos.X.Scale, NewX, FramePos.Y.Scale, NewY)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        if SnapGuideX then
            SnapGuideX:Destroy()
        end
        if SnapGuideY then
            SnapGuideY:Destroy()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        LayoutOrder = Info.LayoutOrder or 0,
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local ActiveTabTweens = setmetatable({}, { __mode = "k" })

function Library:PlayTabAnimation(Tab, Showing: boolean, OnComplete: (() -> ())?, PreviousTab: any?)
    if type(Tab) ~= "table" or not Tab.Container then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local TabContainer = Tab.Container :: Frame
    local Existing = ActiveTabTweens[TabContainer]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabContainer] = nil
    end

    local BaseZIndex = TabContainer.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabContainer.Visible = Showing
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition
        local StartingPositions = {
            Left = UDim2.fromOffset(-Offset, 0),
            Right = UDim2.fromOffset(Offset, 0),
            Top = UDim2.fromOffset(0, -Offset),
            Bottom = UDim2.fromOffset(0, Offset),
        }

        PreviousTab = PreviousTab or Library.PreviousTab
        if SwipeFrom == "auto" and PreviousTab then
            local CurrentOrder = Tab.Button.LayoutOrder
            local PreviousOrder = PreviousTab.Button.LayoutOrder
            if CurrentOrder and PreviousOrder and Tab.IsSubTab then
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Right or StartingPositions.Left
            elseif CurrentOrder and PreviousOrder then -- this may be unnecessary but oh well
                StartPosition = CurrentOrder > PreviousOrder and StartingPositions.Top or StartingPositions.Bottom -- bigger order means its under the current button
            else
                StartPosition = StartingPositions.Bottom
            end
        elseif SwipeFrom == "left" then
            StartPosition = StartingPositions.Left
        elseif SwipeFrom == "top" then
            StartPosition = StartingPositions.Top
        elseif SwipeFrom == "right" then
            StartPosition = StartingPositions.Right
        else -- bottom (Default)
            StartPosition = StartingPositions.Bottom
        end

        TabContainer.ZIndex = BaseZIndex + 1
        TabContainer.Position = StartPosition
        TabContainer.Visible = true

        local Tween = TweenService:Create(TabContainer, TweenInfo, {
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabContainer] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabContainer] == Tween then
                ActiveTabTweens[TabContainer] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabContainer.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabContainer.Visible = false
        TabContainer.Position = UDim2.fromScale(0, 0)
        TabContainer.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Pop Out \\--
function Library:MakeBoxPopOut(Box: any, Options: {
    Enabled: boolean?,
    Header: GuiObject?,
    Children: (() -> { GuiObject })?,
    Before: (() -> ())?,
    After: (() -> ())?,
    MaxPopOutHeight: number?,
    PopOutWidth: number?,
})
    Box.PoppedOut = false
    Box.PopOutEnabled = Options.Enabled ~= false
    Box.PopOutFloat = nil
    Box.PopOutPlaceholder = nil
    Box.PopOutMaxHeight = if typeof(Options.MaxPopOutHeight) == "number" then Options.MaxPopOutHeight else nil
    Box.PopOutWidth = if typeof(Options.PopOutWidth) == "number" then Options.PopOutWidth else nil

    if not Box.PopOutEnabled then
        function Box:SetPoppedOut(_Value: boolean, _SetPoppedOut: UDim2) end
        function Box:TogglePoppedOut() end
        function Box:RefreshPopOutPlaceholder() end
        function Box:SetMaxPopOutHeight(_Height: number?) end
        function Box:SetPopOutWidth(_Width: number?) end
        return
    end

    local BoxHolder = Box.BoxHolder
    local Holder = Box.Holder
    local Header = Options.Header

    local Placeholder
    local PlaceholderHeader
    local Float
    local FloatScale

    local HandledChildren: { GuiObject } = {}
    local OriginalParents: { [GuiObject]: Instance? } = {}
    local OriginalLayoutOrders: { [GuiObject]: number } = {}

    local DragState: "Idle" | "Holding" | "Dragging" = "Idle"
    local DragInput: InputObject?
    local PressMouse: Vector2?

    local DragStartPos: UDim2?
    local DragChanged: RBXScriptConnection?
    local DragDidMove = false

    --// UI Handler
    local function GetPopOutWidth(): number
        if typeof(Box.PopOutWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutWidth + 0.5))
        end

        if typeof(Box.PopOutDockedWidth) == "number" then
            return math.max(50, math.floor(Box.PopOutDockedWidth + 0.5))
        end

        local Width = Holder.AbsoluteSize.X / Library.DPIScale
        if Width < 50 then
            Width = 200
        end

        return math.max(50, math.floor(Width + 0.5))
    end

    local function ApplyPopOutWidth()
        if not (Box.PoppedOut and Float) then
            return
        end

        Float.Size = UDim2.fromOffset(GetPopOutWidth(), Float.Size.Y.Offset)
        if Box.Resize then
            Box:Resize()
        end
    end

    local function RaiseFloat()
        if not Float or not Floats then
            return
        end

        local MaxZ = Float.ZIndex
        for _, Child in Floats:GetChildren() do
            if Child:IsA("GuiObject") and Child ~= Float then
                MaxZ = math.max(MaxZ, Child.ZIndex)
            end
        end

        Float.ZIndex = MaxZ + 1
        if Float.Parent == Floats then
            Float.Parent = Overlay
        end
        Float.Parent = Floats
    end

    local function CreatePlaceholder()
        local Frame = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            BackgroundTransparency = 0.12,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = BoxHolder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = Frame,
            })
        )
        Library:AddOutline(Frame)

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Frame
        RegisterPopOutClone(Header, PlaceholderHeader)
        DimPopOutClone(PlaceholderHeader)

        if PopOutIcon then
            local PlaceholderDockIcon = Library:CreateIcon(PopOutIcon, {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "WhiteColor",
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                ZIndex = PlaceholderHeader.ZIndex + 1,
                Parent = Frame,
            }, true)
            PlaceholderDockIcon.MouseButton1Click:Connect(function()
                Box:SetPoppedOut(false)
            end)
        end

        return Frame
    end

    function Box:RefreshPopOutPlaceholder()
        if not Box.PoppedOut or not Placeholder or not Header then
            return
        end

        if PlaceholderHeader then
            PlaceholderHeader:Destroy()
            PlaceholderHeader = nil
        end

        PlaceholderHeader = Header:Clone()
        PlaceholderHeader.Parent = Placeholder
        RegisterPopOutClone(Header, PlaceholderHeader)
        DimPopOutClone(PlaceholderHeader)
    end

    function Box:SetPoppedOut(Value: boolean, FloatPosition: UDim2?)
        if not Box.PopOutEnabled or Box.Destroyed then
            return
        end

        Value = Value == true
        if Box.PoppedOut == Value then
            if Value and FloatPosition and Float then
                Float.Position = FloatPosition
            end
            return
        end

        if Value then
            if Options.Before then
                Options.Before()
            end

            local BoxChildren = if Options.Children then Options.Children() else { Holder }
            HandledChildren = {}

            table.clear(OriginalParents)
            table.clear(OriginalLayoutOrders)

            for _, Child in BoxChildren do
                if not Child or not Child.Parent then
                    continue
                end

                table.insert(HandledChildren, Child)
                OriginalParents[Child] = Child.Parent
                OriginalLayoutOrders[Child] = Child.LayoutOrder
            end

            if #HandledChildren == 0 then
                return
            end

            local DockedWidth = Holder.AbsoluteSize.X / Library.DPIScale
            if DockedWidth < 50 then
                DockedWidth = 200
            end
            Box.PopOutDockedWidth = math.max(50, math.floor(DockedWidth + 0.5))

            local Width = GetPopOutWidth()

            local AbsolutePosition = Holder.AbsolutePosition
            Placeholder = CreatePlaceholder()
            Box.PopOutPlaceholder = Placeholder

            Float = New("Frame", {
                Active = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Position = FloatPosition or UDim2.fromOffset(
                    AbsolutePosition.X / Library.DPIScale,
                    AbsolutePosition.Y / Library.DPIScale
                ),
                Size = UDim2.fromOffset(Width, 0),
                ZIndex = 1,
                Parent = Floats,
            })
            FloatScale = New("UIScale", {
                Parent = Float,
            })
            table.insert(Library.Scales, FloatScale)
            FloatScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[FloatScale]) or 0)

            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = Float,
            })

            for _, Child in HandledChildren do
                Child.Parent = Float
            end

            if not table.find(Library.DraggableElements, Float) then
                table.insert(Library.DraggableElements, Float)
            end

            Box.PopOutFloat = Float
            Box.PoppedOut = true
            SyncPopOutVisibility(Box)
            RaiseFloat()

            Float:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                Box:Resize()
            end)

            if Options.After then
                Options.After()
            end

            return
        end

        if Float then
            local DraggableIndex = table.find(Library.DraggableElements, Float)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end
        end

        if FloatScale then
            local ScaleIndex = table.find(Library.Scales, FloatScale)
            if ScaleIndex then
                table.remove(Library.Scales, ScaleIndex)
            end

            FloatScale = nil
        end

        for _, Child in HandledChildren do
            if not Child or not Child.Parent then
                continue
            end

            Child.Parent = OriginalParents[Child] or BoxHolder
            Child.LayoutOrder = OriginalLayoutOrders[Child] or 0
        end

        if Placeholder then
            Placeholder:Destroy()
            Placeholder = nil
        end
        
        PlaceholderHeader = nil

        if Float then
            Float:Destroy()
            Float = nil
        end

        Box.PopOutFloat = nil
        Box.PopOutPlaceholder = nil
        Box.PopOutDockedWidth = nil
        Box.PoppedOut = false

        table.clear(HandledChildren)
        table.clear(OriginalParents)
        table.clear(OriginalLayoutOrders)

        if Options.After then
            Options.After()
        end
    end

    function Box:TogglePoppedOut()
        Box:SetPoppedOut(not Box.PoppedOut)
    end

    function Box:SetMaxPopOutHeight(Height: number?)
        if Height ~= nil then
            assert(typeof(Height) == "number", "Height must be a number or nil")
            assert(Height >= 0, "Height must be higher than 0")
        end

        Box.PopOutMaxHeight = Height
        if Box.PoppedOut and Box.Resize then
            Box:Resize()
        end
    end

    function Box:SetPopOutWidth(Width: number?)
        if Width ~= nil then
            assert(typeof(Width) == "number", "Width must be a number or nil")
            assert(Width >= 0, "Width must be higher than 0")
        end

        Box.PopOutWidth = Width
        ApplyPopOutWidth()
    end

    --// Drag Handler
    local function StopDrag()
        if DragState == "Idle" then
            return
        end

        local WasDragging = DragState == "Dragging"
        local DidMove = DragDidMove
        DragState = "Idle"
        DragInput = nil
        PressMouse = nil
        DragStartPos = nil
        DragDidMove = false

        if DragChanged and DragChanged.Connected then
            DragChanged:Disconnect()
            DragChanged = nil
        end

        if not WasDragging or not Box.PoppedOut or not Float then
            return
        end

        local FloatCenter = Float.AbsolutePosition + (Float.AbsoluteSize * 0.5)
        local NearPlaceholder = false
        if Library.Toggled and Placeholder and Placeholder.Parent then
            local PlaceholderCenter = Placeholder.AbsolutePosition + (Placeholder.AbsoluteSize * 0.5)
            NearPlaceholder = (FloatCenter - PlaceholderCenter).Magnitude <= Library.PopOutSnapDistance
        end

        if NearPlaceholder or (DidMove and not IsScreenPointOutsideMain(FloatCenter)) then
            Box:SetPoppedOut(false)
        end
    end

    local function BeginDrag(Input: InputObject)
        if DragState ~= "Idle" or Box.Destroyed or not (ScreenGui and ScreenGui.Parent) then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)
        local Top = GetTopFloatAt(Point)
        if Box.PoppedOut then
            if not Float or Top ~= Float then
                return
            end
        elseif Top ~= nil and not Header:IsDescendantOf(Top) then
            return
        end

        DragState = "Holding"
        DragInput = Input
        PressMouse = Vector2.new(Input.Position.X, Input.Position.Y)
        DragStartPos = nil
        DragDidMove = false

        if Box.PoppedOut and Float then
            RaiseFloat()
        end

        DragChanged = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                StopDrag()
            end
        end)

        task.delay(Library.PopOutHoldTime, function()
            if (DragState :: any) ~= "Holding" or DragInput ~= Input then
                return
            end

            DragState = "Dragging"
            if Box.PoppedOut and Float then
                RaiseFloat()
                DragStartPos = Float.Position
            end
        end)
    end

    local function UpdateDrag(Input: InputObject)
        if DragState ~= "Dragging" or not PressMouse then
            return
        end
        if not (ScreenGui and ScreenGui.Parent) then
            StopDrag()
            return
        end

        local MousePosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Delta = MousePosition - PressMouse

        if not Box.PoppedOut then
            if Delta.Magnitude < Library.PopOutDragThreshold then
                return
            end

            Box:SetPoppedOut(true)
            if not Float then
                return
            end

            RaiseFloat()
            DragStartPos = Float.Position
            DragDidMove = true
        elseif Delta.Magnitude >= Library.PopOutDragThreshold then
            DragDidMove = true
        end

        if Float and DragStartPos then
            Float.Position = UDim2.new(
                DragStartPos.X.Scale,
                DragStartPos.X.Offset + Delta.X,
                DragStartPos.Y.Scale,
                DragStartPos.Y.Offset + Delta.Y
            )
        end
    end

    local function BindDragSource(Gui: GuiObject)
        Library:GiveSignal(Gui.InputBegan:Connect(function(Input: InputObject)
            if IsClickInput(Input) then
                BeginDrag(Input)
            end
        end))
    end

    BindDragSource(Header)
    for _, Descendant in Header:QueryDescendants("GuiObject:not(ImageButton)") do
        BindDragSource(Descendant)
    end

    Library:GiveSignal(Header.DescendantAdded:Connect(function(Descendant)
        if Descendant:IsA("GuiObject") and not Descendant:IsA("ImageButton") then
            BindDragSource(Descendant)
        end
    end))

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if IsHoverInput(Input) then
            UpdateDrag(Input)
        end
    end))
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 1,
        Parent = Floats,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = if IconImage then Library:ApplyIcon(IconImage, CustomIcon) else Library:CreateIcon(CustomIcon, {
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 2,
                Parent = Label,
            })
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local PressPosition
    Button.InputBegan:Connect(function(Input: InputObject)
        if IsMouseInput(Input) then
            PressPosition = Button.AbsolutePosition
        end
    end)
    Button.Activated:Connect(function()
        if PressPosition and (Button.AbsolutePosition - PressPosition).Magnitude > 10 then
            return
        end

        Library:SafeCallback(Func, DraggableButton)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    if not ExcludeDragging then
        Library:MakeDraggable(Button, Button, true)
    end
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 1,
        Parent = Floats,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local DividerLine = Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    local LabelPadding = New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container, Label, DividerLine, LabelPadding
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 1,
        Parent = Floats,
    })

    local IconImage = Library:CreateIcon(nil, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 2,
        Parent = Button,
    })

    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local PressPosition
    Button.InputBegan:Connect(function(Input: InputObject)
        if IsMouseInput(Input) then
            PressPosition = Button.AbsolutePosition
        end
    end)
    Button.Activated:Connect(function()
        if PressPosition and (Button.AbsolutePosition - PressPosition).Magnitude > 10 then
            return
        end

        Library:SafeCallback(Func, DraggableImageButton)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon

        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        IconImage = Library:ApplyIcon(IconImage, CustomIcon)
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    if not ExcludeDragging then
        Library:MakeDraggable(Button, Button, true)
    end
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu

local function CloseMenus(Until: any?, ShouldClose: ((Menu: any) -> boolean)?)
    local Closed = {}

    while CurrentMenu and CurrentMenu ~= Until and not Closed[CurrentMenu] do
        local Menu = CurrentMenu
        if ShouldClose and not ShouldClose(Menu) then
            break
        end

        Closed[Menu] = true
        Menu:Close()
    end
end

function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    IgnoreCornerRadius: boolean?,
    SpecificCornersOnly: ("top" | "bottom" | "no_left" | "no_top_left")?, -- stupid way of doing this
    AnimationType: ("Dropdown" | "KeyPicker" | "none")?
)
    local Menu
    local HolderGui = Holder:FindFirstAncestorOfClass("ScreenGui")
    local ParentGui = Overlay
    if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
        ParentGui = HolderGui
    end

    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = 1,
            Parent = ParentGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Menu,
    })

    local Corner;
    if IgnoreCornerRadius ~= true then
        if SpecificCornersOnly == "top" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "bottom" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        elseif SpecificCornersOnly == "no_top_left" then
            Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.SpecificCorners, Corner)
        else
            Corner = New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Menu,
            }); table.insert(Library.Corners, Corner)
        end
    end

    local Table = {
        Connections = {},
        Destroyed = false,

        Active = false,
        ActiveCallback = ActiveCallback,

        Holder = Holder,
        Menu = Menu,
        Corner = Corner,

        List = nil,
        Signal = nil,

        Size = Size,
        AutoSizeY = List == 1,

        OpenCloseTween = nil,
        Animated = function()
            if not AnimationType or AnimationType == "none" then
                return false
            end

            if not (Library.Animations and Library.Animations[AnimationType] == true) then
                return false
            end

            return true, Library[string.format("%sTransitionInfo", AnimationType)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if List == 1 then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    function Table:Open()
        if CurrentMenu == Table then
            return
        end

        local NestedParent = nil
        local Check = CurrentMenu
        while Check do
            if Holder:IsDescendantOf(Check.Menu) then
                NestedParent = Check
                break
            end
            Check = Check.ParentMenu
        end

        CloseMenus(NestedParent)

        Table.ParentMenu = NestedParent
        CurrentMenu = Table
        Table.Active = true
        Menu.ZIndex = NestedParent and NestedParent.Menu.ZIndex + 1 or 1

        local TargetParent = if ParentGui == Overlay then Overlay else ParentGui
        Menu.Parent = nil
        Menu.Parent = TargetParent

        if typeof(Offset) == "function" then
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset()[2])
            )
        else
            Menu.Position = UDim2.fromOffset(
                math.floor(Holder.AbsolutePosition.X + Offset[1]),
                math.floor(Holder.AbsolutePosition.Y + Offset[2])
            )
        end

        local TargetSize = typeof(Table.Size) == "function" and Table.Size() or Table.Size

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, true)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            local OpenSize = TargetSize
            if Table.AutoSizeY then
                local FullHeight = Menu.AbsoluteSize.Y

                Menu.AutomaticSize = Enum.AutomaticSize.None
                OpenSize = UDim2.new(TargetSize.X.Scale, TargetSize.X.Offset, 0, FullHeight)
            end

            Menu.Size = UDim2.new(OpenSize.X.Scale, OpenSize.X.Offset, 0, 0)
            Menu.Visible = true

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = OpenSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Size = TargetSize
            Menu.Visible = true
        end

        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            if typeof(Offset) == "function" then
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset()[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset()[2])
                )
            else
                Menu.Position = UDim2.fromOffset(
                    math.floor(Holder.AbsolutePosition.X + Offset[1]),
                    math.floor(Holder.AbsolutePosition.Y + Offset[2])
                )
            end

            local HolderAllowed = Table.ParentMenu ~= nil or Library:IsInsideFrame(Library.WindowContainer, Holder)
            if not HolderAllowed then
                for _, Surface in Library.DraggableElements do
                    if not (Surface and Library:IsInsideFrame(Surface, Holder)) then
                        continue
                    end

                    HolderAllowed = true
                    break
                end
            end

            if not HolderAllowed and Table.Active then
                Table:Close()
            end
        end)
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end

        Table.Active = false
        CurrentMenu = Table.ParentMenu
        Table.ParentMenu = nil

        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local IsAnimated, TweenInfo = Table.Animated()
        if IsAnimated == true then
            if Table.AutoSizeY then
                Menu.AutomaticSize = Enum.AutomaticSize.None
            end

            local CurrentSize = Menu.Size
            local CollapsedSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset, 0, 0)

            local Tween = TweenService:Create(Menu, TweenInfo, { Size = CollapsedSize })
            Table.OpenCloseTween = Tween

            local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function(PlaybackState)
                if Connection then
                    Connection:Disconnect()
                end

                if Table.OpenCloseTween == Tween then
                    StopTween(Table.OpenCloseTween, true)
                    Table.OpenCloseTween = nil

                    Menu.Visible = false
                    if Table.AutoSizeY then
                        Menu.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            Tween:Play()
        else
            Menu.Visible = false
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    function Table:Destroy()
        Table.Destroyed = true

        if Table.Connections then
            for _, Connection in Table.Connections do
                Connection:Disconnect()
            end
        end

        if Table.Active then
            CloseMenus(Table)
            Table:Close()
        end

        if Table.OpenCloseTween then
            StopTween(Table.OpenCloseTween, true)
            Table.OpenCloseTween = nil
        end

        local MenuIndex = table.find(Library.ContextMenus, Table)
        if MenuIndex then
            table.remove(Library.ContextMenus, MenuIndex)
        end

        if Menu then
            Menu:Destroy()
        end
    end

    table.insert(Library.ContextMenus, Table)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        CloseMenus(nil, function(Menu)
            return not (Library:MouseIsOverFrame(Menu.Menu, Location) or Library:MouseIsOverFrame(Menu.Holder, Location))
        end)
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 30,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)

local TooltipMeasureId = 0
local LastTooltipText = ""
local LastTooltipMaxWidth = 0

local function UpdateTooltipSize(Force: boolean?)
    if Library.Unloaded or not TooltipLabel.Visible then
        return
    end

    local MaxWidth = math.max(
        40,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    if
        not Force
        and TooltipLabel.Text == LastTooltipText
        and math.abs(MaxWidth - LastTooltipMaxWidth) < 1
        and TooltipLabel.Size.X.Offset > 0
    then
        return
    end

    TooltipMeasureId += 1
    local MeasureId = TooltipMeasureId
    local Text = TooltipLabel.Text

    local X, Y = Library:GetTextBounds(Text, TooltipLabel.FontFace, TooltipLabel.TextSize, MaxWidth)
    if MeasureId ~= TooltipMeasureId or TooltipLabel.Text ~= Text then
        return
    end

    LastTooltipText = Text
    LastTooltipMaxWidth = MaxWidth
    TooltipLabel.Size = UDim2.fromOffset(X + 8, Y + 4)
end

TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    UpdateTooltipSize(false)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and not HoverInstance:IsDescendantOf(CurrentMenu.Menu) and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local HolderGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if HolderGui and HolderGui ~= ScreenGui and Library.ActiveLoading and HolderGui == Library.ActiveLoading.ScreenGui then
            TooltipLabel.Parent = HolderGui
        else
            TooltipLabel.Parent = ScreenGui
        end

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Position = UDim2.fromOffset(
            Mouse.X + (Library.ShowCustomCursor and 8 or 14),
            Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
        )
        TooltipLabel.Visible = true
        UpdateTooltipSize(true)

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and not HoverInstance:IsDescendantOf(CurrentMenu.Menu) and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + (Library.ShowCustomCursor and 8 or 14),
                Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local BaseAddons, BaseGroupbox = {}, {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            NoUI = Info.NoUI == true,
            MenuVisible = Info.NoUI ~= true,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
            Idx = Idx,
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local LastDisplayText = nil
        local MaxPickerWidth = 85
        local SlidingLabel

        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local SlideForwardConn, SlideBackConn
        local CancelSlidingTweens = function()
            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                StopTween(SlideBackTween, true)
                SlideBackTween = nil
            end

            RunService.RenderStepped:Wait()
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(21, 21),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            TextTransparency = 0.4,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        local PickerHoverTween = nil

        local function ApplyPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)
            PickerHoverTween = nil

            Picker.TextTransparency = Transparency
            if SlidingLabel then
                SlidingLabel.TextTransparency = Transparency
            end
        end

        local function TweenPickerTextTransparency(Transparency: number)
            StopTween(PickerHoverTween)

            PickerHoverTween = TweenService:Create(Picker, Library.TweenInfo, {
                TextTransparency = Transparency,
            })
            PickerHoverTween:Play()

            if SlidingLabel then
                TweenService:Create(SlidingLabel, Library.TweenInfo, {
                    TextTransparency = Transparency,
                }):Play()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenPickerTextTransparency(0.4)
        end))

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                Parent = Holder,
            })

            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Fill,
                Parent = ToggleLabel,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Holder,
                })
            )
            local ButtonStroke = New("UIStroke", {
                Color = "OutlineColor",
                Enabled = false,
                Parent = Holder,
            })
            local ButtonPadding = New("UIPadding", {
                Parent = Holder,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = Library:CreateIcon(CheckIcon, {
                ImageColor3 = "FontColor",
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })

            function KeybindsToggle:Display(State)
                if KeyPicker.Mode == "Press" then
                    Label.TextTransparency = 0.4
                    SetIconProperties(CheckImage, { ImageTransparency = 1 })
                    return
                end

                Label.TextTransparency = State and 0 or 0.5
                SetIconProperties(CheckImage, { ImageTransparency = State and 0 or 1 })
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                local IsPress = KeyPicker.Mode == "Press"
                Holder.Active = not Normal or IsPress
                Checkbox.Visible = not Normal
                ButtonStroke.Enabled = IsPress
                Holder.BackgroundTransparency = IsPress and 0 or 1
                Holder.AutomaticSize = IsPress and Enum.AutomaticSize.X or Enum.AutomaticSize.None
                Holder.Size = IsPress and UDim2.fromOffset(0, 20) or UDim2.new(1, 0, 0, 16)
                ButtonPadding.PaddingLeft = UDim.new(0, IsPress and 8 or 0)
                ButtonPadding.PaddingRight = UDim.new(0, IsPress and 8 or 0)

                Label.AutomaticSize = Enum.AutomaticSize.X
                Label.Size = UDim2.fromScale(0, 1)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Position = (not IsPress and not Normal) and UDim2.fromOffset(22, 0) or UDim2.fromOffset(0, 0)
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            table.insert(KeyPicker.Connections, Holder.MouseButton1Click:Connect(function()
                if KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                    return
                end

                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end))
            table.insert(KeyPicker.Connections, Holder.MouseEnter:Connect(function()
                if KeyPicker.Mode == "Press" and not ParentObj.Disabled then
                    Label.TextTransparency = 0
                end
            end))
            table.insert(KeyPicker.Connections, Holder.MouseLeave:Connect(function()
                if KeyPicker.Mode == "Press" then
                    Label.TextTransparency = 0.4
                end
            end))

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local ModeCorners = {}
        local TotalModeButtons = GetTableSize(Info.Modes) + 1
        local MenuCornersOnly = if TotalModeButtons == 1 then "no_left" else "no_top_left"

        local MenuTable
        MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            PickerCorner.TopLeftRadius = Half
            PickerCorner.BottomLeftRadius = Half
            PickerCorner.TopRightRadius = Active and Zero or Half
            PickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = MenuTable and MenuTable.Corner
            if MenuCorner then
                if MenuCornersOnly == "no_left" then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.BottomLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                else
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end

            for _, Entry in ModeCorners do
                local Corner = Entry.Corner
                if Entry.Style == "single" then
                    Corner.TopLeftRadius = Zero
                    Corner.BottomLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomRightRadius = Half
                elseif Entry.Style == "first" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Half
                    Corner.BottomLeftRadius = Zero
                    Corner.BottomRightRadius = Zero
                elseif Entry.Style == "last" then
                    Corner.TopLeftRadius = Zero
                    Corner.TopRightRadius = Zero
                    Corner.BottomLeftRadius = Half
                    Corner.BottomRightRadius = Half
                end
            end
        end, false, MenuCornersOnly, "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            if Index == 1 and TotalModeButtons == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "single" })
            elseif Index == 1 then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "first" })
            elseif Index == TotalModeButtons then
                local Corner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
                table.insert(Library.SpecificCorners, Corner)
                table.insert(ModeCorners, { Corner = Corner, Style = "last" })
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            table.insert(KeyPicker.Connections, Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end))

            table.insert(KeyPicker.Connections, Button.MouseEnter:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, Button.MouseLeave:Connect(function()
                if KeyPicker.Mode == Mode then
                    return
                end

                TweenService:Create(Button, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        do
            local RemoveButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                LayoutOrder = TotalModeButtons,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or 19),
                Text = "Remove",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RemoveButton,
            })
            table.insert(Library.SpecificCorners, Corner)
            table.insert(ModeCorners, { Corner = Corner, Style = "last" })

            table.insert(KeyPicker.Connections, RemoveButton.MouseButton1Click:Connect(function()
                MenuTable:Close()
                KeyPicker:SetValue({ "None", KeyPicker.Mode, {} })
            end))

            table.insert(KeyPicker.Connections, RemoveButton.MouseEnter:Connect(function()
                TweenService:Create(RemoveButton, Library.TweenInfo, {
                    BackgroundTransparency = 0.7,
                    TextTransparency = 0.1,
                }):Play()
            end))

            table.insert(KeyPicker.Connections, RemoveButton.MouseLeave:Connect(function()
                TweenService:Create(RemoveButton, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                    TextTransparency = 0.5,
                }):Play()
            end))
        end

        local SetPickingState = function(State, SkipUpdate: boolean?)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                LastDisplayText = nil
                RunService.RenderStepped:Wait()
            end

            if SkipUpdate ~= true then
                (KeyPicker :: any):Update()
            end
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                local OffsetScale = X + 9
                local TextChanged = LastDisplayText ~= DisplayText
                local LabelWidth

                SlidingLabel.Text = DisplayText
                LastDisplayText = DisplayText

                if Picking then
                    Picker.Size = UDim2.new(1, 0, 1, 0)
                    RunService.RenderStepped:Wait()
                    LabelWidth = Picker.AbsoluteSize.X

                    if LabelWidth <= 0 then
                        LabelWidth = MaxPickerWidth
                    end
                else
                    LabelWidth = math.min(OffsetScale, MaxPickerWidth)
                    Picker.Size = UDim2.new(0, LabelWidth, 1, 0)
                end

                if OffsetScale > LabelWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)

                    local OverflowDistance = OffsetScale - LabelWidth - 4.5
                    if OverflowDistance > 0 then
                        if TextChanged or not SlideForwardTween then
                            SlidingLabel.Position = UDim2.fromOffset(4.5, 0)
                            CancelSlidingTweens()

                            local Duration = math.max(OverflowDistance / 25, 0.35)
                            local TweenInfo = TweenInfo.new(
                                Duration,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.InOut
                            )

                            SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(-OverflowDistance, 0),
                            })

                            SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                                Position = UDim2.fromOffset(4.5, 0),
                            })

                            SlideForwardTween:Play()

                            if SlideForwardConn then
                                SlideForwardConn:Disconnect()
                            end

                            if SlideBackConn then
                                SlideBackConn:Disconnect()
                            end

                            SlideForwardConn = SlideForwardTween.Completed:Connect(HandleForwardTween)
                            SlideBackConn = SlideBackTween.Completed:Connect(HandleBackTween)
                        end
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X / Library.DPIScale
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset(X + 9, 21)
            end
        end

        function KeyPicker:Update()
            local Disabled = ParentObj.Disabled == true

            if Disabled and Picking then
                SetPickingState(false, true)
            end

            KeyPicker:Display()

            Picker.Active = not Disabled
            ApplyPickerTextTransparency(Disabled and 0.8 or 0.4)

            if Disabled then
                if MenuTable.Active then
                    MenuTable:Close()
                end
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
                State = KeyPicker:GetState()
            end

            if Info.NoUI then
                return
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(KeyPicker.MenuVisible ~= false)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking or ParentObj.Disabled then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
            end

            if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if ParentObj.Disabled then
                return
            end

            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeyPicker.Text = Text
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()

            local KeybindMenu = Library.KeybindMenu
            if KeybindMenu and KeybindMenu.SettingsOpen then
                KeybindMenu:RefreshSettings()
            end
        end

        function KeyPicker:SetMenuVisibility(Visible: boolean)
            assert(typeof(Visible) == "boolean", "Visible must be a boolean")

            KeyPicker.MenuVisible = Visible
            KeyPicker:Update()

            local KeybindMenu = Library.KeybindMenu
            if KeybindMenu and KeybindMenu.SettingsOpen then
                KeybindMenu:RefreshSettings()
            end
        end

        table.insert(KeyPicker.Connections, Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking or ParentObj.Disabled then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 21)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end))

        table.insert(KeyPicker.Connections, Picker.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            MenuTable:Toggle()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                ParentObj.Disabled
                or KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if HoldingKey then
                if KeyPicker.Mode == "Toggle" then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Press" then
                    KeyPicker:DoClick()
                elseif KeyPicker.Mode == "Hold" then
                    InputChanged = Input.Changed:Connect(function()
                        if KeyPicker:GetState() then
                            return
                        end

                        KeyPicker:Update()
                        if InputChanged and InputChanged.Connected then
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end

                KeyPicker:Update()
            end
        end))

        KeyPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, KeyPicker)

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if SlideForwardConn then
                SlideForwardConn:Disconnect()
                SlideForwardConn = nil
            end

            if SlideBackConn then
                SlideBackConn:Disconnect()
                SlideBackConn = nil
            end

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then
                    SlideForwardTween:Destroy()
                end

                if SlideBackTween then
                    SlideBackTween:Destroy()
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil

            local KeybindMenu = Library.KeybindMenu
            if KeybindMenu and KeybindMenu.SettingsOpen then
                KeybindMenu:RefreshSettings()
            end
        end

        Options[Idx] = KeyPicker

        local KeybindMenu = Library.KeybindMenu
        if KeybindMenu and KeybindMenu.SettingsOpen then
            KeybindMenu:RefreshSettings()
        end

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.ColorPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Connections = {},
            Destroyed = false,

            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            Size = UDim2.fromOffset(21, 21),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderStroke = New("UIStroke", {
            Color = Library:GetDarkerColor(ColorPicker.Value),
            Parent = Holder,
        })

        local ColorPickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Holder,
        }); table.insert(Library.SpecificCorners, ColorPickerCorner)

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HolderTransparency,
            })
        )

        --// Color Menu \\--
        local MapSize = Library.IsMobile and 140 or 200
        local BarWidth = 16
        local MenuWidth = MapSize + BarWidth + 6 + 12
        if Info.Transparency then
            MenuWidth += BarWidth + 6
        end

        local ColorMenu
        local FooterCorner
        ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(MenuWidth, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1, function(Active: boolean)
                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                ColorPickerCorner.TopLeftRadius = Half
                ColorPickerCorner.TopRightRadius = Half
                ColorPickerCorner.BottomRightRadius = Active and Zero or Half
                ColorPickerCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = ColorMenu and ColorMenu.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Half
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end

                if FooterCorner then
                    FooterCorner.TopLeftRadius = Zero
                    FooterCorner.TopRightRadius = Zero
                    FooterCorner.BottomLeftRadius = Half
                    FooterCorner.BottomRightRadius = Half
                end
            end, false, "no_top_left")
        ColorMenu.List.Padding = UDim.new(0, 0)
        ColorPicker.ColorMenu = ColorMenu

        --// Content Holder \\--
        local ContentHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = ContentHolder,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ContentHolder,
        })

        --// Footer \\--
        local FooterHeight = Library.IsMobile and 30 or 22

        local FooterBackground = New("Frame", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Size = UDim2.new(1, 0, 0, FooterHeight),
            Parent = ColorMenu.Menu,
        })
        FooterCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = FooterBackground,
        })
        table.insert(Library.SpecificCorners, FooterCorner)
        Library:MakeLine(FooterBackground, {
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local FooterBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = FooterBackground,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, Info.Resizable and (FooterHeight + 4) or 6),
            Parent = FooterBar,
        })

        local FooterInfoLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = FooterBar,
        })

        local function RefreshFooterInfo()
            FooterInfoLabel.Text = string.format(
                "#%s • %d, %d, %d",
                ColorPicker.Value:ToHex(),
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255)
            )
        end
        RefreshFooterInfo()

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ContentHolder,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, MapSize),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(MapSize, MapSize),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(BarWidth, MapSize),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(BarWidth, MapSize),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        --// Resizing \\--
        local ResizeGrabber
        if Info.Resizable then
            local BaseMapSize = 200
            local BaseBarWidth = BarWidth
            local BasePadding = 6
            local MinMapSize = 140

            ColorPicker.MapWidth = MapSize
            ColorPicker.MapHeight = MapSize

            local function GetBarWidth(MapWidth)
                return math.clamp(math.floor((MapWidth / BaseMapSize) * BaseBarWidth + 0.5), 12, 24)
            end

            local function GetContentWidth(MapWidth)
                local CurrentBarWidth = GetBarWidth(MapWidth)
                local Width = MapWidth + CurrentBarWidth + BasePadding
                if Info.Transparency then
                    Width += (CurrentBarWidth + BasePadding)
                end

                return Width + 12
            end

            local FixedVerticalOverhead = 6 + 6 + 8 + 20 + 8 + 20 + FooterHeight
            if typeof(ColorPicker.Title) == "string" then
                FixedVerticalOverhead += 8 + 8
            end

            local function ClampToViewport(NewWidth, NewHeight)
                local Camera = workspace.CurrentCamera
                if not Camera then
                    return NewWidth, NewHeight
                end

                local ViewportSize = Camera.ViewportSize
                local ScreenMargin = 12

                local MaxWidth = ViewportSize.X - ColorMenu.Menu.AbsolutePosition.X - ScreenMargin
                local MaxHeight = ViewportSize.Y - ColorMenu.Menu.AbsolutePosition.Y - ScreenMargin - FixedVerticalOverhead

                while NewWidth > MinMapSize and GetContentWidth(NewWidth) > MaxWidth do
                    NewWidth -= 4
                end

                if NewHeight > MaxHeight then
                    NewHeight = math.max(MinMapSize, math.floor(MaxHeight))
                end

                return NewWidth, NewHeight
            end

            local function UpdateColorMenuSize(NewWidth, NewHeight)
                NewWidth = math.max(MinMapSize, math.floor(NewWidth + 0.5))
                NewHeight = math.max(MinMapSize, math.floor(NewHeight + 0.5))
                NewWidth, NewHeight = ClampToViewport(NewWidth, NewHeight)

                if NewWidth == ColorPicker.MapWidth and NewHeight == ColorPicker.MapHeight then
                    return
                end

                local CurrentBarWidth = GetBarWidth(NewWidth)
                local CursorSize = math.clamp(math.floor((math.min(NewWidth, NewHeight) / BaseMapSize) * 6 + 0.5), 4, 10)

                ColorHolder.Size = UDim2.new(1, 0, 0, NewHeight)
                SatVipMap.Size = UDim2.fromOffset(NewWidth, NewHeight)
                SatVibCursor.Size = UDim2.fromOffset(CursorSize, CursorSize)
                HueSelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)

                if TransparencySelector then
                    TransparencySelector.Size = UDim2.new(0, CurrentBarWidth, 0, NewHeight)
                end

                ColorPicker.MapWidth = NewWidth
                ColorPicker.MapHeight = NewHeight
                ColorMenu:SetSize(UDim2.new(0, GetContentWidth(NewWidth), 0, 0))
            end

            ResizeGrabber = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = FooterBackground,
            })
            Library:CreateIcon(ResizeIcon, {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = ResizeGrabber,
            })

            table.insert(ColorPicker.Connections, ResizeGrabber.InputBegan:Connect(function(Input: InputObject)
                Library.CantDragForced = true
                local StartMouse = Vector2.new(Mouse.X, Mouse.Y)
                local StartWidth = ColorPicker.MapWidth
                local StartHeight = ColorPicker.MapHeight

                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Delta = Vector2.new(Mouse.X, Mouse.Y) - StartMouse
                    UpdateColorMenuSize(StartWidth + Delta.X, StartHeight + Delta.Y)

                    RunService.RenderStepped:Wait()
                end

                Library.CantDragForced = false
            end))
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local HueBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = HueBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = HueBox,
            })
        )

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = RgbBox,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = RgbBox,
            })
        )

        --// Context Menu \\--
        local ContextMenu
        ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            ColorPickerCorner.TopLeftRadius = Half
            ColorPickerCorner.BottomLeftRadius = Half
            ColorPickerCorner.TopRightRadius = Active and Zero or Half
            ColorPickerCorner.BottomRightRadius = Active and Zero or Half

            local MenuCorner = ContextMenu and ContextMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end
        end, false, "no_top_left")
        ColorPicker.ContextMenu = ContextMenu
        ContextMenu.List.Padding = UDim.new(0, 6)
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                table.insert(ColorPicker.Connections, Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end))

                table.insert(ColorPicker.Connections, Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 0.7,
                    }):Play()
                end))

                table.insert(ColorPicker.Connections, Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()
                end))
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if not Library.CopiedColor then
                    return
                end

                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)

                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// Copy/Paste Buttons \\--
        local ActionHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ContentHolder,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = ActionHolder,
        })

        local CopyColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = CopyColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = CopyColorButton,
            })
        )

        local PasteColorButton = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ActionHolder,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = PasteColorButton,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = PasteColorButton,
            })
        )

        local CopyColorOriginalText = CopyColorButton.Text
        local PasteColorOriginalText = PasteColorButton.Text
        local CopyColorResetId = 0
        local PasteColorResetId = 0

        table.insert(ColorPicker.Connections, CopyColorButton.MouseEnter:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseLeave:Connect(function()
            TweenService:Create(CopyColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseEnter:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10),
            }):Play()
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseLeave:Connect(function()
            TweenService:Create(PasteColorButton, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.MainColor,
            }):Play()
        end))

        table.insert(ColorPicker.Connections, CopyColorButton.MouseButton1Click:Connect(function()
            Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }

            CopyColorResetId += 1
            local ThisResetId = CopyColorResetId
            CopyColorButton.Text = "Copied color"

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= CopyColorResetId then
                    return
                end

                CopyColorButton.Text = CopyColorOriginalText
            end)
        end))

        table.insert(ColorPicker.Connections, PasteColorButton.MouseButton1Click:Connect(function()
            PasteColorResetId += 1
            local ThisResetId = PasteColorResetId

            if not Library.CopiedColor then
                PasteColorButton.Text = "Nothing to paste"
            else
                ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                PasteColorButton.Text = "Pasted color"
            end

            task.delay(1, function()
                if ColorPicker.Destroyed or ThisResetId ~= PasteColorResetId then
                    return
                end

                PasteColorButton.Text = PasteColorOriginalText
            end)
        end))

        --// End \\--
        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")

            RefreshFooterInfo()
        end

        local function ApplyHolderVisual(Disabled: boolean)
            Holder.Active = not Disabled
            HolderStroke.Transparency = Disabled and 0.5 or 0
            Holder.BackgroundTransparency = Disabled and 0.5 or 0

            if Disabled then
                Holder.BackgroundColor3 = ColorPicker.Value:Lerp(Library.Scheme.BackgroundColor, 0.5)
                HolderTransparency.ImageTransparency = math.clamp((1 - ColorPicker.Transparency) + 0.5, 0, 1)
            else
                Holder.BackgroundColor3 = ColorPicker.Value
                HolderStroke.Color = Library:GetDarkerColor(ColorPicker.Value)
                HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)
            end
        end

        function ColorPicker:RunChanged()
            if ParentObj.Disabled then
                return
            end

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            local Disabled = ParentObj.Disabled == true
            ApplyHolderVisual(Disabled)

            if Disabled then
                if ColorMenu.Active then
                    ColorMenu:Close()
                end

                if ContextMenu.Active then
                    ContextMenu:Close()
                end
            end

            ColorPicker:RunChanged()
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Info.Transparency and Transparency or 0
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        table.insert(ColorPicker.Connections, Holder.MouseButton1Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ColorMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, Holder.MouseButton2Click:Connect(function()
            if ParentObj.Disabled then
                return
            end

            ContextMenu:Toggle()
        end))

        table.insert(ColorPicker.Connections, SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(ColorPicker.Connections, HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and not ColorPicker.Destroyed do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end))

        if TransparencySelector then
            table.insert(ColorPicker.Connections, TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and not ColorPicker.Destroyed do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(ColorPicker.Connections, HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end))

        table.insert(ColorPicker.Connections, RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end))

        for _, BoxPair in {
            { HueBox, HueBoxStroke },
            { RgbBox, RgbBoxStroke }
        } do
            local TextBoxInstance, Stroke = BoxPair[1], BoxPair[2]

            table.insert(ColorPicker.Connections, TextBoxInstance.Focused:Connect(function()
                Library.Registry[Stroke].Color = "AccentColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(ColorPicker.Connections, TextBoxInstance.FocusLost:Connect(function()
                Library.Registry[Stroke].Color = "OutlineColor"
                TweenService:Create(Stroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        ColorPicker:Update()

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, ColorPicker)

        ColorPicker.Default = ColorPicker.Value

        function ColorPicker:Destroy()
            ColorPicker.Destroyed = true

            if ColorPicker.Connections then
                for _, Connection in ColorPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if ColorMenu then
                ColorMenu:Destroy()
            end

            if ResizeGrabber then
                ResizeGrabber:Destroy()
            end

            if ContextMenu then
                ContextMenu:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, ColorPicker)

                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = ColorPicker

        return self
    end

    function Funcs:AddSettings(Info)
        if self.Destroyed then return nil end

        local ParentObj = self
        if ParentObj.Settings and not ParentObj.Settings.Destroyed then
            return ParentObj.Settings
        end

        Info = Library:Validate(Info, Templates.Settings)

        local Settings = {
            Connections = {},
            Destroyed = false,

            Elements = {},
            DependencyBoxes = {},

            Width = Info.Width,

            Type = "Settings",
            Parent = ParentObj,
        }

        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"
        local IsForContainer = ParentObj.Type == "Input" or ParentObj.Type == "Dropdown"
        local ParentContainer = IsForContainer and ParentObj.Container or nil

        local Gear = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = "",
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Gear,
        })

        local GearCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Gear,
        }); table.insert(Library.SpecificCorners, GearCorner)

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3),
            PaddingTop = UDim.new(0, 3),
            Parent = Gear,
        })

        local Icon = Library:CreateIcon(SettingsIcon, {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Size = UDim2.fromScale(1, 1),
            Parent = Gear,
        })

        if IsForButton then
            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.None,
                Parent = Gear,
            })

            Gear.LayoutOrder = ParentObj.Base.LayoutOrder + 1
            Gear.Size = UDim2.new(0, 21, 1, 0)
            Gear.Parent = ParentObj.Base.Parent
        elseif IsForContainer then
            local Height = ParentContainer.Size.Y.Offset
            ParentContainer.Size = UDim2.new(1, -(Height + 6), 0, Height)

            Gear.AnchorPoint = Vector2.new(1, 1)
            Gear.Position = UDim2.fromScale(1, 1)
            Gear.Size = UDim2.fromOffset(Height, Height)
            Gear.Parent = ParentObj.Holder
        else
            Gear.Size = UDim2.fromOffset(21, 21)
            Gear.Parent = ParentObj.TextLabel
        end

        local function GetMenuSize()
            if typeof(Settings.Width) == "number" then
                return UDim2.fromOffset(Settings.Width, 0)
            end

            if not Library.WindowContainer then
                return UDim2.fromOffset(200, 0)
            end

            local Width = (Library.WindowContainer.AbsoluteSize.X / Library.DPIScale - 12) / 2 - 7
            return UDim2.fromOffset(math.floor(Width), 0)
        end

        local SettingsMenu; SettingsMenu = Library:AddContextMenu(Gear, GetMenuSize, function()
            return { 0.5, Gear.AbsoluteSize.Y + 1.5 }
        end, 1, function(Active: boolean)
            local Half = UDim.new(0, Library.CornerRadius / 2)
            local Zero = UDim.new(0, 0)

            GearCorner.TopLeftRadius = Half
            GearCorner.TopRightRadius = Half
            GearCorner.BottomRightRadius = Active and Zero or Half
            GearCorner.BottomLeftRadius = Active and Zero or Half

            local MenuCorner = SettingsMenu and SettingsMenu.Corner
            if MenuCorner then
                MenuCorner.TopLeftRadius = Zero
                MenuCorner.TopRightRadius = Half
                MenuCorner.BottomRightRadius = Half
                MenuCorner.BottomLeftRadius = Half
            end

            if ParentObj.Disabled then
                return
            end

            SetIconProperties(Icon, { ImageTransparency = Active and 0 or 0.5 })
        end, false, "no_top_left")
        Settings.Menu = SettingsMenu

        local Container = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = SettingsMenu.Menu,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = Container,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 7),
            PaddingLeft = UDim.new(0, 7),
            PaddingRight = UDim.new(0, 7),
            PaddingTop = UDim.new(0, 7),
            Parent = Container,
        })

        Settings.Holder = Container
        Settings.Container = Container
        Settings.Gear = Gear

        function Settings:Resize() end

        function Settings:SetWidth(Width: number?)
            if Width ~= nil then
                assert(typeof(Width) == "number", "Width must be a number or nil")
                assert(Width >= 0, "Width must be higher than 0")
            end

            Settings.Width = Width
            SettingsMenu:SetSize(GetMenuSize)
        end

        function Settings:Open()
            if ParentObj.Disabled then
                return
            end

            SettingsMenu:Open()
        end

        function Settings:Close()
            if not SettingsMenu.Active then
                return
            end

            CloseMenus(SettingsMenu)

            SettingsMenu:Close()
        end

        function Settings:Toggle()
            if SettingsMenu.Active then
                Settings:Close()
            else
                Settings:Open()
            end
        end

        function Settings:Update()
            local Disabled = ParentObj.Disabled == true

            Gear.Active = not Disabled
            Gear.BackgroundColor3 = Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Gear].BackgroundColor3 = Disabled and "BackgroundColor" or "MainColor"
            SetIconProperties(Icon, { ImageTransparency = Disabled and 0.8 or (SettingsMenu.Active and 0 or 0.5) })

            if Disabled then
                Settings:Close()
            end
        end

        table.insert(Settings.Connections, Gear.MouseButton1Click:Connect(function()
            Settings:Toggle()
        end))

        table.insert(Settings.Connections, Gear.MouseEnter:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenIcon(Icon, { ImageTransparency = 0 })
        end))

        table.insert(Settings.Connections, Gear.MouseLeave:Connect(function()
            if ParentObj.Disabled then
                return
            end

            TweenIcon(Icon, { ImageTransparency = SettingsMenu.Active and 0 or 0.5 })
        end))

        setmetatable(Settings, BaseGroupbox)

        function Settings:Destroy()
            Settings.Destroyed = true

            for _, Connection in Settings.Connections do
                Connection:Disconnect()
            end

            for Index = #Settings.Elements, 1, -1 do
                local Element = Settings.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end

            for Index = #Settings.DependencyBoxes, 1, -1 do
                local SubDepbox = Settings.DependencyBoxes[Index]
                if SubDepbox and SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            SettingsMenu:Destroy()

            if ParentContainer and ParentContainer.Parent then
                ParentContainer.Size = UDim2.new(1, 0, 0, ParentContainer.Size.Y.Offset)
            end

            if Gear then
                Gear:Destroy()
            end

            if ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, Settings)
                if AddonIdx then
                    table.remove(ParentObj.Addons, AddonIdx)
                end
            end

            if ParentObj.Settings == Settings then
                ParentObj.Settings = nil
            end
        end

        if not ParentObj.Addons then
            ParentObj.Addons = {}
        end

        table.insert(ParentObj.Addons, Settings)
        ParentObj.Settings = Settings

        Settings:Update()

        return Settings
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X / Library.DPIScale)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",

            Parent = Groupbox,
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",

            Parent = Groupbox,
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X / Library.DPIScale
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            table.insert(Label.Connections, TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end))
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then
                TextLabel:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)

                if LblIdx then
                    table.remove(Labels, LblIdx)
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick
                Info.Icon = Params.Icon or Params.IconName

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false
                Info.Icon = nil

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,
            Icon = Info.Icon,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Locked = false,

            Base = nil,
            Stroke = nil,
            Content = nil,
            Label = nil,
            IconImage = nil,

            Addons = {},

            Tween = nil,
            Type = "Button",

            Parent = Groupbox,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 6),
            Parent = Holder,
        })

        local function ApplyButtonIcon(Button, IconName)
            local Content = Button.Content
            if not Content then
                return
            end

            local ParsedIcon = Library:GetCustomIcon(IconName)
            if ParsedIcon then
                Button.IconImage = if Button.IconImage then Library:ApplyIcon(Button.IconImage, ParsedIcon) else Library:CreateIcon(ParsedIcon, {
                    LayoutOrder = 0,
                    Size = UDim2.fromOffset(14, 14),
                    Parent = Content,
                })

                Button.IconImage.Visible = true
                SetIconProperties(Button.IconImage, {
                    ImageColor3 = if Button.Risky then "RedColor" elseif ParsedIcon.Custom then "WhiteColor" else "FontColor",
                    ImageTransparency = Button.Disabled and 0.8 or 0.4,
                })
            elseif Button.IconImage then
                Button.IconImage.Visible = false
            end
        end

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                LayoutOrder = Button.Type == "SubButton" and 2 or 0,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            local Content = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(0, 16),
                Parent = Base,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 6),
                Parent = Content,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Content,
            })

            Button.Content = Content
            Button.Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 16),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = Button.Disabled and 0.8 or 0.4,
                Visible = Button.Text ~= "",
                Parent = Content,
            })

            if Button.Risky then
                Button.Label.TextColor3 = Library.Scheme.RedColor
                Library.Registry[Button.Label].TextColor3 = "RedColor"
            end

            ApplyButtonIcon(Button, Button.Icon)

            return Base, Stroke
        end

        local function InitEvents(Button)
            table.insert(Button.Connections, Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenIcon(Button.IconImage, { ImageTransparency = 0 })
                end
            end))
            table.insert(Button.Connections, Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Label, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()

                if Button.IconImage and Button.IconImage.Visible then
                    TweenIcon(Button.IconImage, { ImageTransparency = 0.4 })
                end
            end))

            table.insert(Button.Connections, Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    local IconWasVisible = false
                    if Button.IconImage then
                        IconWasVisible = Button.IconImage.Visible
                        Button.IconImage.Visible = false
                    end

                    Button.Label.Text = "Are you sure?"
                    Button.Label.Visible = true
                    Button.Label.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Label].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Label.Text = Button.Text
                    Button.Label.Visible = Button.Text ~= ""
                    Button.Label.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Label].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Button.IconImage then
                        Button.IconImage.Visible = IconWasVisible
                    end

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait()
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end))
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,
                Icon = Info.Icon,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,
                Locked = false,

                Base = nil,
                Stroke = nil,
                Content = nil,
                Label = nil,
                IconImage = nil,

                Addons = {},

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
                SubButton.Label.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                if SubButton.IconImage and SubButton.IconImage.Visible then
                    SetIconProperties(SubButton.IconImage, { ImageTransparency = SubButton.Disabled and 0.8 or 0.4 })
                end

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
                Library:UpdateAddons(SubButton)
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Label.Text = Text
                SubButton.Label.Visible = Text ~= ""
            end

            function SubButton:SetIcon(Icon: string?)
                SubButton.Icon = Icon
                ApplyButtonIcon(SubButton, Icon)
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker
            SubButton.AddSettings = BaseAddons.__index.AddSettings

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.Connections then
                    for _, Connection in SubButton.Connections do
                        Connection:Disconnect()
                    end
                end

                if SubButton.Addons then
                    for Index = #SubButton.Addons, 1, -1 do
                        local Addon = table.remove(SubButton.Addons, Index)
                        if Addon and Addon.Destroy then
                            Addon:Destroy()
                        end
                    end
                end

                if SubButton.TooltipTable then
                    SubButton.TooltipTable:Destroy()
                end

                if SubButton.Tween then
                    SubButton.Tween:Destroy()
                end

                if SubButton.Base then
                    SubButton.Base:Destroy()
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)

                    if BIdx then
                        table.remove(Buttons, BIdx)
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Button.Label.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            if Button.IconImage and Button.IconImage.Visible then
                SetIconProperties(Button.IconImage, { ImageTransparency = Button.Disabled and 0.8 or 0.4 })
            end

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
            Library:UpdateAddons(Button)
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Label.Text = Text
            Button.Label.Visible = Text ~= ""
        end

        function Button:SetIcon(Icon: string?)
            Button.Icon = Icon
            ApplyButtonIcon(Button, Icon)
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker
        Button.AddSettings = BaseAddons.__index.AddSettings

        function Button:Destroy()
            Button.Destroyed = true

            if Button.Connections then
                for _, Connection in Button.Connections do
                    Connection:Disconnect()
                end
            end

            if Button.Addons then
                for Index = #Button.Addons, 1, -1 do
                    local Addon = table.remove(Button.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if Button.TooltipTable then
                Button.TooltipTable:Destroy()
            end

            if Button.Tween then
                Button.Tween:Destroy()
            end

            if Button.SubButton then
                Button.SubButton:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)

                if BIdx then
                    table.remove(Buttons, BIdx)
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = Library:CreateIcon(CheckIcon, {
            ImageColor3 = "FontColor",
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                SetIconProperties(CheckImage, { ImageTransparency = Toggle.Value and 0.8 or 1 })

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenIcon(CheckImage, { ImageTransparency = Toggle.Value and 0 or 1 })

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",

            Parent = Groupbox,
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -38, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            if Toggle.Disabled then
                return
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            if not Toggle.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            Library:UpdateAddons(Toggle)

            Button.Active = not Toggle.Disabled
            Toggle:Display()

            Library:UpdateDependencyBoxes()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then
                Toggle.TooltipTable:Destroy()
            end

            if Button then
                Button:Destroy()
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},

            Holder = nil,
            Label = nil,
            Container = nil,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local BoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
            BoxStroke.Transparency = Input.Disabled and 0.5 or 0

            Box.BackgroundColor3 = Input.Disabled and Library.Scheme.BackgroundColor or Library.Scheme.MainColor
            Library.Registry[Box].BackgroundColor3 = Input.Disabled and "BackgroundColor" or "MainColor"
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            if Input.Disabled then
                return
            end

            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            Input:RunChanged()
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()

            Library:UpdateAddons(Input)
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end

                Input:SetValue(Box.Text)
            end))
        end

        table.insert(Input.Connections, Box.Focused:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "AccentColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        table.insert(Input.Connections, Box.FocusLost:Connect(function()
            if Input.Disabled then
                return
            end

            Library.Registry[BoxStroke].Color = "OutlineColor"
            TweenService:Create(BoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        Input.Label = Label
        Input.Container = Box

        Input.AddSettings = BaseAddons.__index.AddSettings
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end

        Input:UpdateColors()
        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.Addons then
                for Index = #Input.Addons, 1, -1 do
                    local Addon = table.remove(Input.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if Input.TooltipTable then
                Input.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 15 or 33),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            ZIndex = Bar.ZIndex + 2,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = GetTextStrokeColor,
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        local InputTextBox
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 14,
                ZIndex = Bar.ZIndex + 3,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = Bar,
            })
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = GetTextStrokeColor,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Bar,
            })
        )

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Fill,
            })
        )

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")

            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")

            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            if Slider.Disabled then
                return
            end

            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local LastValidText = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = InputTextBox.Text
                local AsNum = tonumber(Text)

                if #tostring(Text) > 0 and not AsNum and Text ~= "-" then
                    InputTextBox.Text = LastValidText
                else
                    if Slider.Rounding == 0 and Text:find("%.") then
                        InputTextBox.Text = LastValidText
                        return
                    end

                    local DecimalPos = Text:find("%.")
                    if DecimalPos and Slider.Rounding > 0 then
                        local Decimals = #Text - DecimalPos
                        if Decimals > Slider.Rounding then
                            InputTextBox.Text = LastValidText
                            return
                        end
                    end

                    LastValidText = Text
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local Num = tonumber(InputTextBox.Text)
                if not Num then
                    return
                end

                Num = Round(Num, Slider.Rounding)
                Slider:SetValue(Num)
            end))
        end

        local LastTap = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(Input: InputObject)
            local ValidInput = IsClickInput(Input) or Input.UserInputType == Enum.UserInputType.MouseButton2
            if not ValidInput or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local IsRightClick = Input.UserInputType == Enum.UserInputType.MouseButton2
                local IsDoubleTap = false

                if Library.IsMobile and Input.UserInputType == Enum.UserInputType.Touch then
                    if tick() - LastTap < 0.3 then
                        IsDoubleTap = true
                    end

                    LastTap = tick()
                end

                if IsRightClick or IsDoubleTap then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(Input) then
                return
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = false
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            while IsDragInput(Input) and not Slider.Destroyed do
                local Location = Mouse.X
                local Scale = math.clamp((Location - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local OldValue = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * Scale), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= OldValue then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            if Library.ActiveTab then
                for _, Side in Library.ActiveTab.Sides do
                    Side.ScrollingEnabled = true
                end
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end
        end))

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, Connection in Slider.Connections do
                    Connection:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Slider)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Dropdown)
        Info.FormatDisplayValue = Info.FormatDisplayValue or Info.FormatValue
        Info.FormatListValue = Info.FormatListValue or Info.FormatValue

        local Groupbox = self
        local Container = Groupbox.Container

        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end

        local Dropdown = {
            Connections = {},
            Destroyed = false,

            Text = typeof(Info.Text) == "string" and Info.Text or nil,

            Value = Info.Multi and {} or nil,
            Values = Info.Values,
            DisabledValues = Info.DisabledValues,
            ValueImages = Info.ValueImages,

            Multi = Info.Multi,
            DragSelect = Info.Multi and not Library.IsMobile and Info.DragSelect == true,
            KeepDisabledValuePosition = Info.KeepDisabledValuePosition == true,

            SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            EnablePlayerImages = Info.EnablePlayerImages,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},

            Holder = nil,
            Label = nil,
            Container = nil,

            Type = "Dropdown",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 21),
            Visible = Dropdown.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Dropdown.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not Info.Text,
            ZIndex = 3,
            Parent = Holder,
        })

        local DisplayContainer = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 4),
            Parent = DisplayContainer,
        })

        local DisplayStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = DisplayContainer,
        })

        local DropdownCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = DisplayContainer,
        }); table.insert(Library.SpecificCorners, DropdownCorner)

        local DisplayImage = Library:CreateIcon(nil, {
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local DisplayButton = New("TextButton", {
            Active = not Dropdown.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = DisplayContainer,
        })

        local ArrowImage = Library:CreateIcon(ArrowIcon, {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = DisplayContainer,
        })

        local SearchBox
        if Info.Searchable then
            SearchBox = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = DisplayButton,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SearchBox,
            })

            table.insert(Dropdown.Connections, SearchBox.Focused:Connect(function()
                Library.Registry[DisplayStroke].Color = "AccentColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end))

            table.insert(Dropdown.Connections, SearchBox.FocusLost:Connect(function()
                Library.Registry[DisplayStroke].Color = "OutlineColor"
                TweenService:Create(DisplayStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end))
        end

        local GetValueImage = function(Value, RawValue)
            if not Value then
                return nil
            end

            local ValueImage = nil
            if Dropdown.SpecialType == "Player" and Dropdown.EnablePlayerImages == true then
                local PlayerValue = Value
                if typeof(PlayerValue) ~= "Instance" and RawValue ~= nil then
                    PlayerValue = RawValue
                end

                if typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") then
                    ValueImage = { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(PlayerValue.UserId)) }
                end
            end

            if Dropdown.ValueImages then
                local IconRef = Dropdown.ValueImages[Value]
                if IconRef == nil and RawValue ~= nil then
                    IconRef = Dropdown.ValueImages[RawValue]
                end

                if IconRef then
                    ValueImage = Library:GetCustomIcon(IconRef)
                end
            end

            return ValueImage
        end

        local MenuTable
        MenuTable = Library:AddContextMenu(
            DisplayContainer,
            function()
                return UDim2.fromOffset((DisplayContainer.AbsoluteSize.X / Library.DPIScale), 0)
            end,
            function()
                return { 0.5, DisplayContainer.AbsoluteSize.Y + 1.5 }
            end,
            2,
            function(Active: boolean)
                DisplayButton.TextTransparency = (Active and SearchBox) and 1 or 0

                SetIconProperties(ArrowImage, { ImageTransparency = Active and 0 or 0.5, Rotation = Active and 180 or 0 })

                if SearchBox then
                    SearchBox.Text = ""
                    SearchBox.Visible = Active
                end

                local Half = UDim.new(0, Library.CornerRadius / 2)
                local Zero = UDim.new(0, 0)

                DropdownCorner.TopLeftRadius = Half
                DropdownCorner.TopRightRadius = Half
                DropdownCorner.BottomRightRadius = Active and Zero or Half
                DropdownCorner.BottomLeftRadius = Active and Zero or Half

                local MenuCorner = MenuTable and MenuTable.Corner
                if MenuCorner then
                    MenuCorner.TopLeftRadius = Zero
                    MenuCorner.TopRightRadius = Zero
                    MenuCorner.BottomRightRadius = Half
                    MenuCorner.BottomLeftRadius = Half
                end
            end,
            false,
            "bottom",
            "Dropdown"
        )
        Dropdown.Menu = MenuTable

        local ItemHeight = 21
        local PoolSize = math.max(1, Info.MaxVisibleDropdownItems + 2)
        local Pool = {}
        local FilteredEntries = {}
        local TextWidths = {}

        local function GetListWidth()
            local Width = DisplayContainer.AbsoluteSize.X / Library.DPIScale
            if not Info.AutoWidth then
                return Width
            end

            for _, Entry in FilteredEntries do
                local TextWidth = TextWidths[Entry.FormattedValue]
                if not TextWidth then
                    TextWidth = Library:GetTextBounds(Entry.FormattedValue, Library.Scheme.Font, 14)
                    TextWidths[Entry.FormattedValue] = TextWidth
                end

                local Extra = 16
                if Entry.ValueImage then
                    Extra += 18
                end

                if Entry.IsDivider and Entry.Title then
                    Extra += 40
                end

                Width = math.max(Width, TextWidth + Extra)
            end

            return math.ceil(Width)
        end

        function Dropdown:RecalculateListSize(Count)
            local ItemCount = Count or #FilteredEntries
            local Y = math.clamp(ItemCount * ItemHeight, 0, Info.MaxVisibleDropdownItems * ItemHeight)

            MenuTable.Menu.CanvasSize = UDim2.fromOffset(0, ItemCount * ItemHeight)

            MenuTable:SetSize(function()
                return UDim2.fromOffset(GetListWidth(), Y)
            end)
        end

        function Dropdown:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Dropdown.Disabled and 0.8 or 0
            DisplayButton.TextTransparency = Dropdown.Disabled and 0.8 or 0
            SetIconProperties(DisplayImage, { ImageTransparency = Dropdown.Disabled and 0.8 or 0 })
            SetIconProperties(ArrowImage, { ImageTransparency = Dropdown.Disabled and 0.8 or MenuTable.Active and 0 or 0.5 })
        end

        function Dropdown:Display()
            if Library.Unloaded then
                return
            end

            local Str = ""
            local ValueImage = nil
            local IsDictionary = not IsSequentialArray(Dropdown.Values)

            if Info.Multi then
                for Key, RawValue in Dropdown.Values do
                    local Value = IsDictionary and Key or RawValue

                    if not IsDropdownDivider(RawValue) and Dropdown.Value[Value] then
                        if not ValueImage then
                            ValueImage = GetValueImage(Value, RawValue)
                        end

                        Str = Str
                            .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(RawValue)) or tostring(RawValue))
                            .. ", "
                    end
                end

                Str = Str:sub(1, #Str - 2)
            else
                local DisplayValue = Dropdown.Value
                if IsDictionary and Dropdown.Value ~= nil then
                    DisplayValue = Dropdown.Values[Dropdown.Value]
                end

                ValueImage = GetValueImage(Dropdown.Value, DisplayValue)
                Str = DisplayValue and tostring(DisplayValue) or ""

                if Str ~= "" and Info.FormatDisplayValue then
                    Str = tostring(Info.FormatDisplayValue(Str))
                end
            end

            local PlainStr = Str:gsub("<[^>]*>", "")
            if utf8.len(PlainStr) and utf8.len(PlainStr) > 25 then
                Str = PlainStr:sub(1, utf8.offset(PlainStr, 23) - 1) .. "..."
            end

            DisplayButton.Text = (Str == "" and "---" or Str)

            DisplayImage = Library:ApplyIcon(DisplayImage, ValueImage)
            SetIconProperties(DisplayImage, { ImageTransparency = if ValueImage then 0 else 1 })

            DisplayButton.Size = ValueImage and UDim2.new(1, -8, 0, 21) or UDim2.new(1, 0, 0, 21)
            DisplayButton.Position = ValueImage and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func
        end

        function Dropdown:GetActiveValues(ReturnCount)
            local Table = {}

            if Info.Multi then
                for Value, _ in Dropdown.Value do
                    table.insert(Table, Value)
                end
            else
                if Dropdown.Value then
                    table.insert(Table, Dropdown.Value)
                end
            end

            return ReturnCount == true and GetTableSize(Table) or Table
        end

        local DragSelecting = false
        local DragStartIndex = nil
        local DragPrevMin = nil
        local DragPrevMax = nil
        local DragLastIndex = nil
        local DragInitialValues = {}
        local DragInputEndedConn = nil
        local DragInputChangedConn = nil

        local function RecomputeFilteredEntries()
            local Values = Dropdown.Values
            local DisabledValues = Dropdown.DisabledValues
            local IsDictionary = not IsSequentialArray(Values)

            --// Fuzzy-match dropdown values the same way the sidebar search
            --// does, so e.g. "clr" can find "Clear Inventory" in a list \\--
            local SearchQuery = SearchBox and NormalizeSearch(LowerText(SearchBox.Text)) or ""
            local IsSearching = SearchQuery ~= ""

            local Keys = {}
            for Key in Values do
                table.insert(Keys, Key)
            end

            if not IsDictionary then
                table.sort(Keys)
            end

            local Groups = { { Items = {} } }
            local Count = 0

            for _, Key in Keys do
                local RawValue = Values[Key]

                if IsDropdownDivider(RawValue) then
                    if not IsDictionary then
                        local Title = RawValue.Title and tostring(RawValue.Title) or nil

                        table.insert(Groups, {
                            Divider = {
                                IsDivider = true,
                                Title = Title,
                                FormattedValue = Title or "",
                            },
                            Items = {},
                        })
                    end

                    continue
                end

                local Value = IsDictionary and Key or RawValue

                local FormattedValue = tostring(Info.FormatListValue and Info.FormatListValue(RawValue) or RawValue)

                local MatchScore = 0
                if IsSearching then
                    local Matched, Score = FuzzyScore(LowerText((FormattedValue:gsub("<[^>]*>", ""))), SearchQuery)
                    if not Matched then
                        continue
                    end
                    MatchScore = Score
                end

                local IsDisabled = table.find(DisabledValues, Value) ~= nil
                    or (RawValue ~= nil and RawValue ~= Value and table.find(DisabledValues, RawValue) ~= nil)

                local Entry = {
                    Value = Value,
                    RawValue = RawValue,
                    FormattedValue = FormattedValue,
                    IsDisabled = IsDisabled,
                    ValueImage = GetValueImage(Value, RawValue),
                    MatchScore = MatchScore,
                    Order = Count + 1,
                }

                Count += 1
                table.insert(Groups[#Groups].Items, Entry)
            end

            table.clear(FilteredEntries)

            for _, Group in Groups do
                local Items = Group.Items
                if IsSearching then
                    if #Items == 0 then
                        continue
                    end

                    --// Best matches first; ties fall back to original order \\--
                    table.sort(Items, function(A, B)
                        if A.MatchScore ~= B.MatchScore then
                            return A.MatchScore > B.MatchScore
                        end
                        return A.Order < B.Order
                    end)
                end

                if Group.Divider then
                    table.insert(FilteredEntries, Group.Divider)
                end

                if Dropdown.KeepDisabledValuePosition then
                    for _, Entry in Items do
                        table.insert(FilteredEntries, Entry)
                    end

                    continue
                end

                for _, Entry in Items do
                    if not Entry.IsDisabled then
                        table.insert(FilteredEntries, Entry)
                    end
                end

                for _, Entry in Items do
                    if Entry.IsDisabled then
                        table.insert(FilteredEntries, Entry)
                    end
                end
            end
        end

        local function GetFirstVisibleIndex()
            local Total = #FilteredEntries
            if Total <= PoolSize then
                return 1
            end

            local MaxFirst = Total - PoolSize + 1
            local ScrollY = MenuTable.Menu.CanvasPosition.Y / Library.DPIScale
            local Index = math.floor(ScrollY / ItemHeight) + 1
            return math.clamp(Index, 1, MaxFirst)
        end

        function Dropdown:RefreshPool()
            local Total = #FilteredEntries
            local First = GetFirstVisibleIndex()

            for SlotIndex, Row in Pool do
                local DataIndex = First + SlotIndex - 1
                local Entry = FilteredEntries[DataIndex]

                Row.Entry = Entry
                Row.Index = Entry and DataIndex or nil

                if not Entry then
                    Row.Container.Visible = false
                    continue
                end

                Row.Container.Visible = true
                Row.Container.Position = UDim2.fromOffset(0, (DataIndex - 1) * ItemHeight)

                local IsLast = DataIndex == Total
                Row.Corner.BottomRightRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                Row.Corner.BottomLeftRadius = IsLast and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)

                Row.Button.Text = Entry.FormattedValue
                Row.Button.TextXAlignment = Entry.IsDivider and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
                Row.LeftLine.Visible = Entry.IsDivider == true
                Row.RightLine.Visible = Entry.IsDivider == true and Entry.Title ~= nil

                if Entry.IsDivider then
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight - 1)
                    Row.Button.Position = UDim2.fromOffset(0, 0)

                    if Entry.Title then
                        local TitleWidth = Library:GetTextBounds(Entry.Title, Library.Scheme.Font, 14)
                        local HalfWidth = TitleWidth // 2 + 10

                        Row.LeftLine.Size = UDim2.new(0.5, -7 - HalfWidth, 0, 2)
                        Row.RightLine.Size = UDim2.new(0.5, -7 - HalfWidth, 0, 2)
                    else
                        Row.LeftLine.Size = UDim2.new(1, -14, 0, 2)
                    end

                    Row:UpdateButton()
                    continue
                end

                if Entry.ValueImage then
                    Row.Image = Library:ApplyIcon(Row.Image, Entry.ValueImage)
                    Row.Image.Visible = true
                    Row.Button.Size = UDim2.new(1, -18, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    Row.Image.Visible = false
                    Row.Button.Size = UDim2.new(1, 0, 0, ItemHeight)
                    Row.Button.Position = UDim2.fromOffset(0, 0)
                end

                Row:UpdateButton()
            end
        end

        function Dropdown:RunChanged()
            if Dropdown.Disabled then
                return
            end

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end

        local function StopDragSelect()
            DragSelecting = false
            DragStartIndex = nil
            DragPrevMin = nil
            DragPrevMax = nil
            DragLastIndex = nil
            table.clear(DragInitialValues)

            if DragInputEndedConn then
                DragInputEndedConn:Disconnect()
                DragInputEndedConn = nil
            end

            if DragInputChangedConn then
                DragInputChangedConn:Disconnect()
                DragInputChangedConn = nil
            end
        end

        local DragActiveCount = 0

        local function ApplyDragIndex(Index, InRange)
            local Entry = FilteredEntries[Index]
            if not Entry or Entry.IsDisabled or Entry.IsDivider then
                return
            end

            local Try = DragInitialValues[Entry.Value]
            if InRange then
                Try = not Try
            end

            local WantActive = Try and true or false
            local IsActive = Dropdown.Value[Entry.Value] and true or false
            if WantActive == IsActive then
                return
            end

            if not WantActive and DragActiveCount == 1 and not Info.AllowNull then
                return
            end

            Dropdown.Value[Entry.Value] = WantActive and true or nil
            DragActiveCount += WantActive and 1 or -1
        end

        local function ApplyDragRange(From, To, InRange)
            for Index = From, To do
                ApplyDragIndex(Index, InRange)
            end
        end

        local function UpdateDrag(CurrentIndex)
            if CurrentIndex == nil or CurrentIndex == DragLastIndex then
                return
            end

            DragLastIndex = CurrentIndex

            local Min = math.min(DragStartIndex, CurrentIndex)
            local Max = math.max(DragStartIndex, CurrentIndex)
            DragActiveCount = Dropdown:GetActiveValues(true)

            if DragPrevMin == nil then
                ApplyDragRange(Min, Max, true)
            else
                if DragPrevMin < Min then
                    ApplyDragRange(DragPrevMin, Min - 1, false)
                end
                if DragPrevMax > Max then
                    ApplyDragRange(Max + 1, DragPrevMax, false)
                end
                if Min < DragPrevMin then
                    ApplyDragRange(Min, DragPrevMin - 1, true)
                end
                if Max > DragPrevMax then
                    ApplyDragRange(DragPrevMax + 1, Max, true)
                end
            end

            DragPrevMin = Min
            DragPrevMax = Max

            for _, OtherRow in Pool do
                OtherRow:UpdateButton()
            end
        end

        local function CreatePoolRow()
            local Row = {
                Entry = nil,
                Index = nil
            }

            local Container = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                Visible = false,
                Parent = MenuTable.Menu,
            })

            local Corner = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = Container,
            }); table.insert(Library.SpecificCorners, Corner)

            local Image = Library:CreateIcon(nil, {
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = Container,
            })

            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, ItemHeight),
                RichText = true,
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Container,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                Parent = Button,
            })

            local LeftLine = New("Frame", {
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromOffset(7, (ItemHeight - 1) / 2 - 1),
                Visible = false,
                Parent = Container,
            })

            local RightLine = New("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.new(1, -7, 0, (ItemHeight - 1) / 2 - 1),
                Visible = false,
                Parent = Container,
            })

            Row.Container = Container
            Row.Corner = Corner
            Row.Image = Image
            Row.Button = Button
            Row.LeftLine = LeftLine
            Row.RightLine = RightLine

            function Row:UpdateButton()
                local Entry = Row.Entry
                if not Entry then
                    return
                end

                if Entry.IsDivider then
                    Row.Selected = false
                    Container.BackgroundTransparency = 1
                    Button.TextTransparency = 0.5
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                Row.Selected = Selected and true or false

                Container.BackgroundTransparency = Selected and 0 or 1
                Button.TextTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5

                if Entry.ValueImage then
                    SetIconProperties(Row.Image, { ImageTransparency = Entry.IsDisabled and 0.8 or Selected and 0 or 0.5 })
                end
            end

            table.insert(Dropdown.Connections, Button.MouseButton1Click:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or Entry.IsDivider or DragSelecting then
                    return
                end

                local Selected
                if Info.Multi then
                    Selected = Dropdown.Value[Entry.Value]
                else
                    Selected = Dropdown.Value == Entry.Value
                end

                local Try = not Selected
                if not (Dropdown:GetActiveValues(true) == 1 and not Try and not Info.AllowNull) then
                    Selected = Try
                    if Info.Multi then
                        Dropdown.Value[Entry.Value] = Selected and true or nil
                    else
                        Dropdown.Value = Selected and Entry.Value or nil
                    end

                    for _, OtherRow in Pool do
                        OtherRow:UpdateButton()
                    end
                end

                Row:UpdateButton()
                Dropdown:Display()

                Library:UpdateDependencyBoxes()
                Dropdown:RunChanged()
            end))

            table.insert(Dropdown.Connections, Button.MouseEnter:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or Entry.IsDivider then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 0.85,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.25,
                }):Play()

                TweenIcon(Row.Image, { ImageTransparency = 0.25 })
            end))

            table.insert(Dropdown.Connections, Button.MouseLeave:Connect(function()
                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or Entry.IsDivider then
                    return
                end

                if Row.Selected then
                    return
                end

                TweenService:Create(Container, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.5,
                }):Play()

                TweenIcon(Row.Image, { ImageTransparency = 0.5 })
            end))

            table.insert(Dropdown.Connections, Button.InputBegan:Connect(function(StartInput)
                if not (Info.Multi and Dropdown.DragSelect and not Library.IsMobile) then
                    return
                end

                local Entry = Row.Entry
                if not Entry or Entry.IsDisabled or Entry.IsDivider then
                    return
                end

                if not IsMouseInput(StartInput) then
                    return
                end

                DragSelecting = true
                DragStartIndex = Row.Index
                table.clear(DragInitialValues)

                for _, FilteredEntry in FilteredEntries do
                    if FilteredEntry.IsDivider then continue end
                    DragInitialValues[FilteredEntry.Value] = Dropdown.Value[FilteredEntry.Value]
                end

                UpdateDrag(Row.Index)

                if DragInputEndedConn then DragInputEndedConn:Disconnect() end
                if DragInputChangedConn then DragInputChangedConn:Disconnect() end

                DragInputChangedConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(ChangeInput)
                    if not IsMovementInput(ChangeInput) and ChangeInput ~= StartInput then
                        return
                    end

                    local Pos = ChangeInput.Position
                    for _, OtherRow in Pool do
                        if OtherRow.Entry and Library:MouseIsOverFrame(OtherRow.Button, Pos) then
                            UpdateDrag(OtherRow.Index)
                            break
                        end
                    end
                end))

                DragInputEndedConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(EndInput)
                    if EndInput ~= StartInput and not (IsMouseInput(EndInput) and EndInput.UserInputType == StartInput.UserInputType) then
                        return
                    end

                    Dropdown:Display()
                    Library:UpdateDependencyBoxes()
                    Dropdown:RunChanged()

                    StopDragSelect()
                end))

                table.insert(Dropdown.Connections, DragInputEndedConn)
                table.insert(Dropdown.Connections, DragInputChangedConn)
            end))

            return Row
        end

        function Dropdown:BuildDropdownList()
            StopDragSelect()

            RecomputeFilteredEntries()

            MenuTable.Menu.CanvasPosition = Vector2.new(0, 0)

            Dropdown:RefreshPool()
            Dropdown:RecalculateListSize(#FilteredEntries)
        end

        for _ = 1, PoolSize do
            table.insert(Pool, CreatePoolRow())
        end

        table.insert(Dropdown.Connections, MenuTable.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            Dropdown:RefreshPool()
        end))

        local function ValueExists(Val)
            if IsDropdownDivider(Val) then
                return false
            end

            if IsSequentialArray(Dropdown.Values) then
                for _, Existing in Dropdown.Values do
                    if Existing == Val then
                        return true
                    end
                end

                return false
            end

            return Dropdown.Values[Val] ~= nil
        end

        function Dropdown:SetValue(Value)
            if Info.Multi then
                if typeof(Value) == "string" then
                    Value = if Value == "" then {} else { [Value] = true }
                end

                local Table = {}

                for Val, Active in Value or {} do
                    if typeof(Active) ~= "boolean" then
                        Table[Active] = true
                    elseif Active and ValueExists(Val) then
                        Table[Val] = true
                    end
                end

                Dropdown.Value = Table
            else
                if ValueExists(Value) then
                    Dropdown.Value = Value
                elseif not Value then
                    Dropdown.Value = nil
                end
            end

            Dropdown:Display()
            for _, Row in Pool do
                Row:UpdateButton()
            end

            if not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            Dropdown:RunChanged()
        end

        function Dropdown:SetValues(Values)
            Dropdown.Values = Values

            local Changed = false
            if Info.Multi then
                for Val in Dropdown.Value do
                    if not ValueExists(Val) then
                        Dropdown.Value[Val] = nil
                        Changed = true
                    end
                end

            elseif Dropdown.Value ~= nil and not ValueExists(Dropdown.Value) then
                Dropdown.Value = nil
                Changed = true
            end

            Dropdown:BuildDropdownList()
            Dropdown:Display()

            if Changed and not Dropdown.Disabled then
                Library:UpdateDependencyBoxes()
            end

            if Changed then
                Dropdown:RunChanged()
            end
        end

        function Dropdown:AddValues(Values)
            if typeof(Values) ~= "table" and typeof(Values) ~= "string" then
                return
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            if IsDictionary then
                if typeof(Values) == "string" then
                    Dropdown.Values[Values] = Values

                elseif IsSequentialArray(Values) then
                    for _, Val in Values do
                        Dropdown.Values[Val] = Val
                    end

                else
                    for Key, Val in Values do
                        Dropdown.Values[Key] = Val
                    end
                end
            else
                if typeof(Values) == "table" then
                    for _, Val in Values do
                        table.insert(Dropdown.Values, Val)
                    end
                else
                    table.insert(Dropdown.Values, Values)
                end
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabledValues(DisabledValues)
            Dropdown.DisabledValues = DisabledValues
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddDisabledValues(DisabledValues)
            if typeof(DisabledValues) == "table" then
                for _, val in DisabledValues do
                    table.insert(Dropdown.DisabledValues, val)
                end
            elseif typeof(DisabledValues) == "string" then
                table.insert(Dropdown.DisabledValues, DisabledValues)
            else
                return
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            Dropdown.ValueImages = ValueImages
            Dropdown:BuildDropdownList()
        end

        function Dropdown:AddValueImages(ValueImages)
            if typeof(ValueImages) ~= "table" then
                return
            end

            for key, val in ValueImages do
                Dropdown.ValueImages[key] = val
            end

            Dropdown:BuildDropdownList()
        end

        function Dropdown:SetDisabled(Disabled: boolean)
            Dropdown.Disabled = Disabled

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable.Disabled = Dropdown.Disabled
            end

            MenuTable:Close()
            DisplayButton.Active = not Dropdown.Disabled
            Dropdown:UpdateColors()
            Library:UpdateAddons(Dropdown)

            Library:UpdateDependencyBoxes()
        end

        function Dropdown:SetVisible(Visible: boolean)
            Dropdown.Visible = Visible

            Holder.Visible = Dropdown.Visible
            Groupbox:Resize()
        end

        function Dropdown:SetText(Text: string)
            Dropdown.Text = Text
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 21)

            Label.Text = Text and Text or ""
            Label.Visible = not not Text
        end

        function Dropdown:SetDragSelect(Value: boolean)
            if not Info.Multi or Library.IsMobile then
                Value = false
            end

            Dropdown.DragSelect = Value == true
            Dropdown:BuildDropdownList()
        end

        local ToggleDropdown = function()
            if Dropdown.Disabled then
                return
            end

            MenuTable:Toggle()
        end

        table.insert(Dropdown.Connections, DisplayContainer.MouseButton1Click:Connect(ToggleDropdown))
        table.insert(Dropdown.Connections, DisplayButton.MouseButton1Click:Connect(ToggleDropdown))

        if SearchBox then
            table.insert(Dropdown.Connections, SearchBox:GetPropertyChangedSignal("Text"):Connect(Dropdown.BuildDropdownList))
        end

        local Defaults = (function()
            local Resolved = {}
            local Default = Info.Default
            if Default == nil then
                return Resolved
            end

            local IsDictionary = not IsSequentialArray(Dropdown.Values)
            local function ResolveOne(Candidate)
                if IsDictionary then
                    return Dropdown.Values[Candidate] ~= nil and Candidate or nil
                end

                for _, Existing in Dropdown.Values do
                    if Existing == Candidate then
                        return Existing
                    end
                end

                return nil
            end

            local DefaultType = typeof(Default)
            if DefaultType == "string" then
                local Value = ResolveOne(Default)
                if Value ~= nil then
                    table.insert(Resolved, Value)
                end

            elseif DefaultType == "table" then
                for _, Candidate in Default do
                    local Value = ResolveOne(Candidate)
                    if Value ~= nil then
                        table.insert(Resolved, Value)
                    end
                end

            elseif Dropdown.Values[Default] ~= nil and not IsDropdownDivider(Dropdown.Values[Default]) then
                table.insert(Resolved, IsDictionary and Default or Dropdown.Values[Default])
            end

            return Resolved
        end)()

        for _, SelectValue in Defaults do
            if Info.Multi then
                Dropdown.Value[SelectValue] = true
            else
                Dropdown.Value = SelectValue
                break
            end
        end

        if typeof(Dropdown.Tooltip) == "string" or typeof(Dropdown.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Dropdown.Tooltip, Dropdown.DisabledTooltip, DisplayContainer)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end

        Dropdown:UpdateColors()
        Dropdown:Display()
        Dropdown:BuildDropdownList()
        Groupbox:Resize()

        Dropdown.Holder = Holder
        Dropdown.Label = Label
        Dropdown.Container = DisplayContainer

        Dropdown.AddSettings = BaseAddons.__index.AddSettings
        table.insert(Groupbox.Elements, Dropdown)

        Dropdown.Default = Defaults
        Dropdown.DefaultValues = Dropdown.Values

        Options[Idx] = Dropdown

        function Dropdown:Destroy()
            Dropdown.Destroyed = true

            StopDragSelect()

            if Dropdown.Connections then
                for _, Connection in Dropdown.Connections do
                    Connection:Disconnect()
                end
            end

            if Dropdown.Addons then
                for Index = #Dropdown.Addons, 1, -1 do
                    local Addon = table.remove(Dropdown.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if Dropdown.TooltipTable then
                Dropdown.TooltipTable:Destroy()
            end

            if MenuTable then
                MenuTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Dropdown)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Dropdown
    end

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local function GetPivotPosition()
            return (Viewport.Object :: PVInstance):GetPivot().Position
        end

        local function OrbitCamera(Yaw: number, Pitch: number)
            local Position = GetPivotPosition()
            local Camera = Viewport.Camera

            local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), Yaw)
            Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

            local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, Pitch)
            local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

            if PitchedCFrame.UpVector.Y > 0.1 then
                Camera.CFrame = PitchedCFrame
            end
        end

        local function ZoomCamera(Amount: number)
            Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * Amount
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or (input.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                OrbitCamera(-MouseDelta.X * 0.01, -MouseDelta.Y * 0.01)
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                ZoomCamera(input.Position.Z * 2)
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, _, _, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                ZoomCamera(delta)
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetCameraCFrame(NewCFrame: CFrame)
            assert(typeof(NewCFrame) == "CFrame", "CFrame must be a valid CFrame.")

            Viewport.Camera.CFrame = NewCFrame
        end

        function Viewport:GetCameraCFrame(): CFrame
            return Viewport.Camera.CFrame
        end

        function Viewport:Rotate(Yaw: number, Pitch: number?)
            if not Viewport.Object then
                return
            end

            OrbitCamera(math.rad(Yaw or 0), math.rad(Pitch or 0))
        end

        function Viewport:Zoom(Amount: number)
            assert(typeof(Amount) == "number", "Amount must be a number.")

            ZoomCamera(Amount)
        end

        function Viewport:LookAt(Target: Vector3?)
            if not Target and not Viewport.Object then
                return
            end

            Viewport.Camera.CFrame = CFrame.lookAt(Viewport.Camera.CFrame.Position, Target or GetPivotPosition())
        end

        function Viewport:SetDistance(Distance: number)
            assert(typeof(Distance) == "number" and Distance > 0, "Distance must be greater than 0.")
            if not Viewport.Object then
                return
            end

            local Position = GetPivotPosition()
            local Offset = Viewport.Camera.CFrame.Position - Position
            local Direction = Offset.Magnitude > 0 and Offset.Unit or -Viewport.Camera.CFrame.LookVector

            Viewport.Camera.CFrame = CFrame.lookAt(Position + Direction * Distance, Position)
        end

        function Viewport:GetDistance(): number
            if not Viewport.Object then
                return 0
            end

            return (Viewport.Camera.CFrame.Position - GetPivotPosition()).Magnitude
        end

        function Viewport:SetFieldOfView(FieldOfView: number)
            assert(typeof(FieldOfView) == "number", "FieldOfView must be a number.")

            Viewport.Camera.FieldOfView = math.clamp(FieldOfView, 1, 120)
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = Image.BackgroundTransparency,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local Icon = Library:GetCustomIcon(Image.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        local ImageLabel = New("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ScaleType = Image.ScaleType,
            Parent = Box,
        })
        FillInstance(ImageContent(Icon), ImageLabel)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            FillInstance(ImageContent(Icon), ImageLabel)
            Image.Image = Icon.Url
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then
                Holder:Destroy()
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then
                table.remove(Groupbox.Elements, ElemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        table.insert(Depbox.Connections, DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end))

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        table.insert(Depbox.Connections, DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end))

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then
                DepboxContainer:Destroy()
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
            if Groupbox.RefreshBoxHolderLayout then
                Groupbox.RefreshBoxHolderLayout()
            end
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Disabled then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                end

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then
                DepGroupboxContainer:Destroy()
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then
                table.remove(Tab.DependencyGroupboxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then
                table.remove(Library.DependencyBoxes, LibIdx)
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()

    for _, Label in Labels do
        if Label.DoesWrap then
            Label:Display()
            Label.Parent:Resize()
        end
    end

    if Library.Window and Library.Window.RefreshTitleSize then
        Library.Window:RefreshTitleSize()
    end
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))

    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

local function GetNotifySide(): (boolean, boolean)
    local Side = tostring(Library.NotifySide):lower()
    return Side:find("left") ~= nil, Side:find("bottom") ~= nil
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft, IsBottom = GetNotifySide()
    local XScale, YScale, YSign = IsLeft and 0 or 1, IsBottom and 1 or 0, IsBottom and -1 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, YScale, RunningY * YSign)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y / Library.DPIScale + 8
    end
end

function Library:SetNotifySide(Side: "Left" | "Right" | "TopLeft" | "TopRight" | "BottomLeft" | "BottomRight" | string)
    Library.NotifySide = Side

    local IsLeft, IsBottom = GetNotifySide()
    local Anchor = Vector2.new(IsLeft and 0 or 1, IsBottom and 1 or 0)
    NotificationArea.AnchorPoint = Anchor
    NotificationArea.Position = UDim2.new(Anchor.X, IsLeft and 6 or -6, Anchor.Y, IsBottom and -6 or 6)

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = Anchor
    end

    if Library.UpdateNotificationPositions then
        Library:UpdateNotificationPositions(true)
    end
end

function Library:Notify(...)
    local Data = {}
    local Info = select(1, ...)

    if typeof(Info) == "table" then
        Data.Title = tostring(Info.Title)
        Data.TitleColor = Info.TitleColor

        Data.Description = tostring(Info.Description)
        Data.DescriptionColor = Info.DescriptionColor

        Data.Time = Info.Time or 5
        Data.SoundId = Info.SoundId
        Data.Steps = Info.Steps
        Data.Persist = Info.Persist

        Data.Callback = typeof(Info.Callback) == "function" and Info.Callback or nil
        Data.Closable = Info.Closable == true

        Data.Icon = Info.Icon
        Data.BigIcon = Info.BigIcon
        Data.IconColor = Info.IconColor

        Data.Volume = tonumber(Info.Volume) or 3
    else
        Data.Description = tostring(Info)
        Data.Time = select(2, ...) or 5
        Data.SoundId = select(3, ...)
        Data.Volume = select(4, ...) or 3
    end
    Data.Destroyed = false

    local DeletedInstance = false
    local DeleteConnection = nil
    if typeof(Data.Time) == "Instance" then
        DeleteConnection = Data.Time.Destroying:Connect(function()
            DeletedInstance = true

            DeleteConnection:Disconnect()
            DeleteConnection = nil
        end)
    end

    local IsLeft, IsBottom = GetNotifySide()
    local FakeBackground = New("Frame", {
        AnchorPoint = Vector2.new(IsLeft and 0 or 1, IsBottom and 1 or 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = IsLeft and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
        Parent = FakeBackground,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local ContentHolder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = ContentHolder,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = ContentHolder,
    })

    local CloseButton
    if Data.Closable then
        CloseButton = Library:CreateIcon(CloseIcon, {
            AnchorPoint = Vector2.new(1, 0),
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 6,
            Parent = Holder,
        }, true)

        CloseButton.MouseEnter:Connect(function()
            TweenIcon(CloseButton, { ImageTransparency = 0 })
        end)
        CloseButton.MouseLeave:Connect(function()
            TweenIcon(CloseButton, { ImageTransparency = 0.5 })
        end)
        CloseButton.MouseButton1Click:Connect(function()
            Data:Destroy("user")
        end)
    end

    local ContentContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentHolder,
    })

    if Data.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = ContentContainer,
        })
    end

    local BigIconLabel
    if Data.BigIcon then
        local ParsedIcon = Library:GetCustomIcon(Data.BigIcon)
        if ParsedIcon then
            BigIconLabel = Library:CreateIcon(ParsedIcon, {
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = Data.IconColor or "AccentColor",
                Parent = ContentContainer,
            })
        end
    end

    local TextContainer = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        Parent = ContentContainer,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = TextContainer,
    })

    local TitleContainer
    if Data.Title then
        TitleContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Parent = TextContainer,
        })
    end

    local IconLabel
    if Data.Icon and TitleContainer then
        local ParsedIcon = Library:GetCustomIcon(Data.Icon)
        if ParsedIcon then
            IconLabel = Library:CreateIcon(ParsedIcon, {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                ImageColor3 = Data.IconColor or "FontColor",
                Parent = TitleContainer,
            })
        end
    end

    local Title
    local Desc
    local TitleX = 0
    local DescX = 0

    local TimerFill

    if Data.Title then
        Title = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (IconLabel and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = Data.Title,
            TextColor3 = Data.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = TitleContainer,
        })
    end

    if Data.Description then
        Desc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = Data.Description,
            TextColor3 = Data.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = TextContainer,
        })
    end

    function Data:Resize()
        local ExtraWidth = BigIconLabel and 32 or 0
        local IconWidth = IconLabel and 21 or 0
        local CloseWidth = Data.Closable and 20 or 0
        local MaxTextWidth = math.max(
            40,
            (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - ExtraWidth - CloseWidth
        )

        if Title then
            local X, Y = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, MaxTextWidth - IconWidth)
            Title.Size = UDim2.fromOffset(X, Y)
            TitleX = X + IconWidth
            TitleContainer.Size = UDim2.fromOffset(TitleX, math.max(Y, IconLabel and 16 or 0))
        end

        if Desc then
            local X, Y = Library:GetTextBounds(Desc.Text, Desc.FontFace, Desc.TextSize, MaxTextWidth)
            Desc.Size = UDim2.fromOffset(X, Y)
            DescX = X
        end

        FakeBackground.Size = UDim2.fromOffset(math.max(TitleX, DescX) + 24 + ExtraWidth + CloseWidth, 0)

        if Library.Notifications[FakeBackground] then
            task.defer(function()
                if Data.Destroyed or not FakeBackground.Parent then
                    return
                end

                if FakeBackground.AbsoluteSize.Y <= 0 then
                    task.defer(function()
                        if Data.Destroyed or not FakeBackground.Parent then
                            return
                        end

                        Library:UpdateNotificationPositions(true)
                    end)
                    return
                end

                Library:UpdateNotificationPositions(true)
            end)
        end
    end

    function Data:ChangeTitle(Text)
        if Title then
            Data.Title = tostring(Text)
            Title.Text = Data.Title
            Data:Resize()
        end
    end

    function Data:ChangeDescription(Text)
        if Desc then
            Data.Description = tostring(Text)
            Desc.Text = Data.Description
            Data:Resize()
        end
    end

    function Data:ChangeStep(NewStep)
        if TimerFill and Data.Steps then
            NewStep = math.clamp(NewStep or 0, 0, Data.Steps)
            TimerFill.Size = UDim2.fromScale(NewStep / Data.Steps, 1)
        end
    end

    function Data:Destroy(Reason)
        if Data.Destroyed then
            return
        end

        Reason = Reason or "script"
        Data.Destroyed = true

        if Data.Callback then
            pcall(Data.Callback, Reason)
        end

        if typeof(Data.Time) == "Instance" then
            pcall(Data.Time.Destroy, Data.Time)
        end

        if DeleteConnection then
            DeleteConnection:Disconnect()
        end

        if FakeBackground then
            local Idx = table.find(NotifyOrder, FakeBackground)
            if Idx then
                table.remove(NotifyOrder, Idx)
            end
        end

        Library:UpdateNotificationPositions()

        TweenService
            :Create(Holder, Library.NotifyTweenInfo, {
                Position = GetNotifySide() and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
            })
            :Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[FakeBackground] = nil
            FakeBackground:Destroy()
        end)
    end

    local TimerHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (Data.Persist ~= true and typeof(Data.Time) ~= "Instance") or typeof(Data.Steps) == "number",
        Parent = ContentHolder,
    })
    local TimerBar = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = TimerHolder,
    })
    TimerFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = TimerBar,
    })

    if typeof(Data.Time) == "Instance" then
        TimerFill.Size = UDim2.fromScale(0, 1)
    end
    if Data.SoundId then
        local SoundId = Data.SoundId
        if typeof(SoundId) == "number" then
            SoundId = string.format("rbxassetid://%d", SoundId)
        end

        New("Sound", {
            SoundId = SoundId,
            Volume = tonumber(Data.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    Data.Holder = Holder

    table.insert(NotifyOrder, FakeBackground)
    Library.Notifications[FakeBackground] = Data

    Data:Resize()

    FakeBackground.Visible = true
    TweenService:Create(Holder, Library.NotifyTweenInfo, {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.defer(function()
        if not Data.Destroyed then
            Library:UpdateNotificationPositions(true)
        end
    end)

    task.delay(Library.NotifyTweenInfo.Time, function()
        if Data.Persist then
            return
        elseif typeof(Data.Time) == "Instance" then
            repeat
                task.wait()
            until DeletedInstance or Data.Destroyed
        else
            TweenService
                :Create(TimerFill, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromScale(0, 1),
                })
                :Play()
            task.wait(Data.Time)
        end

        Data:Destroy("timer")
    end)

    return Data
end

-- ============================================================================
-- YX · UI 美化模块   ——   所有 Icon「液态玻璃 + 渐变流光」（库原生原理版）
-- ----------------------------------------------------------------------------
-- 【本版改动】
--   ① 液态玻璃：保留窗口级（玻璃高光层 + 面板半透明，移植自新版库 Library.lua），
--      并新增【图标级】玻璃高光 —— 每个图标的流光渐变叠加库 AddGlassSheen 的
--      112° 斜向反光带（Rotation + NumberSequence 透明度），不新建任何实例。
--   ② 流光范围：从「标签按钮 Icon」扩大到【所有 Icon】——
--      图片图标 ImageLabel / ImageButton，以及 lucide 字体图标
--      （库 CreateIcon 生成的、带 IconPadding 子对象的 TextLabel / TextButton）。
--   ③ 窗口 Icon 例外：CreateWindow 里 Icon=... 那个标题栏图标不加流光、不加玻璃，
--      按「图标 asset id」+「父级是 TitleHolder」双保险精确定位。
--   ④ 大图 / 背景图 / 赞助码 / 全透明占位一律跳过，避免误染色。
--   ⑤ 窗口内磨砂玻璃底：不碰 Lighting / 游戏画面，在 MainFrame 内垫一层不透明的
--      柔和磨砂渐变「景」，替代库原版靠 BlurEffect 模糊的游戏世界；面板半透明后
--      透出的是这层有明暗层次的磨砂底，而不是同色纯色底板或杂乱 3D 场景。
--      与「显示背景图」互斥（开图 -> 隐藏磨砂底；关图 -> 显示磨砂底）。
--
-- 【流光算法】1:1 采用 SyndromeXph/Obsidian 新版库 Library.lua：
--   319-336     MakeVioletBlackGradient：4 关键点 sin + Lerp
--   11022-11056 标题：每帧 RenderStepped 重建 ColorSequence + 强制白字基底
--   11234-11248 页脚：每帧重建 + Offset 横向平移 + Rotation 摆动
--   核心是【每帧重新构造整个 ColorSequence】，不是只建一次色带平移 Offset。
--
-- 【液态玻璃】库 1593-1644 行 ApplyLiquidGlass + AddGlassSheen：
--   Rotation=112，Color 白(255,255,255)/浅蓝(200,214,255)/深蓝(36,42,70)，
--   Transparency 0.7/0.88/0.97。窗口层照搬；图标层把透明度压到温和区间
--   （默认 0 → 0.32 → 0），否则图标会淡到看不见。
--
-- 【用法】主脚本 BEAUTIFY_URL 指向本文件即可，主脚本无需改动。
--   加载器签名固定：Loader(Library, ThemeManager, SaveManager)
-- ============================================================================
-- ============================================================================
-- 【内嵌模式】YX 美化模块已并入本库，直接使用库作用域内的局部 Library。
--   无需主脚本再通过 BEAUTIFY_URL 远程加载本模块。
-- ============================================================================

do
    local function IsLockButton(Obj)
        if not (Obj and Obj:IsA("TextButton")) then return false end
        local Ok, T = pcall(function() return Obj.Text end)
        return Ok and (T == "Lock" or T == "Unlock")
    end
    local function Watch(Obj)
        if not (Obj and Obj:IsA("TextButton")) then return end
        pcall(function()
            Obj:GetPropertyChangedSignal("Text"):Connect(function()
                if IsLockButton(Obj) then Obj.Visible = false end
            end)
        end)
        if IsLockButton(Obj) then Obj.Visible = false end
    end
    local Floats = Library.Floats
    if Floats then
        pcall(function()
            for _, Child in ipairs(Floats:GetChildren()) do Watch(Child) end
            Floats.ChildAdded:Connect(Watch)
        end)
    end
end

local DefaultThemeBackground = {
    Library = nil,
    ThemeManager = nil,
    Images = {
        "https://raw.githubusercontent.com/YirdeX-Dev/Miscs/refs/heads/main/IMG_20261107_105307.jpg",
    },

    -- 只保留「背景 1」，启动即用它（已删除背景 2 / 背景 3 及其切换逻辑）
    StartupImageIndex = 1,

    -- 主题切换触发
    TriggerNames = { "Default" },  -- 视为「默认主题」的主题名
    MatchAssignedDefault = true,   -- 同时匹配被「设为默认」的主题名
    AvoidRepeat = true,            -- 不连续抽到同一张
    RollOnFirstApply = false,      -- 首次进入默认主题是否换图
    NotifyOnSwitch = false,        -- 换图时是否弹通知
    NotifyTitle = "默认主题背景",

    -- 选择持久化（记住最后一次背景，下次启动不回到默认图）
    PersistSelection = true,
    PersistFolder = "MyScriptHub",
    PersistFile = "MyScriptHub/yx_background.txt",

    -- 延迟优化：预缓存背景图 + 绕过库对自定义图的强制重下载
    PrefetchImages = true,         -- 后台预下载背景图
    BypassRedownload = true,       -- 拦截 DownloadAsset(FileName, true) 的同步 HttpGet

    -- 配色与渐变
    ApplyPalette = true,           -- 按背景图套用配套主题色
    TintIcons = true,              -- 图标统一青色
    EnableGradient = true,         -- 图标叠加 UIGradient 渐变
    GradientRotation = 45,

    -- 按钮底色「填充」渐变（作用于按钮本体，不是描边）
    EnableButtonGradient = true,     -- 给 AddButton 创建的按钮底色加渐变
    -- 渐变轴角度，通用/CSS 语义：180 = 垂直「上 -> 下」（即向下加深的 180 度）
    --   Roblox UIGradient.Rotation 以「左->右」为 0 顺时针增加，
    --   内部换算：180(上->下)->90，0(下->上)->270，90(左->右)->0，270(右->左)->180
    --   若要直接指定 Roblox 原生角度，设 ButtonGradientRotationOverride = 数值
    ButtonGradientAngle = 180,
    ButtonGradientRotationOverride = nil,
    -- 规则：亮主题色 -> 上=主题色(限亮)，下=加深          =>「向下加深」
    --       偏黑主题 -> 上=提亮(黑->灰)，下=主题色加深    =>「向上变亮」
    ButtonGradientDarkAmount = 0.45,     -- 向下加深幅度（下端 = 上端 x 此值，越小越深）
    ButtonGradientLightAmount = 0.45,    -- 向上提亮幅度（黑 -> 灰）
    ButtonGradientDarkThreshold = 0.18,  -- 主题色感知亮度低于此值 => 判定偏黑，改走提亮
    ButtonGradientTextSafeLum = 0.15,    -- 渐变亮端亮度上限，保证白色文字对比度 >= 4.5
    ButtonGradientBrightness = 1.0,      -- 整体亮度微调（1 = 不变，<1 更暗）

    -- 强调色填充（开关底色 / 滑块填充 / 通知进度条）：与按钮同款主题色自适应。
    --   方向默认自动：开关这种矮胖胶囊用竖向（圆点盖住右半边，横向渐变只剩左半截，看不出），
    --   滑块填充 / 通知进度条这种细长条用水平；把 AutoOrient 关掉则统一听 AccentGradientAngle
    -- 滑块填充渐变：改成约 45° 斜向（不再是纯水平/纯垂直），亮暗沿对角线分布，
    --   右端不会整条压暗发灰；配合下面把末端压暗幅度调高，解决「拖到后面不明显」。
    AccentGradientAngle = 45,   -- 45=斜向渐变（细长条滑块/进度条用；开关仍自动走竖向）
    AccentGradientDarkAmount = 0.72, -- 末端 = 亮端 x 此值（原 0.40 太暗 -> 0.72 右端更明显）
    AccentGradientSafeLum = 0.62,    -- 强调色填充亮端亮度上限；按钮为了白字压到 0.15，
                                     --   开关没有文字，放宽到 0.62，亮端保持主题色本身的鲜艳度
    AccentGradientAutoOrient = true, -- 自动选方向：矮胖控件(开关胶囊)用竖向，细长条(滑块/进度条)用水平

    -- 下拉菜单（Dropdown）：触发按钮 + 展开面板都跟随主题色
    EnableDropdownGradient = true,   -- 关掉则下拉框保持库的纯色（MainColor / BackgroundColor）
    DropdownGradientAngle = 180,     -- 触发按钮角度（180 = 垂直上->下，和按钮一致）
    DropdownMenuTint = 0.35,         -- 展开面板混入主题色的比例（0 = 不染，1 = 整块主题色）
    DropdownMenuAngle = 180,         -- 面板角度（180 = 垂直上->下）
    DropdownMenuDarkAmount = 0.55,   -- 面板下端亮度 = 上端 x 此值（越小越黑）

    -- 滑块：轨道（未填充的右半段）也跟随主题色，与填充形成同色系明暗对比
    EnableSliderTrackGradient = true,
    SliderTrackTint = 0.22,          -- 轨道混入主题色的比例（比填充低，才不会和已填段糊在一起）
    SliderTrackAngle = 45,           -- 轨道与填充统一约 45° 斜向，避免两条渐变方向打架
    SliderTrackDarkAmount = 0.68,    -- 轨道末端亮度（原 0.35 太暗 -> 0.68 到后面仍看得清）
    -- 青 -> 蓝 -> 靛（仅图标使用；按钮和开关都改成跟随主题色了）
    GradientStops = {
        { 0.0, { 34, 211, 238 } },   -- #22D3EE 青
        { 0.5, { 56, 132, 255 } },   -- #3884FF 蓝
        { 1.0, { 99, 102, 241 } },   -- #6366F1 靛
    },

    -- 只保留「背景 1」一套主题色（已删除背景 2 / 背景 3 及其相关主题代码）
    -- 字段：Background / Main / Accent / Outline / Font / Icon，均为 {R,G,B}
    Palettes = {
        { -- 背景 1：整体提亮一档的浅蓝灰（唯一保留的配色，作为启动默认）
          -- 背景/主色/强调色保持明亮档；轮廓(Outline)与字体(Font)按要求改成纯白
            Background = { 32, 44, 64 }, Main = { 46, 62, 88 },
            Accent = { 130, 200, 248 }, Outline = { 255, 255, 255 },
            Font = { 255, 255, 255 }, Icon = { 120, 220, 250 },
        },
    },

    -- 控件填充色（按钮 / 开关 / 滑块填充 / 下拉）默认跟随主题强调色，切主题一起变。
    --   想强制固定一个颜色时，填 {R,G,B}（0~255）；nil = 跟随主题。
    ControlAccent = nil,
    -- 雾蓝调和：跟随主题的同时把青绿偏色拉回雾蓝、略降饱和，和偏亮低饱和的背景图协调。
    --   设为 false 则完全使用主题原色，不做任何调和。
    MistTint = true,

    -- 可选：背景变化时的回调 (Index, Url)
    OnSelect = nil,

    -- 运行时状态
    LastIndex = nil,
    LastUrl = nil,
    LastAppliedTheme = nil,
    Enabled = false,
    _OriginalApplyTheme = nil,
    _OriginalDownloadAsset = nil,
    _OriginalSetBackground = nil,
    _SkipFirstApply = false,
    _CachedAssets = {},      -- FileName -> true
    _GradientObjects = {},   -- 已插入的 UIGradient
    _RegistryBackup = {},    -- Instance -> { {Property, Value, Kind}, ... }
    _SchemeBackup = nil,     -- 应用配色前的 Scheme
    _TargetsCollected = false,
    _IconsTinted = false,

    -- 动态底色渐变同步（开关在运行时开启 / 关闭也能保持渐变）
    _GradientSyncConn = nil,  -- RunService.Heartbeat 连接
    _DynamicTargets = {},     -- [Inst] = true，已被渐变接管的开关 / 强调底色
    _StopsSignature = nil,    -- 上次应用的渐变配置签名（检测配置变更）

    -- 按钮底色渐变（与图标/开关渐变完全隔离，互不干扰）
    _ButtonTargets = {},          -- [Base] = true，已被接管的按钮底色
    _ButtonGradientObjects = {},  -- 按钮专用 UIGradient 列表
    _ButtonSignature = nil,       -- 按钮渐变配置签名（含亮度）

    -- 下拉菜单 / 滑块轨道渐变（同样独立，互不接管）
    _ElemTargets = {},            -- [Inst] = 渐变名（YXDropdownGradient / YXMenuGradient / YXSliderTrackGradient）
    _ElemOrigins = {},            -- [Inst] = 接管前的注册键（MainColor / BackgroundColor）
    _ElemGradientObjects = {},    -- 本路 UIGradient 列表
    _ElemSignature = nil,         -- 本路配置签名
}

local RNG = (Random and Random.new) and Random.new() or nil
local function RandomInt(Min, Max)
    if RNG then return RNG:NextInteger(Min, Max) end
    return math.random(Min, Max)
end

local ConfigKeys = {
    "Images", "StartupImageIndex", "TriggerNames", "MatchAssignedDefault",
    "AvoidRepeat", "RollOnFirstApply", "NotifyOnSwitch", "NotifyTitle",
    "PersistSelection", "PersistFolder", "PersistFile", "PrefetchImages",
    "BypassRedownload", "ApplyPalette", "TintIcons", "EnableGradient",
    "GradientRotation", "GradientStops", "Palettes", "ControlAccent", "MistTint", "OnSelect",
    "EnableButtonGradient", "ButtonGradientBrightness",
    "ButtonGradientAngle", "ButtonGradientRotationOverride",
    "ButtonGradientDarkAmount", "ButtonGradientLightAmount",
    "ButtonGradientDarkThreshold", "ButtonGradientTextSafeLum",
    "AccentGradientAngle", "AccentGradientDarkAmount", "AccentGradientSafeLum",
    "AccentGradientAutoOrient",
    "EnableDropdownGradient", "DropdownGradientAngle", "DropdownMenuTint",
    "DropdownMenuAngle", "DropdownMenuDarkAmount",
    "EnableSliderTrackGradient", "SliderTrackTint", "SliderTrackAngle", "SliderTrackDarkAmount",
}

-- 复刻库 Window:SetBackgroundImage 里的文件名提取规则，
-- 保证预注册的 AssetName 与库内部使用的完全一致。
local function AssetFileName(Url)
    if type(Url) ~= "string" then return nil end
    return Url:match("([^/]+)$")
end

local function RGB(Table)
    if not (Color3 and Color3.fromRGB) then return nil end
    local Ok, Color = pcall(Color3.fromRGB, Table[1], Table[2], Table[3])
    return Ok and Color or nil
end

-- ============================================================
-- 按钮渐变：主题色自适应明暗工具（颜色分量统一为 0~1 的 sRGB 编码值）
--   Color3.fromRGB 得到的 .R/.G/.B 就是 0~1，这里所有运算都在此空间完成，
--   与 RGB({0..255}) 的写法等价，实测与游戏内渲染吻合。
-- ============================================================
local function YXReadColor3(C)
    if type(C) ~= "userdata" and type(C) ~= "table" then return nil end
    local Ok, R, G, B = pcall(function() return C.R, C.G, C.B end)
    if not (Ok and type(R) == "number" and type(G) == "number" and type(B) == "number") then
        return nil
    end
    local Scale = (R > 1 or G > 1 or B > 1) and 255 or 1  -- 兼容少数 0~255 执行器
    local function Bound(V)
        if V < 0 then return 0 end
        if V > 1 then return 1 end
        return V
    end
    return { Bound(R / Scale), Bound(G / Scale), Bound(B / Scale) }
end

local function YXLuminance(C)
    local function F(V)
        if V <= 0.04045 then return V / 12.92 end
        return ((V + 0.055) / 1.055) ^ 2.4
    end
    return 0.2126 * F(C[1]) + 0.7152 * F(C[2]) + 0.0722 * F(C[3])
end

-- 保持色相，仅按统一系数把亮度压到 MaxL 以内（二分求系数）
local function YXClampLuminance(C, MaxL)
    if YXLuminance(C) <= MaxL then return { C[1], C[2], C[3] } end
    local Lo, Hi = 0, 1
    for _ = 1, 20 do
        local M = (Lo + Hi) / 2
        local T = { C[1] * M, C[2] * M, C[3] * M }
        if YXLuminance(T) > MaxL then Hi = M else Lo = M end
    end
    return { C[1] * Lo, C[2] * Lo, C[3] * Lo }
end

-- 线性混色：T=0 取 A，T=1 取 B（三个分量都在 0~1 空间）
local function YXMix(A, B, T)
    T = tonumber(T) or 0
    if T < 0 then T = 0 elseif T > 1 then T = 1 end
    return {
        A[1] + (B[1] - A[1]) * T,
        A[2] + (B[2] - A[2]) * T,
        A[3] + (B[3] - A[3]) * T,
    }
end

-- ============================================================
-- 统一主题取色（控件 / 边框共用）
--   背景图实测主色 RGB(170,179,198)、色相 221°、低饱和、偏亮，是雾蓝灰。
--   因此在「跟随主题强调色」基础上做一次雾蓝调和：
--     * 青绿偏色（约 140°~205°）拉回雾蓝色相 215°，避免再次发绿；
--     * 其余色相保留，仅轻微降饱和；
--     * 亮度沿用主题本身，不强行压暗。
-- ============================================================
local function YXMistTint(C)
    if not (Color3 and Color3.new and Color3.fromHSV) then return C end
    local Ok, Out = pcall(function()
        local H, S, V = Color3.new(C[1], C[2], C[3]):ToHSV()
        local Deg = H * 360
        if Deg >= 140 and Deg <= 205 then
            Deg = 215
            S = math.min(S, 0.45)
        else
            S = S * 0.85
        end
        -- 只强制调和青绿偏色；其余色相仅 *0.85，不再统一压上限，避免把鲜艳主题色调得过淡
        S = math.max(0.12, S)
        local R = Color3.fromHSV(Deg / 360, S, V)
        return { R.R, R.G, R.B }
    end)
    return (Ok and Out) or C
end

-- 读当前主题强调色并做雾蓝调和，返回 {r,g,b}（0~1）。Mist=false 可关闭调和。
local function YXThemeAccentRGB(Lib, Mist)
    local Base = YXReadColor3(Lib and Lib.Scheme and Lib.Scheme.AccentColor)
    if not Base then Base = { 130 / 255, 200 / 255, 248 / 255 } end
    if Mist ~= false then Base = YXMistTint(Base) end
    return Base
end

function DefaultThemeBackground:SetLibrary(Lib)
    self.Library = Lib
    return self
end

function DefaultThemeBackground:SetThemeManager(Manager)
    self.ThemeManager = Manager
    return self
end

function DefaultThemeBackground:SetImages(Images)
    assert(type(Images) == "table" and #Images > 0, "图片列表必须是非空数组")
    self.Images = Images
    self.LastIndex = nil
    return self
end

function DefaultThemeBackground:Configure(Config)
    if type(Config) ~= "table" then return self end
    for _, Key in ipairs(ConfigKeys) do
        if Config[Key] ~= nil then self[Key] = Config[Key] end
    end
    return self
end

function DefaultThemeBackground:IndexOfUrl(Url)
    for Index, Item in ipairs(self.Images) do
        if Item == Url then return Index end
    end
    return nil
end

function DefaultThemeBackground:IsDefaultTheme(ThemeName)
    if type(ThemeName) ~= "string" then return false end
    for _, Name in ipairs(self.TriggerNames) do
        if ThemeName == Name then return true end
    end
    if self.MatchAssignedDefault and self.ThemeManager then
        local Assigned = self.ThemeManager.DefaultThemeName
        if Assigned and ThemeName == Assigned then return true end
    end
    return false
end

--// 选择持久化 //--
function DefaultThemeBackground:ReadSelection()
    if not (self.PersistSelection and readfile and isfile) then return nil end
    local OkExists, Exists = pcall(isfile, self.PersistFile)
    if not (OkExists and Exists) then return nil end
    local OkRead, Content = pcall(readfile, self.PersistFile)
    if not OkRead then return nil end
    local Index = tonumber(tostring(Content):match("%d+"))
    if Index and Index >= 1 and Index <= #self.Images then return Index end
    return nil
end

function DefaultThemeBackground:SaveSelection(Index)
    if not (self.PersistSelection and writefile) then return false end
    if type(Index) ~= "number" then return false end
    return pcall(function()
        if makefolder and isfolder then
            local Ok, Exists = pcall(isfolder, self.PersistFolder)
            if not (Ok and Exists) then pcall(makefolder, self.PersistFolder) end
        end
        writefile(self.PersistFile, tostring(math.floor(Index)))
    end)
end

--// 延迟优化：预注册缓存 + 拦截强制重下载 //--
function DefaultThemeBackground:InstallCacheOptimizer()
    local IM = self.Library and self.Library.ImageManager
    if not (IM and type(IM.AddAsset) == "function" and type(IM.DownloadAsset) == "function") then
        return false
    end

    if self.BypassRedownload and not self._OriginalDownloadAsset then
        local Original = IM.DownloadAsset
        self._OriginalDownloadAsset = Original
        local Module = self
        IM.DownloadAsset = function(Name, ForceRedownload, ...)
            -- 库每次设置 URL 背景都会传 true 强制重新下载；对已缓存图片直接跳过
            if ForceRedownload == true and Module._CachedAssets[Name] then
                return true, nil
            end
            return Original(Name, ForceRedownload, ...)
        end
    end

    if not self.PrefetchImages then return true end

    local Module = self
    local function Register(Url)
        local Name = AssetFileName(Url)
        if not Name then return end
        pcall(function()
            if not IM.GetAsset or not IM.GetAsset(Name) then
                pcall(IM.AddAsset, Name, 0, Url)   -- 首次注册并下载一次
            end
        end)
        Module._CachedAssets[Name] = true
    end

    local Urls = {}
    for _, Url in ipairs(self.Images) do Urls[#Urls + 1] = Url end
    local function Work()
        for _, Url in ipairs(Urls) do Register(Url) end
    end
    if task and task.spawn then pcall(task.spawn, Work) else Work() end
    return true
end

--// 监听一切背景设置（含用户在「背景图片」输入框手动粘贴 URL）//--
function DefaultThemeBackground:InstallBackgroundTracker()
    local Lib = self.Library
    if not (Lib and type(Lib.SetBackgroundImage) == "function") then return false end
    if self._OriginalSetBackground then return true end

    local Original = Lib.SetBackgroundImage
    self._OriginalSetBackground = Original
    local Module = self
    Lib.SetBackgroundImage = function(LibSelf, Image, ...)
        local Results = table.pack(Original(LibSelf, Image, ...))
        pcall(function()
            if type(Image) == "string" then
                local Index = Module:IndexOfUrl(Image)
                if Index and Index ~= Module.LastIndex then
                    Module.LastIndex = Index
                    Module.LastUrl = Module.Images[Index]
                    Module:SaveSelection(Index)
                    if Module.ApplyPalette then pcall(Module.ApplyPaletteFor, Module, Index) end
                    if type(Module.OnSelect) == "function" then
                        pcall(Module.OnSelect, Index, Module.LastUrl)
                    end
                end
            end
        end)
        return table.unpack(Results, 1, Results.n)
    end
    return true
end

--// 应用背景 URL //--
function DefaultThemeBackground:ApplyUrl(Url)
    local Lib = self.Library
    if not Lib or type(Url) ~= "string" or Url == "" then return false end

    local Option = Lib.Options and Lib.Options.BackgroundImage
    local Applied = false
    if Option and Option.SetValue then
        local Ok = pcall(function() Option:SetValue(Url) end)
        Applied = Ok and Lib.Scheme ~= nil and Lib.Scheme.BackgroundImage == Url
    end
    if not Applied then
        pcall(function() Lib:SetBackgroundImage(Url) end)
    end
    return true
end

--// 配色 / 图标青色 / 渐变 //--
function DefaultThemeBackground:ApplyPaletteFor(Index, Force)
    local Lib = self.Library
    if not (self.ApplyPalette and Lib and Lib.Scheme) then return end
    -- 默认只把「背景 1」配色套用一次（启动时）。切到别的主题时不再用固定调色板
    --   覆盖主题自身的 AccentColor / BackgroundColor，渐变才能实时跟随当前主题。
    -- Force = true：用于「从别的主题切回默认主题」。ThemeManager 刚用它自己的主题数据
    --   整表覆盖了 Scheme，必须重新把背景 1 配色套回去，否则回切后配色不是启动那套默认值。
    if self._PaletteApplied and not Force then return end
    self._PaletteApplied = true
    local P = self.Palettes[Index] or self.Palettes[1]
    if not P then return end

    if not self._SchemeBackup then
        self._SchemeBackup = {}
        for _, Key in ipairs({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor" }) do
            self._SchemeBackup[Key] = Lib.Scheme[Key]
        end
        self._SchemeBackup.IconColor = Lib.Scheme.IconColor
    end

    -- Scheme 键 -> 配色表字段
    local PaletteMap = {
        { "BackgroundColor", "Background" },
        { "MainColor", "Main" },
        { "AccentColor", "Accent" },
        { "OutlineColor", "Outline" },
        { "FontColor", "Font" },
    }
    local function Set(Key, ValueTable)
        local Color = RGB(ValueTable)
        if Color then Lib.Scheme[Key] = Color end
    end

    -- 先同步颜色选择器（其 OnChanged 会触发 ThemeUpdate 回写 Scheme）
    for _, Pair in ipairs(PaletteMap) do
        local Color = RGB(P[Pair[2]])
        local Opt = Lib.Options and Lib.Options[Pair[1]]
        if Opt and Opt.SetValue and Color then
            pcall(Opt.SetValue, Opt, Color)
        end
    end

    -- 再显式写入精确值，避免颜色选择器 HSV 往返与回调副作用改变最终配色
    Set("BackgroundColor", P.Background)
    Set("MainColor", P.Main)
    Set("AccentColor", P.Accent)
    Set("OutlineColor", P.Outline)
    Set("FontColor", P.Font)
    if self.TintIcons then Set("IconColor", P.Icon) end

    self:ApplyIconTint()
    self:ApplyGradient()
    if Lib.UpdateColorsUsingRegistry then pcall(Lib.UpdateColorsUsingRegistry, Lib) end
end

-- 收集需要染色的元素：图标（ImageColor3=FontColor）与强调色元素（AccentColor 系）
function DefaultThemeBackground:CollectTargets()
    local Lib = self.Library
    if not (Lib and Lib.Registry) then return end
    if self._TargetsCollected then return end
    self._TargetsCollected = true

    for Inst, Props in pairs(Lib.Registry) do
        local List = {}
        for Property, Index in pairs(Props) do
            if type(Index) == "string" then
                local Kind = nil
                if Index == "FontColor" and Property == "ImageColor3" then
                    Kind = "Icon"
                elseif Index == "AccentColor" and (Property == "BackgroundColor3" or Property == "ImageColor3") then
                    Kind = "Accent"
                end
                if Kind then
                    table.insert(List, { Property = Property, Value = Index, Kind = Kind })
                end
            end
        end
        if #List > 0 then self._RegistryBackup[Inst] = List end
    end
end

function DefaultThemeBackground:ApplyIconTint()
    local Lib = self.Library
    if not (self.TintIcons and Lib and Lib.Registry) then return end
    self:CollectTargets()
    if self._IconsTinted then return end
    self._IconsTinted = true
    for Inst, List in pairs(self._RegistryBackup) do
        local Props = Lib.Registry[Inst]
        if Props then
            for _, Entry in ipairs(List) do
                if Entry.Kind == "Icon" then
                    Props[Entry.Property] = "IconColor"  -- 先统一青色；渐变成功时再改白色基底
                end
            end
        end
    end
end

-- 构建渐变色序列（图标 / 强调色 / 开关底色共用同一套）
function DefaultThemeBackground:GetGradientStops()
    local Ok, Stops = pcall(function()
        local Keypoints = {}
        for _, Stop in ipairs(self.GradientStops) do
            local Color = RGB(Stop[2])
            if Color then
                table.insert(Keypoints, ColorSequenceKeypoint.new(Stop[1], Color))
            end
        end
        if #Keypoints == 0 then return nil end
        return ColorSequence.new(Keypoints)
    end)
    return Ok and Stops or nil
end

function DefaultThemeBackground:GetGradientWhite()
    if Color3 and Color3.fromRGB then return Color3.fromRGB(255, 255, 255) end
    if Color3 and Color3.new then return Color3.new(1, 1, 1) end
    return nil
end

-- 配置签名：GradientStops / Rotation 变化时可刷新所有已建渐变
function DefaultThemeBackground:StopsSignature()
    local Parts = {}
    for _, Stop in ipairs(self.GradientStops) do
        local C = Stop[2] or {}
        Parts[#Parts + 1] = string.format("%s:%s,%s,%s", tostring(Stop[1]),
            tostring(C[1]), tostring(C[2]), tostring(C[3]))
    end
    return table.concat(Parts, "|") .. "@" .. tostring(self.GradientRotation)
end

-- 强调色填充的签名：主题色 + 自适应参数 + 角度；任一变化即刷新开关/滑块/进度条渐变
function DefaultThemeBackground:AccentStopsSignature()
    local C = self:GetThemeColor()
    return string.format("%.4f,%.4f,%.4f", C[1], C[2], C[3])
        .. "#AA" .. tostring(self.AccentGradientAngle)
        .. "#DA" .. tostring(self.ButtonGradientDarkAmount)
        .. "#LA" .. tostring(self.ButtonGradientLightAmount)
        .. "#TH" .. tostring(self.ButtonGradientDarkThreshold)
        .. "#SL" .. tostring(self.ButtonGradientTextSafeLum)
        .. "#BR" .. tostring(self.ButtonGradientBrightness)
        .. "#AD" .. tostring(self.AccentGradientDarkAmount)
        .. "#AS" .. tostring(self.AccentGradientSafeLum)
end

function DefaultThemeBackground:RememberDynamicBackup(Inst, Property, Value)
    local List = self._RegistryBackup[Inst]
    if not List then List = {}; self._RegistryBackup[Inst] = List end
    for _, Entry in ipairs(List) do
        if Entry.Property == Property then return end   -- 已有原值更权威，不覆盖
    end
    table.insert(List, { Property = Property, Value = Value, Kind = "Dynamic" })
end

function DefaultThemeBackground:ApplyGradient()
    local Lib = self.Library
    if not (self.EnableGradient and Lib and Lib.Scheme and Lib.Registry) then return end
    if not (Instance and Instance.new) then return end
    if #self._GradientObjects > 0 then return end  -- 已插入
    self:CollectTargets()

    -- 库的 Registry 只支持单一 Color3，主题色本身无法设成渐变；
    -- 这里只给「图标」叠加固定青->蓝->靛渐变（YXThemeGradient）。
    --   强调色元素（开关开启时的底色 / 滑块填充 / 通知进度条）不再在这里接管，
    --   改由 SyncDynamicGradients 每帧扫描 Registry 的 "AccentColor" 来接管：
    --   这样即便库的 Toggle:Display 每帧把开关底色索引改回 "AccentColor"，
    --   也不会和我们的自定义白键互相覆盖；运行时开启的开关也能立即拿到渐变，
    --   且渐变颜色每帧用实时主题色重算，自动跟随主题切换。
    local Stops = self:GetGradientStops()
    local White = self:GetGradientWhite()
    if not (Stops and White) then return end
    Lib.Scheme.IconGradientBase = White

    local Gradientable = {}
    for Inst, List in pairs(self._RegistryBackup) do
        local Props = Lib.Registry[Inst]
        if Props then
            for _, Entry in ipairs(List) do
                if Entry.Kind == "Icon" then
                    Props[Entry.Property] = "IconGradientBase"
                    table.insert(Gradientable, Inst)
                    break
                end
            end
        end
    end

    for _, Inst in ipairs(Gradientable) do
        pcall(function()
            local Grad = Instance.new("UIGradient")
            Grad.Name = "YXThemeGradient"
            Grad.Rotation = self.GradientRotation
            Grad.Color = Stops
            Grad.Parent = Inst
            table.insert(self._GradientObjects, Grad)
        end)
    end

    -- 立即按新注册表键刷新一次，让白基底当场生效（原版依赖外部回写，单独调用会失效）
    if Lib.UpdateColorsUsingRegistry then pcall(Lib.UpdateColorsUsingRegistry, Lib) end
    self:InstallGradientSync()
end

-- ============================================================
-- 动态底色渐变同步器
--   库的 Toggle:Display() 每次都会直接写 Switch.BackgroundColor3（纯色），
--   并把 Registry 标签在 "MainColor" / "AccentColor" 之间来回改：
--       启动时关闭的开关 -> 标签是 "MainColor"，CollectTargets 收不到
--       后来开启 / 反复切换 -> 库刷回纯 AccentColor，白基底与渐变一起丢失
--   所以只靠启动时分类一次不够。这里低频扫描 Registry：
--     · 当前为强调色底色的对象 -> 补渐变 + 白基底 + 自定义白键
--     · 变回非强调色（开关关闭）-> 禁用渐变，交还库按原配色渲染
--   同时覆盖运行时新增控件、主题回写、换背景后的配色刷新。
-- ============================================================
function DefaultThemeBackground:SyncDynamicGradients()
    local Lib = self.Library
    if not (self.EnableGradient and Lib and Lib.Registry and Lib.Scheme) then return end
    if not (Instance and Instance.new) then return end

    local White = self:GetGradientWhite()
    if not White then return end
    local IconRot = self.GradientRotation

    -- 切主题 / 换背景会整表替换 Library.Scheme，自定义键 IconGradientBase 会一起丢。
    --   丢了之后，运行时新开启的开关只能拿到 AccentColor 当基底，
    --   渐变一叠上去就被压成发黑的一坨（同一个开关一半亮一半暗的元凶）。这里每轮补回。
    if Lib.Scheme.IconGradientBase ~= White then
        Lib.Scheme.IconGradientBase = White
    end

    -- 先算签名（便宜）：主题色/配置没变就复用缓存的 ColorSequence，不再每轮新建。
    local IconSig   = self:StopsSignature()        -- 青蓝固定 + 45 度
    local AccentSig = self:AccentStopsSignature()  -- 主题色 + 参数 + 角度
    local IconChanged   = (IconSig   ~= self._IconStopsSignature)
    local AccentChanged = (AccentSig ~= self._AccentStopsSignature)
    self._IconStopsSignature   = IconSig
    self._AccentStopsSignature = AccentSig

    -- 图标路：青 -> 蓝 -> 靛 固定渐变（缓存）
    local IconStops = self._CachedIconStops
    if IconChanged or not IconStops then
        IconStops = self:GetGradientStops()
        self._CachedIconStops = IconStops
    end
    if not IconStops then return end

    -- 强调色路：主题色自适应（开关底色 / 滑块填充 / 通知进度条 / 运行时新增），缓存
    --   方向不写死：每个对象按自己的形状取（开关竖向、细长条水平），见 GetAccentRotationFor
    local AccentStops = self._CachedAccentStops
    if AccentChanged or not AccentStops then
        AccentStops = self:GetAccentGradientStops()
        self._CachedAccentStops = AccentStops
    end

    -- 已 Dismiss/Destroy 的临时控件（通知进度条等）跳过：库 Registry 不自动清理死对象，
    --   不处理会反复为"尸体"建渐变并永不清登记（内存泄漏）。
    local function IsDead(O)
        -- 【真机根因】Roblox 的 Instance 是 userdata，读不存在的自定义成员
        -- （旧写法里的 O._destroyed）会直接抛错，pcall 吞掉后 Ok=false -> 判死，
        -- 整批真实控件被误杀，渐变一个都不建。这份文件里开关全靠 SyncDynamicGradients
        -- 接管，所以默认开启和运行时开启的开关都没有渐变。
        -- 只读 Instance 一定存在的标准属性 ClassName：读得出来就一律视为存活。
        -- 仅在清理登记时调用（次数极少），宽进不误杀。
        if O == nil then return true end
        local Ok = pcall(function() return O.ClassName end)
        return not Ok
    end
    -- 1) 强调色底色对象（含本次刚开启的开关 / 运行时通知进度条 / 滑块填充）
    --    -> 补主题色自适应渐变 + 白基底 + 自定义白键
    for Inst, Props in pairs(Lib.Registry) do
        -- 不再对每个对象 pcall 判活：Registry 里都是库登记的控件，全量扫描上百个对象、
        -- 每个一次 pcall 很费。个别已销毁对象由下面的 pcall 兜底，不会中断整批。
        if Props then
        pcall(function()
        local Idx = Props.BackgroundColor3
        if Idx == "AccentColor" or Idx == "IconGradientBase" then
            local IsNew = (Idx == "AccentColor")
            local Rot = self:GetAccentRotationFor(Inst)
            local OkFind, Grad = pcall(function() return Inst:FindFirstChild("YXAccentGradient") end)
            if not (OkFind and Grad) then
                pcall(function()
                    local G = Instance.new("UIGradient")
                    G.Name = "YXAccentGradient"
                    G.Rotation = Rot
                    G.Color = AccentStops
                    G.Parent = Inst
                    table.insert(self._GradientObjects, G)
                end)
                OkFind, Grad = pcall(function() return Inst:FindFirstChild("YXAccentGradient") end)
                if not (OkFind and Grad) then Grad = nil end
            end
            if Grad and AccentStops then
                Grad.Enabled = true
                -- 强调色每帧用实时主题色：新建即写入，主题/配置变化(AccentChanged)统一刷新
                if IsNew or AccentChanged then
                    Grad.Color = AccentStops
                end
                -- 窗口缩放 / 首次布局后尺寸才有效，每轮校正方向
                if Grad.Rotation ~= Rot then
                    Grad.Rotation = Rot
                end
                if Inst.BackgroundColor3 ~= White then Inst.BackgroundColor3 = White end
                -- 不再把 Registry 索引改写成自定义键：库的 Toggle:Display 每帧会把开关
                -- 底色索引改回 "AccentColor"，改写它只会反复互踩。不透明 UIGradient 会完整
                -- 覆盖 BackgroundColor3，所以无需抢白基底，库按原索引渲染底色即可，渐变照样显示。
                self._DynamicTargets[Inst] = true
            end
        end
        end)
        end
    end

    -- 2) 之前接管过、现在变回非强调色（开关关闭 / 滑块 disabled / 进度条消失）
    --    -> 禁用渐变，交还库按原配色渲染
    for Inst in pairs(self._DynamicTargets) do
        local Props = Lib.Registry[Inst]
        if not Props then
            self._DynamicTargets[Inst] = nil
        else
            local Idx = Props.BackgroundColor3
            if Idx == nil then
                -- 非底色对象（图标等）不再跟踪，但不动它的渐变
                self._DynamicTargets[Inst] = nil
            elseif Idx ~= "IconGradientBase" and Idx ~= "AccentColor" then
                local OkFind, Grad = pcall(function()
                    return Inst:FindFirstChild("YXAccentGradient") or Inst:FindFirstChild("YXThemeGradient")
                end)
                if OkFind and Grad then Grad.Enabled = false end
                local C = (type(Idx) == "string") and Lib.Scheme[Idx] or nil
                if C then
                    pcall(function()
                        if Inst.BackgroundColor3 == White then Inst.BackgroundColor3 = C end
                    end)
                end
                self._DynamicTargets[Inst] = nil
            end
        end
    end

    -- 3) 配置变化 -> 刷新所有已建渐变（图标 / 强调色分别按各自签名）
    if IconChanged then
        for _, Grad in ipairs(self._GradientObjects) do
            if Grad.Name == "YXThemeGradient" then
                Grad.Color = IconStops
                Grad.Rotation = IconRot
            end
        end
    end
    if AccentChanged then
        for _, Grad in ipairs(self._GradientObjects) do
            if Grad.Name == "YXAccentGradient" then
                Grad.Color = AccentStops
                local OkP, Parent = pcall(function() return Grad.Parent end)
                Grad.Rotation = self:GetAccentRotationFor(OkP and Parent or nil)
            end
        end
    end
end


-- ============================================================
-- 按钮底色渐变（填充渐变，作用于按钮本体；不是 UIStroke 描边）
--
--   为什么不能按 Registry 标签抓：库里 "MainColor" 有几十处，分组框、
--   输入框、下拉框、标签按钮、Toggle 外层按钮都用它，一律接管会染花半个 UI。
--   所以走库的一等公民对象模型：
--       Library.Tabs → Tab.Groupboxes / Tabboxes / DependencyGroupboxes
--                    → Groupbox.Elements → Type=="Button" / "SubButton" → .Base
--   动态扫描，运行时新增的按钮（含 SaveManager/ThemeManager 生成的）也会自动纳入。
--
--   为什么跟着主题色走：按钮渐变不再写死配色，每 0.05s 读一次
--   Library.Scheme.AccentColor（换背景 / ThemeManager 切主题都会改它），
--   由它实时生成同色相的垂直渐变；签名变化即刷新所有按钮。
--
--   方向规则（ButtonGradientAngle = 180，垂直「上 -> 下」）：
--     主题色较亮       -> 上 = 主题色(限亮)，下 = 加深   =>「向下加深」
--     主题色偏黑(近黑) -> 上 = 提亮成灰，下 = 主题色加深 =>「向上变亮」
--   两端都经 YXClampLuminance 限亮，保证按钮白色文字对比度 >= 4.5。
--
--   为什么独立：用独立白键 ButtonGradientBase、独立对象表 _ButtonTargets /
--   _ButtonGradientObjects，避免和开关同步器(_DynamicTargets / _GradientObjects)
--   互相接管或误禁用；库 UpdateColorsUsingRegistry 回写时会按白键刷成白色，
--   不会把渐变冲成纯色。
-- ============================================================
-- 取「控件填充渐变基色」：跟随主题强调色（Scheme.AccentColor），切主题自动换色，
--   再经 YXMistTint 做雾蓝调和，避免青绿偏色、并和背景图的雾蓝灰协调。
--   ControlAccent 填 {R,G,B} 可强制固定；MistTint=false 可关闭调和。
function DefaultThemeBackground:GetThemeColor()
    local Base
    local C = self.ControlAccent
    if type(C) == "table" and C[1] then
        Base = { (C[1] or 0) / 255, (C[2] or 0) / 255, (C[3] or 0) / 255 }
    else
        local Lib = self.Library
        Base = YXReadColor3(Lib and Lib.Scheme and Lib.Scheme.AccentColor)
        if not Base then
            -- 回退：当前背景配套的 Accent
            local P = self.Palettes[self.LastIndex or 1] or self.Palettes[1]
            if P and P.Accent then
                Base = { (P.Accent[1] or 0) / 255, (P.Accent[2] or 0) / 255, (P.Accent[3] or 0) / 255 }
            else
                Base = { 0.20, 0.40, 0.70 }
            end
        end
    end
    if self.MistTint ~= false then Base = YXMistTint(Base) end
    return Base
end

-- 通用/CSS 渐变角度 -> Roblox UIGradient.Rotation
function DefaultThemeBackground:GetButtonGradientRotation()
    local Override = self.ButtonGradientRotationOverride
    if type(Override) == "number" then return Override % 360 end
    local A = tonumber(self.ButtonGradientAngle) or 180
    return (A - 90) % 360
end

-- 强调色填充渐变角度（开关 / 滑块 / 进度条）；默认水平(0)，可与按钮视觉分离
function DefaultThemeBackground:GetAccentGradientRotation()
    local A = tonumber(self.AccentGradientAngle)
    if A == nil then return self.GradientRotation end
    return (tonumber(A) or 0) % 360
end

-- 实际角度：开关是矮胖胶囊，圆点盖住右半边，横向渐变只剩左半截 -> 看不出；
--   这类控件改竖向，露出来的左半区正好走完 亮 -> 暗 的整条渐变。
--   滑块填充 / 通知进度条是细长条，用配置的基础角度（当前 45° 斜向）。
function DefaultThemeBackground:GetAccentRotationFor(Inst)
    local Base = self:GetAccentGradientRotation()
    if not self.AccentGradientAutoOrient or not Inst then return Base end
    local Ok, Size = pcall(function() return Inst.AbsoluteSize end)
    if Ok and Size and Size.X ~= nil and Size.Y ~= nil then
        local SX = tonumber(Size.X) or 0
        local SY = tonumber(Size.Y) or 0
        -- 高度够、且宽高比接近方形/矮胖 => 开关类，竖向
        if SY >= 10 and SX > 0 and SX <= SY * 2.2 then
            return 90
        end
    end
    return Base
end

-- 依据当前主题色生成按钮渐变（垂直 上 -> 下）
--   亮色：上 = 主题色(限亮)，下 = 加深         -> 向下加深
--   偏黑：上 = 提亮(黑->灰)，下 = 主题色加深   -> 向上变亮
function DefaultThemeBackground:GetButtonGradientStops(DarkAmtOverride, SafeLumOverride)
    local function Num(V, Def)
        V = tonumber(V)
        if not V then return Def end
        if V < 0 then return 0 end
        if V > 1 then return 1 end
        return V
    end
    local DarkAmt   = Num(DarkAmtOverride or self.ButtonGradientDarkAmount, 0.45)
    local LightAmt  = Num(self.ButtonGradientLightAmount, 0.45)
    local Threshold = Num(self.ButtonGradientDarkThreshold, 0.18)
    local SafeLum   = Num(SafeLumOverride or self.ButtonGradientTextSafeLum, 0.15)
    local Overall   = tonumber(self.ButtonGradientBrightness) or 1.0
    if Overall < 0 then Overall = 0 end

    local Theme  = self:GetThemeColor()
    local IsDark = (YXLuminance(Theme) < Threshold)
    local Base   = YXClampLuminance(Theme, SafeLum)

    local Bottom = { Base[1] * DarkAmt, Base[2] * DarkAmt, Base[3] * DarkAmt }
    local Top
    if IsDark then
        -- 黑 -> 灰：朝白色方向提亮，再限亮保证白字可读
        local Lift = {
            Base[1] + (1 - Base[1]) * LightAmt,
            Base[2] + (1 - Base[2]) * LightAmt,
            Base[3] + (1 - Base[3]) * LightAmt,
        }
        Top = YXClampLuminance(Lift, SafeLum)
    else
        Top = Base
    end

    local A = { Top[1] * Overall, Top[2] * Overall, Top[3] * Overall }
    local B = { Bottom[1] * Overall, Bottom[2] * Overall, Bottom[3] * Overall }
    local Mid = { (A[1] + B[1]) / 2, (A[2] + B[2]) / 2, (A[3] + B[3]) / 2 }
    local function ToColor(C)
        return RGB({
            math.floor(C[1] * 255 + 0.5),
            math.floor(C[2] * 255 + 0.5),
            math.floor(C[3] * 255 + 0.5),
        })
    end
    local Ok, Stops = pcall(function()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, ToColor(A)),
            ColorSequenceKeypoint.new(0.5, ToColor(Mid)),
            ColorSequenceKeypoint.new(1.0, ToColor(B)),
        })
    end)
    return Ok and Stops or nil
end

-- 强调色填充（开关 / 滑块 / 进度条）用的渐变：
--   算法与按钮完全一致（亮色向下加深、偏黑向上提亮），只是加深幅度单独配置，
--   因为这些控件没有白色文字，不需要压到按钮那么暗。
function DefaultThemeBackground:GetAccentGradientStops()
    return self:GetButtonGradientStops(self.AccentGradientDarkAmount, self.AccentGradientSafeLum)
end

function DefaultThemeBackground:ButtonStopsSignature()
    local C = self:GetThemeColor()
    return string.format("%.4f,%.4f,%.4f", C[1], C[2], C[3])
        .. "#A" .. tostring(self.ButtonGradientAngle)
        .. "#O" .. tostring(self.ButtonGradientRotationOverride)
        .. "#D" .. tostring(self.ButtonGradientDarkAmount)
        .. "#L" .. tostring(self.ButtonGradientLightAmount)
        .. "#T" .. tostring(self.ButtonGradientDarkThreshold)
        .. "#S" .. tostring(self.ButtonGradientTextSafeLum)
        .. "#B" .. tostring(self.ButtonGradientBrightness)
end

-- 收集所有「按钮底色实例」；白名单字段递归，避免遍历到 Connections/Tween 等无关表
function DefaultThemeBackground:CollectButtonBases()
    local Lib = self.Library
    local Found, Seen = {}, {}
    if not (Lib and Lib.Registry and type(Lib.Tabs) == "table") then return Found end

    local Fields = { "Elements", "Groupboxes", "Tabboxes", "Tabs",
                     "DependencyGroupboxes", "SubButton" }

    local function Walk(Node, Depth)
        if type(Node) ~= "table" or Depth > 8 or Seen[Node] then return end
        Seen[Node] = true

        if (Node.Type == "Button" or Node.Type == "SubButton") and Node.Base then
            local Base = Node.Base
            local Props = Lib.Registry[Base]
            if Props then
                local Idx = Props.BackgroundColor3
                if Idx == "MainColor" or Idx == "BackgroundColor"
                   or Idx == "ButtonGradientBase" then
                    Found[Base] = true
                end
            end
        end

        for _, Key in ipairs(Fields) do
            local Child = Node[Key]
            if type(Child) == "table" then
                if Child.Type ~= nil then
                    Walk(Child, Depth + 1)             -- 单个对象（如 SubButton）
                else
                    for _, V in pairs(Child) do         -- 容器（数组或字典）
                        if type(V) == "table" then Walk(V, Depth + 1) end
                    end
                end
            end
        end
    end

    for _, V in pairs(Lib.Tabs) do
        if type(V) == "table" then Walk(V, 0) end
    end
    return Found
end

function DefaultThemeBackground:SyncButtonGradients()
    local Lib = self.Library
    if not (self.EnableButtonGradient and Lib and Lib.Registry and Lib.Scheme) then return end
    if not (Instance and Instance.new) then return end
    local White = self:GetGradientWhite()
    if not White then return end
    local Rot = self:GetButtonGradientRotation()
    Lib.Scheme.ButtonGradientBase = White

    local Signature = self:ButtonStopsSignature()
    local ConfigChanged = (Signature ~= self._ButtonSignature)
    self._ButtonSignature = Signature

    -- 色标缓存：配置/主题未变就复用，不再每轮新建 ColorSequence
    local Stops = self._CachedButtonStops
    if ConfigChanged or not Stops then
        Stops = self:GetButtonGradientStops()
        self._CachedButtonStops = Stops
    end
    if not Stops then return end

    -- 结构遍历（递归整个 Tabs）是最大热点：缓存结果，每 0.5s 才重建一次
    local Now = os.clock()
    local Bases = self._CachedButtonBases
    if (not Bases) or (Now - (self._ButtonBasesAt or 0) >= 0.5) then
        Bases = self:CollectButtonBases()
        self._CachedButtonBases = Bases
        self._ButtonBasesAt = Now
    end

    for Base in pairs(Bases) do
        local Props = Lib.Registry[Base]
        if Props then
            local Idx = Props.BackgroundColor3
            if Idx == "BackgroundColor" then
                -- 按钮被 SetDisabled(true)：禁用渐变，把底色交还库按 BackgroundColor 渲染
                local OkF, G = pcall(function() return Base:FindFirstChild("YXButtonGradient") end)
                if OkF and G then G.Enabled = false end
                pcall(function()
                    if Base.BackgroundColor3 == White then
                        Base.BackgroundColor3 = Lib.Scheme.BackgroundColor
                    end
                end)
                self._ButtonTargets[Base] = nil
            else
                local OkF, G = pcall(function() return Base:FindFirstChild("YXButtonGradient") end)
                if not (OkF and G) then
                    pcall(function()
                        local Grad = Instance.new("UIGradient")
                        Grad.Name = "YXButtonGradient"
                        Grad.Rotation = Rot
                        Grad.Color = Stops
                        Grad.Parent = Base
                        table.insert(self._ButtonGradientObjects, Grad)
                    end)
                    OkF, G = pcall(function() return Base:FindFirstChild("YXButtonGradient") end)
                    if not (OkF and G) then G = nil end
                end
                if G then
                    G.Enabled = true
                    if ConfigChanged then
                        G.Color = Stops
                        G.Rotation = Rot
                    end
                    pcall(function()
                        if Base.BackgroundColor3 ~= White then Base.BackgroundColor3 = White end
                    end)
                    if Idx ~= "ButtonGradientBase" then
                        self:RememberDynamicBackup(Base, "BackgroundColor3", Idx)
                        Props.BackgroundColor3 = "ButtonGradientBase"
                    end
                    self._ButtonTargets[Base] = true
                end
            end
        end
    end

    -- 已接管的按钮若已不在对象模型（被销毁/移除）或标签被外部改走，清登记
    for Base in pairs(self._ButtonTargets) do
        if not Bases[Base] then
            local Props = Lib.Registry[Base]
            if not Props or Props.BackgroundColor3 ~= "ButtonGradientBase" then
                self._ButtonTargets[Base] = nil
            end
        end
    end
end


-- ============================================================
-- 下拉菜单 / 滑块轨道渐变（第三路，与图标-强调色、按钮完全隔离）
--
--   为什么不能按 Registry 键抓：
--     下拉触发按钮、滑块轨道、分组框、输入框、Tab 按钮全都注册成 "MainColor"；
--     下拉面板注册成 "BackgroundColor"（窗口背景、右键菜单也是它）。
--     一律接管会染花半个 UI。所以走对象模型：
--        Library.Tabs → ... → Elements → Type=="Dropdown" → .Container（触发按钮）
--                                                       → .Menu.Menu（展开面板）
--                                       Type=="Slider"  → .Holder 里的 TextButton（轨道）
--   为什么用渐变：
--     库只给单色。"MainColor" 的轨道和"BackgroundColor"的面板都是很深的底色，
--     直接把主题色铺上去会整块变蓝、白字发灰。所以这里把主题色当"染色剂"，
--     按比例混进背景色：面板/轨道仍是深色，但一眼能看出是当前主题的色系。
-- ============================================================

-- 面板底色：下拉菜单 / 滑块轨道的"底"，主题色只往上混
function DefaultThemeBackground:GetPanelBaseColor()
    local Lib = self.Library
    local Read = YXReadColor3(Lib and Lib.Scheme and Lib.Scheme.BackgroundColor)
    if Read then return Read end
    local P = self.Palettes[self.LastIndex or 1] or self.Palettes[1]
    if P and P.Background then
        return { (P.Background[1] or 0) / 255, (P.Background[2] or 0) / 255, (P.Background[3] or 0) / 255 }
    end
    return { 0.05, 0.07, 0.12 }
end

-- 上 / 中 / 下 三色标（中间取两端均值，避免两色标在短控件上出现断带）
function DefaultThemeBackground:MakeStops(Top, Bottom)
    local function ToColor(C)
        local function B(V)
            if V < 0 then return 0 elseif V > 1 then return 1 end
            return V
        end
        return RGB({
            math.floor(B(C[1]) * 255 + 0.5),
            math.floor(B(C[2]) * 255 + 0.5),
            math.floor(B(C[3]) * 255 + 0.5),
        })
    end
    local Mid = { (Top[1] + Bottom[1]) / 2, (Top[2] + Bottom[2]) / 2, (Top[3] + Bottom[3]) / 2 }
    local Ok, Seq = pcall(function()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, ToColor(Top)),
            ColorSequenceKeypoint.new(0.5, ToColor(Mid)),
            ColorSequenceKeypoint.new(1.0, ToColor(Bottom)),
        })
    end)
    return Ok and Seq or nil
end

-- 下拉展开面板：深色板 + 主题色调，上亮下暗
function DefaultThemeBackground:GetMenuGradientStops()
    local function Num(V, Def)
        V = tonumber(V); if not V then return Def end
        if V < 0 then return 0 elseif V > 1 then return 1 end
        return V
    end
    local Tint = Num(self.DropdownMenuTint, 0.35)
    local Dark = Num(self.DropdownMenuDarkAmount, 0.55)
    local Bg    = self:GetPanelBaseColor()
    local Theme = self:GetThemeColor()
    local Top    = YXMix(Bg, Theme, Tint)
    local DarkBg = { Bg[1] * Dark, Bg[2] * Dark, Bg[3] * Dark }
    local Bottom = YXMix(DarkBg, Theme, Tint * 0.40)
    return self:MakeStops(Top, Bottom)
end

-- 滑块轨道：同色系，左亮右暗（横条方向）
function DefaultThemeBackground:GetSliderTrackStops()
    local function Num(V, Def)
        V = tonumber(V); if not V then return Def end
        if V < 0 then return 0 elseif V > 1 then return 1 end
        return V
    end
    local Tint = Num(self.SliderTrackTint, 0.34)
    local Dark = Num(self.SliderTrackDarkAmount, 0.45)
    local Bg    = self:GetPanelBaseColor()
    local Theme = self:GetThemeColor()
    local Top    = YXMix(Bg, Theme, Tint)
    local DarkBg = { Bg[1] * Dark, Bg[2] * Dark, Bg[3] * Dark }
    local Bottom = YXMix(DarkBg, Theme, Tint * 0.45)
    return self:MakeStops(Top, Bottom)
end

function DefaultThemeBackground:ElementStopsSignature()
    local C = self:GetThemeColor()
    local B = self:GetPanelBaseColor()
    return string.format("%.4f,%.4f,%.4f", C[1], C[2], C[3])
        .. string.format("|%.4f,%.4f,%.4f", B[1], B[2], B[3])
        .. "#DT" .. tostring(self.DropdownMenuTint)
        .. "#DD" .. tostring(self.DropdownMenuDarkAmount)
        .. "#DA" .. tostring(self.DropdownGradientAngle)
        .. "#MA" .. tostring(self.DropdownMenuAngle)
        .. "#TT" .. tostring(self.SliderTrackTint)
        .. "#TD" .. tostring(self.SliderTrackDarkAmount)
        .. "#TA" .. tostring(self.SliderTrackAngle)
end

-- 收集三个目标集合：下拉触发按钮 / 下拉展开面板 / 滑块轨道
function DefaultThemeBackground:CollectElementGradients()
    local Lib = self.Library
    local Out = { Dropdown = {}, Menu = {}, Track = {} }
    if not (Lib and Lib.Registry and type(Lib.Tabs) == "table") then return Out end

    local Seen = {}
    local Fields = { "Elements", "Groupboxes", "Tabboxes", "Tabs",
                     "DependencyGroupboxes", "SubButton" }

    -- Holder 里第一个 TextButton 就是控件主体（Slider 的轨道 Bar / Dropdown 的触发按钮）
    local function FirstButton(Holder)
        if type(Holder) ~= "table" then return nil end
        local Ok, R = pcall(function() return Holder:FindFirstChildWhichIsA("TextButton") end)
        if Ok and R then return R end
        local OkC, Kids = pcall(function() return Holder:GetChildren() end)
        if OkC and type(Kids) == "table" then
            for _, K in ipairs(Kids) do
                if K.ClassName == "TextButton" then return K end
            end
        end
        return nil
    end

    local function Walk(Node, Depth)
        if type(Node) ~= "table" or Depth > 8 or Seen[Node] then return end
        Seen[Node] = true

        if Node.Type == "Dropdown" then
            if Node.Container then Out.Dropdown[Node.Container] = true end
            local MT = Node.Menu
            if type(MT) == "table" and MT.Menu then Out.Menu[MT.Menu] = true end
        elseif Node.Type == "Slider" then
            local Bar = FirstButton(Node.Holder)
            if Bar then Out.Track[Bar] = true end
        end

        for _, Key in ipairs(Fields) do
            local Child = Node[Key]
            if type(Child) == "table" then
                if Child.Type ~= nil then
                    Walk(Child, Depth + 1)          -- 单个对象（如 SubButton）
                else
                    for _, V in pairs(Child) do     -- 容器（数组或字典）
                        if type(V) == "table" then Walk(V, Depth + 1) end
                    end
                end
            end
        end
    end

    for _, V in pairs(Lib.Tabs) do
        if type(V) == "table" then Walk(V, 0) end
    end
    return Out
end

function DefaultThemeBackground:SyncElementGradients()
    local Lib = self.Library
    if not (Lib and Lib.Registry and Lib.Scheme) then return end
    if not (Instance and Instance.new) then return end

    local WantDrop  = self.EnableDropdownGradient and true or false
    local WantTrack = self.EnableSliderTrackGradient and true or false

    local White = self:GetGradientWhite()
    if not White then return end
    -- 白键：让渐变完整呈现；切主题会整表替换 Scheme，每轮补回
    if Lib.Scheme.YXElemBase ~= White then Lib.Scheme.YXElemBase = White end

    local Sig = self:ElementStopsSignature()
    local Changed = (Sig ~= self._ElemSignature)
    self._ElemSignature = Sig

    -- 结构遍历（递归整个 Tabs）缓存 + 降频：每 0.5s 才重建一次
    local Now = os.clock()
    local Sets = self._CachedElemSets
    if (not Sets) or (Now - (self._ElemSetsAt or 0) >= 0.5) then
        Sets = self:CollectElementGradients()
        self._CachedElemSets = Sets
        self._ElemSetsAt = Now
    end

    -- 色标缓存：签名未变就复用，避免每轮新建 3 个 ColorSequence
    local DropStops  = self._CachedDropStops
    local MenuStops  = self._CachedMenuStops
    local TrackStops = self._CachedTrackStops
    if Changed or not (DropStops and MenuStops and TrackStops) then
        DropStops  = self:GetButtonGradientStops()   -- 触发按钮有白字，沿用按钮那套限亮
        MenuStops  = self:GetMenuGradientStops()
        TrackStops = self:GetSliderTrackStops()
        self._CachedDropStops  = DropStops
        self._CachedMenuStops  = MenuStops
        self._CachedTrackStops = TrackStops
    end

    -- 通用/CSS 角度 -> Roblox：180(上->下)=90，0(下->上)=270
    local function CSSDeg(A, Def)
        local V = tonumber(A); if not V then V = Def end
        return (V - 90) % 360
    end
    local DropRot  = CSSDeg(self.DropdownGradientAngle, 180)
    local MenuRot  = CSSDeg(self.DropdownMenuAngle, 180)
    local TrackRot = (tonumber(self.SliderTrackAngle) or 0) % 360

    local function IsDead(O)
        -- 【真机根因】Roblox 的 Instance 是 userdata，读不存在的自定义成员
        -- （旧写法里的 O._destroyed）会直接抛错，pcall 吞掉后 Ok=false -> 判死，
        -- 整批真实控件被误杀，渐变一个都不建。这份文件里开关全靠 SyncDynamicGradients
        -- 接管，所以默认开启和运行时开启的开关都没有渐变。
        -- 只读 Instance 一定存在的标准属性 ClassName：读得出来就一律视为存活。
        -- 仅在清理登记时调用（次数极少），宽进不误杀。
        if O == nil then return true end
        local Ok = pcall(function() return O.ClassName end)
        return not Ok
    end

    local function Handle(Inst, GName, Stops, Rot, Want)
        if not Inst or IsDead(Inst) then return end
        local Props = Lib.Registry[Inst]
        if not Props then return end

        local OkF, Grad = pcall(function() return Inst:FindFirstChild(GName) end)
        local WasNew = false
        if not (OkF and Grad) then
            if Want and Stops then
                pcall(function()
                    local G = Instance.new("UIGradient")
                    G.Name = GName
                    G.Rotation = Rot
                    G.Color = Stops
                    G.Parent = Inst
                    table.insert(self._ElemGradientObjects, G)
                end)
                OkF, Grad = pcall(function() return Inst:FindFirstChild(GName) end)
                if OkF and Grad then WasNew = true else Grad = nil end
            else
                Grad = nil
            end
        end

        if not (Want and Stops and Grad) then
            -- 关闭 / 无渐变：停用渐变，并把注册键、底色一并交还库按原配色渲染
            if Grad then Grad.Enabled = false end
            local Origin = self._ElemOrigins[Inst]
            if Origin and Props.BackgroundColor3 == "YXElemBase" then
                Props.BackgroundColor3 = Origin
                local C = (type(Origin) == "string") and Lib.Scheme[Origin] or nil
                if C then pcall(function() Inst.BackgroundColor3 = C end) end
            end
            self._ElemTargets[Inst] = nil
            self._ElemOrigins[Inst] = nil
            return
        end

        -- 与「按钮」那路一致的双保险：白基底 + 自定义白键。
        --   库的 UpdateColorsUsingRegistry / 主题切换会把底色刷回 MainColor /
        --   BackgroundColor（深色）；底色不是白的时，渐变与底色叠加会发暗、
        --   看起来就是一块纯色平底。把注册键改成指向白色的 "YXElemBase"
        --   （Lib.Scheme.YXElemBase 每轮补回白色），库回写时也会刷成白色，渐变才稳定可见。
        --   下拉触发条 / 面板 / 滑块轨道的注册键不会被库像 Toggle:Display 那样反复改回，
        --   所以这里改写是安全的，不会互踩。
        local Idx = Props.BackgroundColor3
        if Idx ~= "YXElemBase" then
            self._ElemOrigins[Inst] = Idx
            Props.BackgroundColor3 = "YXElemBase"
        end
        pcall(function()
            if Inst.BackgroundColor3 ~= White then Inst.BackgroundColor3 = White end
        end)

        Grad.Enabled = true
        if WasNew or Changed then Grad.Color = Stops end   -- 创建即写入；主题/背景变化统一刷新
        if Grad.Rotation ~= Rot then Grad.Rotation = Rot end
        self._ElemTargets[Inst] = GName
    end

    for Inst in pairs(Sets.Dropdown) do
        Handle(Inst, "YXDropdownGradient", DropStops, DropRot, WantDrop)
    end
    for Inst in pairs(Sets.Menu) do
        Handle(Inst, "YXMenuGradient", MenuStops, MenuRot, WantDrop)
    end
    for Inst in pairs(Sets.Track) do
        Handle(Inst, "YXSliderTrackGradient", TrackStops, TrackRot, WantTrack)
    end

    -- 已接管的实例若被销毁 / 移出对象模型，清登记（库 Registry 不自动清理死对象）
    for Inst in pairs(self._ElemTargets) do
        if IsDead(Inst) then
            self._ElemTargets[Inst] = nil
            self._ElemOrigins[Inst] = nil
        end
    end
end

function DefaultThemeBackground:InstallGradientSync()
    if not ((self.EnableGradient or self.EnableButtonGradient
             or self.EnableDropdownGradient or self.EnableSliderTrackGradient) and self.Library) then return end
    if self._GradientSyncConn then return end
    local OkSvc, RunService = pcall(function() return game:GetService("RunService") end)
    if not (OkSvc and RunService and RunService.Heartbeat) then return end
    local Module = self
    local Acc = 0
    -- 渐变是静态贴图，无需 20Hz 刷新；默认降到约 8Hz，开关/主题响应仍在 0.12s 内，无感。
    -- 配合下方色标/结构缓存，整体 CPU 占用大幅下降，缓解掉帧。可用 GradientSyncInterval 调整。
    local Interval = tonumber(self.GradientSyncInterval) or 0.12
    local OkConn, Conn = pcall(function()
        return RunService.Heartbeat:Connect(function(dt)
            Acc = Acc + (type(dt) == "number" and dt or 0.016)
            if Acc < Interval then return end
            Acc = 0
            pcall(function() Module:SyncDynamicGradients() end)
            pcall(function() Module:SyncButtonGradients() end)
            pcall(function() Module:SyncElementGradients() end)
        end)
    end)
    if OkConn then self._GradientSyncConn = Conn end
    -- 安装后三路都立即跑一次，启动即生效（不必等首个心跳）：
    --   默认开启的开关、滑块填充也要在首帧就带上渐变。
    pcall(function() self:SyncDynamicGradients() end)
    pcall(function() self:SyncButtonGradients() end)
    pcall(function() self:SyncElementGradients() end)
end

--// 换图 //--
function DefaultThemeBackground:Select(Index)
    local Count = #self.Images
    if Count == 0 then return false, "图片列表为空" end
    if type(Index) ~= "number" then return false, "索引必须是数字" end
    Index = math.max(1, math.min(Count, math.floor(Index)))

    self.LastIndex = Index
    self.LastUrl = self.Images[Index]
    self:ApplyUrl(self.LastUrl)
    if self.ApplyPalette then self:ApplyPaletteFor(Index) end
    self:SaveSelection(Index)
    if type(self.OnSelect) == "function" then pcall(self.OnSelect, Index, self.LastUrl) end
    return true, self.LastUrl
end

function DefaultThemeBackground:Roll()
    local Lib = self.Library
    if not Lib then return false, "尚未调用 SetLibrary" end
    local Count = #self.Images
    if Count == 0 then return false, "图片列表为空" end

    local Index
    if Count == 1 then
        Index = 1
    elseif self.AvoidRepeat and self.LastIndex then
        Index = RandomInt(1, Count - 1)
        if Index >= self.LastIndex then Index = Index + 1 end
    else
        Index = RandomInt(1, Count)
    end

    local Url = self.Images[Index]
    self.LastIndex = Index
    self.LastUrl = Url
    self:ApplyUrl(Url)
    if self.ApplyPalette then self:ApplyPaletteFor(Index) end
    self:SaveSelection(Index)
    if type(self.OnSelect) == "function" then pcall(self.OnSelect, Index, Url) end

    if self.NotifyOnSwitch and Lib.Notify then
        pcall(function()
            Lib:Notify({
                Title = self.NotifyTitle,
                Description = string.format("已切换背景图（第 %d / %d 张）", Index, Count),
                Time = 3,
            })
        end)
    end
    return true, Url
end

--// 挂载 //--
function DefaultThemeBackground:Enable()
    if self.Enabled then return self end
    assert(self.Library, "请先调用 SetLibrary(Library)")
    -- ThemeManager 可选：内嵌进 Library.lua 后由外部主脚本单独加载，这里可能拿不到。
    --   有则包装 ApplyTheme 实现「切主题自动回流背景/配色」，无则降级为仅启动套用背景。
    local HasTM = (self.ThemeManager and type(self.ThemeManager.ApplyTheme) == "function") and true or false

    self:InstallCacheOptimizer()
    self:InstallBackgroundTracker()

    -- 启动背景：优先上次保存的选择，否则用默认第 1 张（仅保留背景 1）
    local Startup = self:ReadSelection() or self.StartupImageIndex
    Startup = math.max(1, math.min(#self.Images, Startup))
    self.LastIndex = Startup
    self.LastUrl = self.Images[Startup]
    self:ApplyUrl(self.LastUrl)
    if self.ApplyPalette then self:ApplyPaletteFor(Startup) end
    self:SaveSelection(Startup)

    if HasTM then
    local Module = self
    local Original = self.ThemeManager.ApplyTheme
    self._OriginalApplyTheme = Original
    self._SkipFirstApply = (self.ThemeManager.AppliedToTab ~= true)

    self.ThemeManager.ApplyTheme = function(Manager, ThemeName, ...)
        local Results = table.pack(Original(Manager, ThemeName, ...))

        if Module.Enabled and type(ThemeName) == "string" and ThemeName ~= "" then
            local Previous = Module.LastAppliedTheme
            local IsFirst = (Previous == nil)
            local Changed = (Previous ~= ThemeName)
            local SkipFirst = IsFirst and Module._SkipFirstApply

            Module.LastAppliedTheme = ThemeName

            if Module:IsDefaultTheme(ThemeName) then
                -- 主题应用会把 BackgroundImage 清空（内置主题数据带 ""），贴回当前背景
                if Changed and not IsFirst then
                    -- 从别的主题「切回默认主题」：ThemeManager 刚用它自己的主题数据
                    -- 整表覆盖了 Scheme，必须强制把「背景 1」配色重新套回，否则回切后
                    -- 停留的是 ThemeManager 的默认主题配色，不是启动时那套默认配色。
                    pcall(function()
                        if Module.LastUrl then Module:ApplyUrl(Module.LastUrl) end
                        if Module.ApplyPalette then
                            Module:ApplyPaletteFor(Module.LastIndex, true)
                        end
                    end)
                elseif Changed and (not SkipFirst or Module.RollOnFirstApply) then
                    pcall(function() Module:Roll() end)
                elseif Module.LastUrl then
                    pcall(function()
                        Module:ApplyUrl(Module.LastUrl)
                        if Module.ApplyPalette then Module:ApplyPaletteFor(Module.LastIndex) end
                    end)
                end
            end

            -- 主题色刚变（切到别的主题 / 切回默认）立即重算各路渐变与白基底，
            -- 不必等下个 0.05s 心跳，切换瞬间配色就跟上。
            if Changed then
                pcall(function() Module:SyncDynamicGradients() end)
                pcall(function() Module:SyncElementGradients() end)
                pcall(function() Module:SyncButtonGradients() end)
            end
        end

        return table.unpack(Results, 1, Results.n)
    end
    end

    self.Enabled = true
    self:InstallGradientSync()
    return self
end

function DefaultThemeBackground:Disable()
    if not self.Enabled then return self end

    if self._GradientSyncConn then
        pcall(function() self._GradientSyncConn:Disconnect() end)
        self._GradientSyncConn = nil
    end

    if self.ThemeManager and self._OriginalApplyTheme then
        self.ThemeManager.ApplyTheme = self._OriginalApplyTheme
    end
    local Lib = self.Library
    local IM = Lib and Lib.ImageManager
    if IM and self._OriginalDownloadAsset then
        IM.DownloadAsset = self._OriginalDownloadAsset
    end
    if Lib and self._OriginalSetBackground then
        Lib.SetBackgroundImage = self._OriginalSetBackground
    end

    if self._SchemeBackup and Lib and Lib.Scheme then
        for Key, Value in pairs(self._SchemeBackup) do
            Lib.Scheme[Key] = Value
        end
        -- 自定义键原本可能不存在（备份值为 nil），pairs 遍历不到，需显式清除
        Lib.Scheme.IconColor = self._SchemeBackup.IconColor
        Lib.Scheme.IconGradientBase = nil
        if Lib.UpdateColorsUsingRegistry then
            pcall(Lib.UpdateColorsUsingRegistry, Lib)
        end
    end
    -- 无论是否走过 ApplyPaletteFor，都清掉自定义 Scheme 键（ApplyGradient 会设置它）
    if Lib and Lib.Scheme then
        Lib.Scheme.IconGradientBase = nil
        Lib.Scheme.ButtonGradientBase = nil
        Lib.Scheme.YXElemBase = nil
    end
    if Lib and Lib.Registry then
        for Inst, List in pairs(self._RegistryBackup) do
            if Lib.Registry[Inst] then
                for _, Entry in ipairs(List) do
                    Lib.Registry[Inst][Entry.Property] = Entry.Value
                end
            end
        end
    end
    -- 下拉触发按钮 / 面板 / 滑块轨道：白键换回原键（MainColor / BackgroundColor）
    if Lib and Lib.Registry then
        for Inst, Origin in pairs(self._ElemOrigins or {}) do
            local Props = Lib.Registry[Inst]
            if Props and Props.BackgroundColor3 == "YXElemBase" then
                Props.BackgroundColor3 = Origin
            end
        end
    end
    for _, Grad in ipairs(self._GradientObjects) do
        pcall(function() Grad:Destroy() end)
    end
    for _, Grad in ipairs(self._ButtonGradientObjects or {}) do
        pcall(function() Grad:Destroy() end)
    end
    for _, Grad in ipairs(self._ElemGradientObjects or {}) do
        pcall(function() Grad:Destroy() end)
    end
    -- 注册表已恢复，再回写一次，把白基底刷回各元素的原始配色
    if Lib and Lib.UpdateColorsUsingRegistry then
        pcall(Lib.UpdateColorsUsingRegistry, Lib)
    end

    self._OriginalApplyTheme = nil
    self._OriginalDownloadAsset = nil
    self._OriginalSetBackground = nil
    self._SchemeBackup = nil
    self._RegistryBackup = {}
    self._GradientObjects = {}
    self._CachedAssets = {}
    self._TargetsCollected = false
    self._IconsTinted = false
    self._DynamicTargets = {}
    self._StopsSignature = nil
    self._IconStopsSignature = nil
    self._AccentStopsSignature = nil
    self._ButtonTargets = {}
    self._ButtonGradientObjects = {}
    self._ButtonSignature = nil
    self._ElemTargets = {}
    self._ElemOrigins = {}
    self._ElemGradientObjects = {}
    self._ElemSignature = nil
    self._PaletteApplied = nil
    self.LastAppliedTheme = nil
    self.Enabled = false
    return self
end

local Bg = DefaultThemeBackground
Bg:SetLibrary(Library)
-- ==================== 模块定义结束 ====================

-- 「背景图片」选择下拉已移除：只保留背景 1，由 Bg:Enable() 自动套用，
--   不在「UI 设置」里再显示切换项。OnSelect 保持默认 nil（模块内部调用都有判空保护）。
-- [内嵌] Bg:Enable() -> 已移至 YXStart() 统一启动
-- 自动配置加载为可选：独立版由主脚本传入 SaveManager 时执行；
--   内嵌进 Library.lua 后无 SaveManager，跳过（自动配置由主脚本自行加载）。
if SaveManager then pcall(function() SaveManager:LoadAutoloadConfig() end) end

--    YXGradientBorder:Enable()          -- 窗口 + 标签页一起开（默认）
--    YXGradientBorder:Disable()         -- 全部关闭
--    YXGradientBorder:EnableTabs()      -- 只开标签页边框
--    YXGradientBorder:DisableTabs()     -- 只关标签页边框
--    YXGradientBorder:EnableWindow()    -- 只开窗口边框
--    YXGradientBorder:DisableWindow()   -- 只关窗口边框
--    YXGradientBorder:SetColors(Color3, Color3)   -- 端点 / 中点（覆盖默认的 亮青/浅青）
--    YXGradientBorder:SetSpeed(90)     -- 窗口渐变速度（度/秒）
--    YXGradientBorder:SetThickness(4)  -- 窗口描边粗细
--    YXGradientBorder:SetPulse(true)   -- 窗口描边呼吸
--    YXGradientBorder:SetTabSpeed(90)             -- 标签页渐变速度
--    YXGradientBorder:SetTabThickness(2, 3)       -- 未选中 / 选中粗细
--    YXGradientBorder:SetTabIdleTransparency(0.5) -- 未选中淡化程度
--    YXGradientBorder:SetTabRadius(8)             -- 圆角；传 nil 恢复自动跟随
--    YXGradientBorder:SetTabOnlyActive(true)      -- 只给选中的标签显示
--    YXGradientBorder:SetTabIncludeContent(true)  -- 连标签内容区也加
--    YXGradientBorder:EnableNotifs()   -- 只开通知流动渐变描边（Enable 时已自动开）
--    YXGradientBorder:DisableNotifs()  -- 只关通知描边
--    YXGradientBorder:SetNotifSpeed(90)       -- 通知渐变旋转速度
--    YXGradientBorder:SetNotifThickness(2)    -- 通知描边粗细
--  通知由库动态创建/销毁，模块每 0.2s 差量扫描 Library.Notifications，自动挂载与清理。
--  窗口 / 标签页 / 通知边框统一「跟随主题强调色 + 雾蓝调和」，切主题一起换色，不再写死青色。
--  也可直接改 YXGradientBorder.Tabs.xxx / Notifs.xxx（见下方配置表）后即生效。
-- ============================================================

local YXGradientBorder = (function(Library)
    local M = {}

    -- Library 由末尾 (...)(Library) 显式传入，避免 local 作用域歧义
    local RunService = game:GetService("RunService")

    -- ===== 窗口边框参数（v1 保持兼容）=====
    M.Radius       = 12     -- 与 Window:SetCornerRadius(12) 保持一致
    M.Thickness    = 4
    M.Transparency = 0
    M.Speed        = 120
    M.Pulse        = true
    M.Name         = "YXGradientBorder"
    -- 边框颜色默认跟随主题强调色（雾蓝调和），切主题自动换色。
    --   想固定颜色：把下面两行填成 Color3.fromRGB(...)，并把 FollowTheme 设为 false。
    --   也可运行时调 YXGradientBorder:SetColors(Color3, Color3) 临时覆盖。
    M.FollowTheme  = true   -- true = 边框跟随主题强调色；false = 用下面两个固定色
    M.EdgeColor    = nil    -- 端点：默认由主题色压暗得到
    M.MidColor     = nil    -- 中点：默认由主题色提亮得到的高光

    -- ===== 标签页边框参数 =====
    M.Tabs = {
        Enabled            = false,
        AutoEnable         = true,   -- Enable() 时自动一并开启标签页
        Radius             = nil,    -- nil = 自动跟随按钮自带 UICorner；填数字覆盖
        Thickness          = 2,      -- 未选中标签描边粗细
        ActiveThickness    = 3,      -- 选中标签描边粗细
        IdleTransparency   = 0.5,    -- 未选中标签描边淡化（0=实色 1=全隐）
        ActiveTransparency = 0,      -- 选中标签描边透明度
        Speed              = 120,    -- 标签渐变旋转速度（度/秒）
        OnlyActive         = false,  -- true = 只有选中的标签显示边框
        IncludeContent     = false,  -- true = 连 Tab.Container 内容区也加边框
        ContentThickness   = 2,
        ContentRadius      = 8,
        Name               = "YXGradientBorder_Tab",
    }

    -- ===== 通知边框参数（流动渐变描边，动态出现的通知自动挂上）=====
    M.Notifs = {
        Enabled        = false,
        AutoEnable     = true,   -- Enable() 时自动一并开启
        Radius         = nil,    -- nil = 自动跟随通知自带 UICorner
        Thickness      = 2,
        Transparency   = 0,
        Speed          = 120,    -- 渐变旋转速度（度/秒）
        Name           = "YXGradientBorder_Notif",
    }


    M.Enabled = false   -- 窗口边框状态（标签页状态见 M.Tabs.Enabled / M.Notifs.Enabled）

    -- ===== 运行时 =====
    local winFrame, winCorner, winStroke, winGrad = nil, nil, nil, nil
    local winConn, tabConn = nil, nil
    local winLast, tabLast, tabAngle, scanAcc = 0, 0, 0, 0
    -- Color 写入脏标记：buildSequence 按主题色缓存，引用不变就跳过 Roblox 属性写，
    --   避免每帧对全部标签/通知重写同一个 ColorSequence（仅旋转仍需每帧写动画）。
    local winLastSeq, tabLastSeq, notifLastSeq = nil, nil, nil
    local manualSeq = nil
    local tabItems = {}   -- [目标对象] = {frame, corner, stroke, grad, kind, tab}
    local notifItems = {} -- [通知 Holder] = {frame, corner, stroke, grad}
    local notifConn = nil
    local notifLast, notifAngle, notifScanAcc = 0, 0, 0

    local function clamp01(v)
        if v < 0 then return 0 elseif v > 1 then return 1 end
        return v
    end
    local function shade(c, factor)
        -- factor>1 提亮，<1 压暗；限制到 [0,1]
        return Color3.new(
            clamp01(c.R * factor),
            clamp01(c.G * factor),
            clamp01(c.B * factor)
        )
    end

    -- 读取主题强调色并做雾蓝调和（与控件、边框同一套取色），
    --   再经库自带的 GetBetterColor 微调。
    local function ReadAccentColor()
        local Base = YXThemeAccentRGB(Library, true)
        local Col = Color3.new(Base[1], Base[2], Base[3])
        local Better = Library and Library.GetBetterColor
        if type(Better) == "function" then
            local Ok, C = pcall(Better, Library, Col, -1)
            if Ok and C then return C end
        end
        return Col
    end



    -- 边框配色：跟随主题强调色（雾蓝调和），主题变化即重建序列，不再写死青色。
    --   端点 = 主题色压暗，中点 = 主题色提亮降饱和的高光；0 与 1 端点相同，旋转接缝平滑。
    --   窗口 / 标签页 / 通知三处每帧都取本函数返回值，主题一变三处一起更新。
    --   签名计算降频到 0.12s，平时直接返回缓存，不增加每帧开销。
    --   SetColors() 的 manualSeq 优先级最高，仍可运行时覆盖。
    local function BuildThemeColors()
        if M.FollowTheme == false then
            return M.EdgeColor or Color3.fromRGB(140, 180, 220),
                   M.MidColor  or Color3.fromRGB(190, 215, 240)
        end
        local Base = YXThemeAccentRGB(Library, true)
        local H, S, V = Color3.new(Base[1], Base[2], Base[3]):ToHSV()
        local Edge = M.EdgeColor or Color3.fromHSV(H, S, math.min(V, 0.80))
        local Mid  = M.MidColor  or Color3.fromHSV(H, math.max(0.10, S * 0.55), math.min(1, V + 0.12))
        return Edge, Mid
    end

    local themeSeq, themeSig, themeCheckAt = nil, nil, 0
    local function buildSequence()
        if manualSeq then return manualSeq end
        local now = os.clock()
        if themeSeq and (now - themeCheckAt) < 0.12 then return themeSeq end
        themeCheckAt = now
        local Edge, Mid = BuildThemeColors()
        local Sig = string.format("%.4f,%.4f,%.4f|%.4f,%.4f,%.4f",
            Edge.R, Edge.G, Edge.B, Mid.R, Mid.G, Mid.B)
        if Sig ~= themeSig then
            themeSig = Sig
            themeSeq = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Edge),
                ColorSequenceKeypoint.new(0.30, Edge),
                ColorSequenceKeypoint.new(0.50, Mid),
                ColorSequenceKeypoint.new(0.70, Edge),
                ColorSequenceKeypoint.new(1.00, Edge),
            })
        end
        return themeSeq
    end

    local function getMainFrame()
        if not Library then return nil end
        local w = Library.Window
        local mf = w and w.MainFrame
        if mf and mf.Parent then return mf end
        return nil
    end

    -- 通用：在 parent 内建一层透明描边框（所有目标共用这一套机制）
    local function newBorder(parent, radius, thickness, inset, name)
        local f = Instance.new("Frame")
        f.Name = name or "YXGradientBorder"
        f.Size = UDim2.new(1, -inset * 2, 1, -inset * 2)
        f.Position = UDim2.fromOffset(inset, inset)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.Active = false                 -- 不挡点击
        f.ZIndex = 999                  -- 盖在内容之上
        f.Parent = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 0)
        c.Parent = f

        local s = Instance.new("UIStroke")
        s.Name = "GradientStroke"
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Thickness = thickness
        s.Transparency = 0
        s.Color = Color3.new(1, 1, 1)    -- 白基底仅用于让 UIGradient 完整显色，不是可见白色
        s.Parent = f

        local g = Instance.new("UIGradient")
        g.Name = "BorderGradient"
        g.Enabled = true
        g.Color = buildSequence()
        g.Rotation = 0
        g.Parent = s

        return { frame = f, corner = c, stroke = s, grad = g }
    end





    -- ========================================================
    -- 窗口边框
    -- ========================================================
    function M:EnableWindow()
        if winFrame and winFrame.Parent then return self end
        local mf = getMainFrame()
        if not mf then
            warn("YXGradientBorder: 未找到 Library.Window.MainFrame，请在 CreateWindow 之后调用 Enable()")
            return self
        end

        local b = newBorder(mf, M.Radius, M.Thickness, 0, M.Name)
        winFrame, winCorner, winStroke, winGrad = b.frame, b.corner, b.stroke, b.grad
        winStroke.Transparency = M.Transparency
        M.Enabled = true
        winLast = os.clock()

        winConn = RunService.Heartbeat:Connect(function()
            if not (winFrame and winFrame.Parent) then M:DisableWindow(); return end
            local now = os.clock()
            local dt = now - winLast
            winLast = now
            if not manualSeq then
                local seq = buildSequence()
                if seq ~= winLastSeq then winGrad.Color = seq; winLastSeq = seq end
            end
            local rot = (winGrad.Rotation + M.Speed * dt) % 360
            winGrad.Rotation = rot
            if M.Pulse then
                winStroke.Thickness = M.Thickness + math.sin(now * 3) * 0.4
            end
        end)
        return self
    end

    function M:DisableWindow()
        if winConn then pcall(function() winConn:Disconnect() end); winConn = nil end
        if winFrame then pcall(function() winFrame:Destroy() end) end
        winFrame, winCorner, winStroke, winGrad = nil, nil, nil, nil
        M.Enabled = false
        return self
    end

    -- ========================================================
    -- 标签页边框
    -- ========================================================
    local function buttonRadius(btn)
        local r = M.Tabs.Radius
        if type(r) == "number" then return r end
        -- 库默认 TabButtonsStyle.CornerRadius = 0；跟随按钮自身 UICorner 最稳
        local ok, c = pcall(function()
            return btn.FindFirstChildOfClass and btn:FindFirstChildOfClass("UICorner")
        end)
        if ok and c and c.CornerRadius then return c.CornerRadius.Offset or 0 end
        return 0
    end

    -- 收集当前所有标签目标（同时覆盖普通 Tab 与 KeyTab）
    local function collectTargets()
        local out = {}
        if not (Library and type(Library.Tabs) == "table") then return out end
        for _, tab in pairs(Library.Tabs) do
            if type(tab) == "table" then
                if tab.Button then
                    out[#out + 1] = { tab = tab, obj = tab.Button, kind = "button" }
                end
                if M.Tabs.IncludeContent and tab.Container then
                    out[#out + 1] = { tab = tab, obj = tab.Container, kind = "content" }
                end
            end
        end
        return out
    end

    -- 差量同步：新标签自动挂上，已销毁 / 不再需要的自动移除
    local function syncTargets()
        local seen = {}
        for _, t in ipairs(collectTargets()) do
            local obj = t.obj
            seen[obj] = true
            local item = tabItems[obj]
            if not item then
                local radius, thick
                if t.kind == "button" then
                    radius, thick = buttonRadius(obj), M.Tabs.Thickness
                else
                    radius, thick = M.Tabs.ContentRadius, M.Tabs.ContentThickness
                end
                item = newBorder(obj, radius, thick, 1, M.Tabs.Name)
                item.kind = t.kind
                tabItems[obj] = item
            end
            item.tab = t.tab   -- 选中态判断每次刷新
        end
        for obj, item in pairs(tabItems) do
            if not seen[obj] then
                pcall(function() item.frame:Destroy() end)
                tabItems[obj] = nil
            end
        end
    end

    function M:EnableTabs()
        if M.Tabs.Enabled then return self end
        M.Tabs.Enabled = true
        tabLast = os.clock()
        scanAcc = 0
        syncTargets()

        tabConn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            local dt = now - tabLast
            tabLast = now
            local seq = buildSequence()
            tabAngle = (tabAngle + M.Tabs.Speed * dt) % 360

            -- 每 0.2s 扫一次新增/销毁的标签（切页无需每帧扫）
            scanAcc = scanAcc + dt
            if scanAcc >= 0.2 then scanAcc = 0; syncTargets() end

            local activeTab = Library and Library.ActiveTab
            local tabSeqChanged = (seq ~= tabLastSeq)
            if tabSeqChanged then tabLastSeq = seq end
            for obj, item in pairs(tabItems) do
                if item.frame and item.frame.Parent then
                    if tabSeqChanged then item.grad.Color = seq end
                    item.grad.Rotation = tabAngle
                    if item.kind == "button" then
                        local active = (item.tab == activeTab)
                        local show = active or not M.Tabs.OnlyActive
                        item.stroke.Thickness = active
                            and M.Tabs.ActiveThickness or M.Tabs.Thickness
                        item.stroke.Transparency = show
                            and (active and M.Tabs.ActiveTransparency
                                       or M.Tabs.IdleTransparency)
                            or 1
                    else
                        item.stroke.Thickness = M.Tabs.ContentThickness
                        item.stroke.Transparency = 0
                    end
                end
            end
        end)
        return self
    end

    function M:DisableTabs()
        if tabConn then pcall(function() tabConn:Disconnect() end); tabConn = nil end
        for obj, item in pairs(tabItems) do
            pcall(function() item.frame:Destroy() end)
            tabItems[obj] = nil
        end
        M.Tabs.Enabled = false
        return self
    end

    -- ========================================================
    -- 通知边框（流动渐变描边）
    --   通知由 Library:Notify 动态创建、几秒后销毁，存在 Library.Notifications 里
    --   （key = FakeBackground，value = Data，Data.Holder 是通知主体 Frame）。
    --   因此照标签页那套做差量同步：每 0.2s 扫一次，新通知自动挂、销毁的自动清。
    -- ========================================================
    local function notifRadius(holder)
        local r = M.Notifs.Radius
        if type(r) == "number" then return r end
        local ok, c = pcall(function()
            return holder.FindFirstChildOfClass and holder:FindFirstChildOfClass("UICorner")
        end)
        if ok and c and c.CornerRadius then return c.CornerRadius.Offset or 0 end
        return 0
    end

    local function collectNotifs()
        local out = {}
        if not (Library and type(Library.Notifications) == "table") then return out end
        for _, Data in pairs(Library.Notifications) do
            if type(Data) == "table" and Data.Holder then
                local holder = Data.Holder
                local ok, parent = pcall(function() return holder.Parent end)
                if ok and parent then out[#out + 1] = holder end
            end
        end
        return out
    end

    local function syncNotifs()
        local seen = {}
        for _, holder in ipairs(collectNotifs()) do
            seen[holder] = true
            local item = notifItems[holder]
            if not item then
                item = newBorder(holder, notifRadius(holder), M.Notifs.Thickness, 0, M.Notifs.Name)
                item.stroke.Transparency = M.Notifs.Transparency
                notifItems[holder] = item
            end
        end
        for holder, item in pairs(notifItems) do
            if not seen[holder] then
                pcall(function() item.frame:Destroy() end)
                notifItems[holder] = nil
            end
        end
    end

    function M:EnableNotifs()
        if M.Notifs.Enabled then return self end
        M.Notifs.Enabled = true
        notifLast = os.clock()
        notifScanAcc = 0
        syncNotifs()
        notifConn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            local dt = now - notifLast
            notifLast = now
            local seq = buildSequence()   -- 已按主题色缓存，不会每帧新建
            notifAngle = (notifAngle + M.Notifs.Speed * dt) % 360
            notifScanAcc = notifScanAcc + dt
            if notifScanAcc >= 0.2 then notifScanAcc = 0; syncNotifs() end
            local notifSeqChanged = (seq ~= notifLastSeq)
            if notifSeqChanged then notifLastSeq = seq end
            for _, item in pairs(notifItems) do
                if item.frame and item.frame.Parent then
                    if notifSeqChanged then item.grad.Color = seq end
                    item.grad.Rotation = notifAngle
                end
            end
        end)
        return self
    end

    function M:DisableNotifs()
        if notifConn then pcall(function() notifConn:Disconnect() end); notifConn = nil end
        for holder, item in pairs(notifItems) do
            pcall(function() item.frame:Destroy() end)
            notifItems[holder] = nil
        end
        M.Notifs.Enabled = false
        return self
    end

    -- ========================================================
    -- 统一开关 + Setter
    -- ========================================================
    function M:Enable()
        M:EnableWindow()
        if M.Tabs.AutoEnable ~= false then M:EnableTabs() end
        if M.Notifs.AutoEnable ~= false then M:EnableNotifs() end
        return self
    end

    function M:Disable()
        M:DisableNotifs()
        M:DisableTabs()
        M:DisableWindow()
        return self
    end

    function M:SetColors(edge, mid)
        -- 传 nil, nil 恢复「跟随主题强调色」的默认边框配色
        if edge == nil and mid == nil then
            manualSeq = nil
            themeSig = nil      -- 强制下一轮按当前主题重建
            themeCheckAt = 0
        else
            edge = edge or Color3.fromRGB(34, 211, 238)
            mid  = mid  or edge
            manualSeq = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   edge),
                ColorSequenceKeypoint.new(0.5, mid),
                ColorSequenceKeypoint.new(1,   edge),
            })
        end
        local seq = buildSequence()
        if winGrad then winGrad.Color = seq end
        for _, item in pairs(tabItems) do
            if item.grad then item.grad.Color = seq end
        end
        for _, item in pairs(notifItems) do
            if item.grad then item.grad.Color = seq end
        end
        return self
    end


    function M:SetSpeed(v)   if type(v) == "number" then M.Speed = v end; return self end
    function M:SetThickness(v)
        if type(v) == "number" then
            M.Thickness = v
            if winStroke then winStroke.Thickness = v end
        end
        return self
    end
    function M:SetPulse(v)   M.Pulse = v and true or false; return self end

    function M:SetTabSpeed(v)
        if type(v) == "number" then M.Tabs.Speed = v end
        return self
    end
    function M:SetTabThickness(idle, active)
        if type(idle) == "number" then M.Tabs.Thickness = idle end
        if type(active) == "number" then M.Tabs.ActiveThickness = active end
        return self
    end
    function M:SetTabIdleTransparency(v)
        if type(v) == "number" then M.Tabs.IdleTransparency = clamp01(v) end
        return self
    end
    function M:SetTabRadius(v)
        -- nil = 恢复自动跟随按钮自身 UICorner
        M.Tabs.Radius = (type(v) == "number") and v or nil
        if M.Tabs.Enabled then
            for obj, item in pairs(tabItems) do
                if item.kind == "button" and item.corner then
                    item.corner.CornerRadius = UDim.new(0, buttonRadius(obj))
                end
            end
        end
        return self
    end
    function M:SetTabOnlyActive(v)
        M.Tabs.OnlyActive = v and true or false
        return self
    end
    function M:SetTabIncludeContent(v)
        M.Tabs.IncludeContent = v and true or false
        if M.Tabs.Enabled then syncTargets() end
        return self
    end
    function M:SetNotifSpeed(v)
        if type(v) == "number" then M.Notifs.Speed = v end
        return self
    end
    function M:SetNotifThickness(v)
        if type(v) == "number" then
            M.Notifs.Thickness = v
            if M.Notifs.Enabled then
                for _, item in pairs(notifItems) do item.stroke.Thickness = v end
            end
        end
        return self
    end

    return M
end)(Library)

-- [内嵌] YXGradientBorder:Enable() -> 已移至 YXStart() 统一启动
-- ============================================================================
-- 液态玻璃（移植自 SyndromeXph/Obsidian 新版库 Library.lua 的 "Liquid Glass"）
--   库内位置：294-301 行配置 / 1593-1644 行 ApplyLiquidGlass + AddGlassSheen /
--             1646-1681 行 SetWorldGlass / 1789-1821 行 Lighting 特效。
--   本次按需求只采用其中两块，不做「世界模糊 / 压暗」（不创建 BlurEffect、
--     ColorCorrectionEffect，也不改 Lighting）：
--     1) AddGlassSheen    -> 窗口 MainFrame 上的斜向玻璃高光层（完全照搬库实现）
--     2) ApplyLiquidGlass -> 窗口内 BackgroundColor / MainColor 面板半透明化
--   当前主脚本用的是 deividcomsono 旧库，没有内建这些；ApplyLiquidGlass 原本挂在
--   库内部 New() 上，外部拦不到，这里改成「低频扫描窗口后代 + 双路判定」近似复刻：
--     · 路 A：读 Library.Registry[obj].BackgroundColor3 的键（与库原版判定一致）
--     · 路 B：底色是否接近 Library.Scheme.BackgroundColor / MainColor
--             （美化模块会改写部分 Registry 键，路 B 保证这种情况仍能命中）
--   不碰窗口 MainFrame 本体：它自身保持不透明，半透过去也看不到效果。
-- ============================================================================
local YXLiquidGlass = (function(Library)
    local M = {}

    M.Glass = {
        Enabled           = true,

        -- 1) 面板半透明化 -------------------------------------------------
        Transparency      = 0.5,   -- 与库 GlassTransparency 一致
        IncludeMainFrame  = false, -- 窗口本体自身保持不透明，半透也看不到效果
        OnlyOpaque        = true,  -- 只接管当前完全不透明的面板，不破坏控件自设透明度
        ScanInterval      = 0.35,  -- 运行时新增控件（下拉 / 通知等）补扫间隔
        ColorTolerance    = 0.08,  -- 主题底色近似匹配容差

        -- 2) 窗口玻璃高光层 ---------------------------------------------
        SheenEnabled      = true,
        SheenName         = "YXLiquidGlassSheen",
        SheenZIndex       = 0,     -- 与库一致；若被背景图压住可调到 990 左右
        SheenRotation     = 112,   -- 库原版斜向角度
        SheenColors       = { { 255, 255, 255 }, { 200, 214, 255 }, { 36, 42, 70 } },
        SheenStops        = { 0, 0.4, 1 },
        SheenTransparency = { { 0, 0.7 }, { 0.42, 0.88 }, { 1, 0.97 } },
        SheenFollowTheme  = false, -- 玻璃反光是中性高光，默认不随主题；true 则混入主题强调色
    }

    local OkRun, RunService = pcall(function() return game:GetService("RunService") end)
    local Heartbeat = (OkRun and RunService and RunService.Heartbeat) or nil

    local Conn = nil
    local Sheen, SheenCorner, SheenGrad = nil, nil, nil
    local BoundMF, SheenSig = nil, nil
    local Processed = setmetatable({}, { __mode = "k" })
    local Origins   = setmetatable({}, { __mode = "k" })
    local ScanAcc, LastFrame = 0, 0

    local function GetMainFrame()
        if not (Library and Library.Window) then return nil end
        local mf = Library.Window.MainFrame
        if mf and mf.Parent then return mf end
        return nil
    end

    local function IsAlive(O)
        if not O then return false end
        local Ok, P = pcall(function() return O.Parent end)
        return Ok and P ~= nil
    end

    -- 面板判定：Registry 键（库原版逻辑） + 当前底色接近主题 BackgroundColor / MainColor
    local function IsPanel(Obj)
        local Reg = Library.Registry and Library.Registry[Obj]
        local Key = Reg and Reg.BackgroundColor3
        if type(Key) == "function" then return true end
        if type(Key) == "string" and (Key == "BackgroundColor" or Key == "MainColor") then
            return true
        end
        local C, S = Obj.BackgroundColor3, Library.Scheme
        if not (C and S) then return false end
        local Tol = M.Glass.ColorTolerance or 0.08
        for _, Name in ipairs({ "BackgroundColor", "MainColor" }) do
            local T = S[Name]
            if T and math.abs(C.R - T.R) < Tol
                  and math.abs(C.G - T.G) < Tol
                  and math.abs(C.B - T.B) < Tol then
                return true
            end
        end
        return false
    end

    -- 返回 true = 以后不用再判断这个对象；false = 属性还没就绪，下轮重试
    local function ApplyOne(Obj, mf)
        if Obj == mf and not M.Glass.IncludeMainFrame then return true end
        if Obj == Sheen then return true end
        local Ok, Handled = pcall(function()
            -- 磨砂玻璃底是自造的「景」，必须保持不透明，不能被当面板半透明化
            if string.find(Obj.Name or "", "YXGlassBackdrop", 1, true) then return true end
            if not Obj:IsA("GuiObject") then return true end
            local BT = Obj.BackgroundTransparency
            if type(BT) ~= "number" then return false end
            if BT >= 1 then return true end                       -- 本来就全透，跳过
            if M.Glass.OnlyOpaque and BT > 0.01 then return true end -- 控件自设透明度，别动
            if not IsPanel(Obj) then return true end
            Origins[Obj] = BT
            Obj.BackgroundTransparency = M.Glass.Transparency
            return true
        end)
        return (Ok and Handled) or false
    end

    local function Scan()
        local mf = GetMainFrame()
        if not mf then return end
        BoundMF = mf
        pcall(function()
            for _, Obj in ipairs(mf:GetDescendants()) do
                if not Processed[Obj] then
                    if ApplyOne(Obj, mf) then Processed[Obj] = true end
                end
            end
        end)
    end

    local function BuildSheenColors()
        local C = M.Glass.SheenColors
        local function ToColor(T) return Color3.fromRGB(T[1], T[2], T[3]) end
        local A, B, D = ToColor(C[1]), ToColor(C[2]), ToColor(C[3])
        if M.Glass.SheenFollowTheme then
            local Ok, RGB = pcall(function() return YXThemeAccentRGB(Library, true) end)
            if Ok and RGB then
                local Acc = Color3.new(RGB[1], RGB[2], RGB[3])
                B = Color3.new((B.R + Acc.R) / 2, (B.G + Acc.G) / 2, (B.B + Acc.B) / 2)
            end
        end
        return A, B, D
    end

    local function NewSheen(mf)
        local G = M.Glass
        local S = Instance.new("Frame")
        S.Name = G.SheenName
        S.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        S.BackgroundTransparency = 0
        S.BorderSizePixel = 0
        S.Size = UDim2.fromScale(1, 1)
        S.Active = false
        S.ZIndex = G.SheenZIndex
        S.Parent = mf

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, Library.CornerRadius or 4)
        Corner.Parent = S
        if type(Library.Corners) == "table" then
            table.insert(Library.Corners, Corner)
        end

        local A, B, D = BuildSheenColors()
        local St, Tr = G.SheenStops, G.SheenTransparency
        local Grad = Instance.new("UIGradient")
        Grad.Rotation = G.SheenRotation
        Grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(St[1], A),
            ColorSequenceKeypoint.new(St[2], B),
            ColorSequenceKeypoint.new(St[3], D),
        })
        Grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(Tr[1][1], Tr[1][2]),
            NumberSequenceKeypoint.new(Tr[2][1], Tr[2][2]),
            NumberSequenceKeypoint.new(Tr[3][1], Tr[3][2]),
        })
        Grad.Parent = S
        return S, Corner, Grad
    end

    local function RemoveSheen()
        if SheenCorner and type(Library.Corners) == "table" then
            for i = #Library.Corners, 1, -1 do
                if Library.Corners[i] == SheenCorner then
                    table.remove(Library.Corners, i)
                end
            end
        end
        if Sheen then pcall(function() Sheen:Destroy() end) end
        Sheen, SheenCorner, SheenGrad = nil, nil, nil
    end

    local function Restore()
        for Obj, Old in pairs(Origins) do
            pcall(function() Obj.BackgroundTransparency = Old end)
            Origins[Obj] = nil
        end
        Processed = setmetatable({}, { __mode = "k" })
    end

    local function ThemeSignature()
        if not M.Glass.SheenFollowTheme then return nil end
        local Ok, RGB = pcall(function() return YXThemeAccentRGB(Library, true) end)
        if not (Ok and RGB) then return nil end
        return string.format("%.3f,%.3f,%.3f", RGB[1], RGB[2], RGB[3])
    end

    local function Tick(dt)
        if not M.Glass.Enabled then return end
        local Now = os.clock()
        local Step = (type(dt) == "number" and dt > 0 and dt) or (Now - LastFrame)
        if Step < 0 then Step = 0 end
        if Step > 0.2 then Step = 0.2 end
        LastFrame = Now
        ScanAcc = ScanAcc + Step
        if ScanAcc < M.Glass.ScanInterval then return end
        ScanAcc = 0

        local mf = GetMainFrame()
        if not mf then
            RemoveSheen(); BoundMF = nil
            return
        end
        if BoundMF ~= mf then               -- 窗口被重建
            RemoveSheen()
            Processed = setmetatable({}, { __mode = "k" })
            Origins   = setmetatable({}, { __mode = "k" })
            BoundMF = mf
        end
        if M.Glass.SheenEnabled and not IsAlive(Sheen) then
            Sheen, SheenCorner, SheenGrad = NewSheen(mf)
        elseif not M.Glass.SheenEnabled and IsAlive(Sheen) then
            RemoveSheen()
        end
        Scan()
        if SheenGrad and M.Glass.SheenFollowTheme then
            local Sig = ThemeSignature()
            if Sig and Sig ~= SheenSig then
                SheenSig = Sig
                local A, B, D = BuildSheenColors()
                local St = M.Glass.SheenStops
                pcall(function()
                    SheenGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(St[1], A),
                        ColorSequenceKeypoint.new(St[2], B),
                        ColorSequenceKeypoint.new(St[3], D),
                    })
                end)
            end
        end
    end

    function M:Enable()
        M.Glass.Enabled = true
        if not Heartbeat or Conn then return self end
        LastFrame = os.clock()
        local Ok, C = pcall(function()
            return Heartbeat:Connect(function(dt) pcall(Tick, dt) end)
        end)
        if Ok then Conn = C end
        local mf = GetMainFrame()
        if mf then
            BoundMF = mf
            if M.Glass.SheenEnabled then
                Sheen, SheenCorner, SheenGrad = NewSheen(mf)
            end
            Scan()
        end
        return self
    end

    function M:Disable()
        M.Glass.Enabled = false
        if Conn then pcall(function() Conn:Disconnect() end); Conn = nil end
        RemoveSheen()
        Restore()
        BoundMF, SheenSig = nil, nil
        return self
    end

    function M:SetTransparency(V)
        if type(V) == "number" then
            M.Glass.Transparency = V
            for Obj in pairs(Origins) do
                pcall(function() Obj.BackgroundTransparency = V end)
            end
        end
        return self
    end

    return M
end)(Library)

-- [内嵌] YXLiquidGlass:Enable() -> 已移至 YXStart() 统一启动
-- ============================================================================
-- 窗口内磨砂玻璃底   ——   「不碰游戏画面」版液态玻璃的「景」
-- ----------------------------------------------------------------------------
-- 【成因】库原版 Liquid Glass 是三件套：面板半透明 + 玻璃高光 + SetWorldGlass
--   （Lighting 里的 BlurEffect 模糊 + ColorCorrectionEffect 压暗降饱和）。
--   主脚本用的旧库没有这套，本模块此前只复刻了前两件。于是面板设成 0.5 半透明
--   后，透出的是 MainFrame 那层【不透明的纯色底板】——两层几乎同色叠加，糊成一片、
--   没层次、白字发灰、斜高光浮在表面像块灰塑料。库原版玻璃后面「有景」（模糊
--   压暗的 3D 世界），所以通透、柔和、文字清晰。
--
-- 【本模块做法】完全不碰 Lighting / 游戏画面，在 MainFrame 内部、所有半透明面板
--   之下，垫一层【不透明】的柔和磨砂渐变「景」，用两层不同角度的 UIGradient
--   造出明暗层次与柔光带，模拟被模糊压暗的景物；玻璃后面就有东西可看了。
--     · Base 层（-2）：不透明，4 关键点斜向渐变，主题底色 + 强调色混入 + 明暗起伏
--     · Haze 层（-1）：另一角度的柔光带，靠 NumberSequence 两端隐、中部显
--     · 两层都带 UICorner（跟随窗口圆角），Active=false 不挡点击
--     · 名字统一含 YXGlassBackdrop：YXLiquidGlass 扫描会跳过（保持不透明），
--       流光段的 SKIP_NAME 已含 "Backdrop" 也会跳过
--     · 低频同步主题色 / 圆角 / 窗口重建 / 背景图互斥，不做每帧赋值
--
-- 【背景图互斥】库每帧把 ScreenGui 下那张 BackgroundImage(ImageTransparency≈0.75)
--   的 Visible 设为 HasBackgroundImage and MainFrame.Visible。低频读它的 Visible
--   即可知道开关状态：显示背景图 -> 隐藏磨砂底；关背景图 -> 显示磨砂底。
--
-- 【参数】全部在 M.Backdrop 配置表里，改数字即可，不需要 UI 开关 / 滑块。
-- ============================================================================
local YXGlassBackdrop = (function(Library)
    local M = {}

    M.Backdrop = {
        Enabled        = true,
        Name           = "YXGlassBackdrop",
        HazeName       = "YXGlassBackdropHaze",
        BaseZ          = -2,        -- 低于玻璃高光层 Sheen(ZIndex=0) 与所有内容
        HazeZ          = -1,
        Strength       = 1.0,       -- 磨砂层次总强度 0~2（0=接近纯色，越大越有景）
        ThemeMix       = 0.30,      -- 混入主题强调色比例，造色相差异
        LightLift      = 0.20,      -- 亮部提亮
        DarkDrop       = 0.10,      -- 暗部压暗
        HazeStrength   = 0.55,      -- 柔光斑明显度 0~1
        Rotation       = 112,       -- 与库 AddGlassSheen 一致的斜向角度
        HazeRotation   = -32,       -- 柔光带换个角度，叠出景深
        SyncInterval   = 0.30,      -- 低频同步（主题 / 圆角 / 互斥 / 重建）
        ExclusiveWithBackgroundImage = true,  -- 与「显示背景图」互斥
    }

    local OkRun, RunService = pcall(function() return game:GetService("RunService") end)
    local Heartbeat = (OkRun and RunService and RunService.Heartbeat) or nil

    local Conn, Started = nil, false
    local BoundMF = nil
    local Base, Haze, BaseGrad, HazeGrad, BaseCorner, HazeCorner = nil, nil, nil, nil, nil, nil
    local Sig, Acc, Last = nil, 0, 0

    local function Clamp01(v) return math.max(0, math.min(1, v)) end
    local function Lerp(a, b, t) return a + (b - a) * t end
    local function Mix(A, B, t)
        return Color3.new(Lerp(A.R, B.R, t), Lerp(A.G, B.G, t), Lerp(A.B, B.B, t))
    end
    local function Shade(C, d)
        return Color3.new(Clamp01(C.R + d), Clamp01(C.G + d), Clamp01(C.B + d))
    end

    local function GetMainFrame()
        if not (Library and Library.Window) then return nil end
        local mf = Library.Window.MainFrame
        if mf and mf.Parent then return mf end
        return nil
    end

    local function IsAlive(O)
        if not O then return false end
        local Ok, P = pcall(function() return O.Parent end)
        return Ok and P ~= nil
    end

    local function ThemeColors()
        local S = Library.Scheme or {}
        local Bg = S.BackgroundColor or Color3.fromRGB(24, 27, 34)
        local Ac = S.AccentColor or Color3.fromRGB(130, 200, 248)
        return Bg, Ac
    end

    -- 4 关键点：暗 -> 亮(强调色) -> 次亮 -> 深蓝灰，形成柔和斜向明暗带
    local function BuildBaseColor()
        local Bg, Ac = ThemeColors()
        local C = M.Backdrop
        local K = C.Strength
        local Deep = Color3.fromRGB(36, 42, 70)   -- 库 Sheen 的暗端色
        local C0 = Shade(Mix(Bg, Ac, C.ThemeMix * 0.35), -C.DarkDrop * K)
        local C1 = Shade(Mix(Bg, Ac, C.ThemeMix),         C.LightLift * K)
        local C2 = Shade(Mix(Bg, Ac, C.ThemeMix * 0.18),  C.LightLift * 0.35 * K)
        local C3 = Shade(Mix(Bg, Deep, 0.35),            -C.DarkDrop * 0.5 * K)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0,    C0),
            ColorSequenceKeypoint.new(0.34, C1),
            ColorSequenceKeypoint.new(0.68, C2),
            ColorSequenceKeypoint.new(1,    C3),
        })
    end

    -- 柔光带：两端几乎全隐、中部显，颜色白 -> 浅强调色 -> 白
    local function BuildHazeColor()
        local _, Ac = ThemeColors()
        local W = Color3.new(1, 1, 1)
        local Soft = Mix(W, Ac, 0.35)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0,   W),
            ColorSequenceKeypoint.new(0.5, Soft),
            ColorSequenceKeypoint.new(1,   W),
        })
    end
    local function BuildHazeTrans()
        local S = Clamp01(M.Backdrop.HazeStrength * M.Backdrop.Strength)
        local Mid = 1 - 0.55 * S
        return NumberSequence.new({
            NumberSequenceKeypoint.new(0,   0.94),
            NumberSequenceKeypoint.new(0.5, Mid),
            NumberSequenceKeypoint.new(1,   0.94),
        })
    end

    local function Radius()
        return UDim.new(0, Library.CornerRadius or 12)
    end

    local function NewLayer(mf, Name, Z)
        local F = Instance.new("Frame")
        F.Name = Name
        F.Size = UDim2.fromScale(1, 1)
        F.Position = UDim2.fromScale(0, 0)
        F.BorderSizePixel = 0
        F.BackgroundTransparency = 0        -- 不透明：Base 挡住 3D 世界
        F.BackgroundColor3 = Color3.new(1, 1, 1)
        F.Active = false
        F.Visible = true                    -- 首帧即显示，不等第一次同步
        F.ZIndex = Z
        F.Parent = mf

        local Co = Instance.new("UICorner")
        Co.CornerRadius = Radius()
        Co.Parent = F

        local G = Instance.new("UIGradient")
        G.Enabled = true
        G.Parent = F
        return F, Co, G
    end

    local function DestroyLayers()
        for _, O in ipairs({ Haze, Base }) do
            if O then pcall(function() O:Destroy() end) end
        end
        Base, Haze, BaseGrad, HazeGrad, BaseCorner, HazeCorner = nil, nil, nil, nil, nil, nil
    end

    local function Build(mf)
        DestroyLayers()
        local Ok = pcall(function()
            Base, BaseCorner, BaseGrad = NewLayer(mf, M.Backdrop.Name, M.Backdrop.BaseZ)
            Haze, HazeCorner, HazeGrad = NewLayer(mf, M.Backdrop.HazeName, M.Backdrop.HazeZ)

            BaseGrad.Rotation = M.Backdrop.Rotation
            BaseGrad.Color = BuildBaseColor()

            HazeGrad.Rotation = M.Backdrop.HazeRotation
            HazeGrad.Color = BuildHazeColor()
            HazeGrad.Transparency = BuildHazeTrans()
        end)
        if not Ok then DestroyLayers() end
        return Ok
    end

    local function ApplyColors()
        pcall(function()
            if BaseGrad then
                BaseGrad.Rotation = M.Backdrop.Rotation
                BaseGrad.Color = BuildBaseColor()
            end
            if HazeGrad then
                HazeGrad.Rotation = M.Backdrop.HazeRotation
                HazeGrad.Color = BuildHazeColor()
                HazeGrad.Transparency = BuildHazeTrans()
            end
        end)
    end

    local function ThemeSignature()
        local Bg, Ac = ThemeColors()
        return string.format("%.3f,%.3f,%.3f|%.3f,%.3f,%.3f|%.2f|%.2f|%.2f|%.2f|%.2f",
            Bg.R, Bg.G, Bg.B, Ac.R, Ac.G, Ac.B,
            M.Backdrop.Strength, M.Backdrop.ThemeMix,
            M.Backdrop.LightLift, M.Backdrop.DarkDrop, M.Backdrop.HazeStrength)
    end

    -- 库每帧把 ScreenGui 下那张 ImageTransparency≈0.75 的 BackgroundImage
    -- 的 Visible 设为 HasBackgroundImage and MainFrame.Visible。
    local function LibBackgroundOn(Screen)
        if not Screen then return false end
        local Ok, Res = pcall(function()
            for _, C in ipairs(Screen:GetChildren()) do
                if C:IsA("ImageLabel")
                   and not string.find(C.Name or "", "YX", 1, true)
                   and C:FindFirstChildOfClass("UICorner") then
                    local Tr = C.ImageTransparency
                    if type(Tr) == "number" and math.abs(Tr - 0.75) < 0.02 then
                        return C.Visible == true
                    end
                end
            end
            return false
        end)
        return (Ok and Res == true)
    end

    local function Tick(dt)
        if not M.Backdrop.Enabled then return end
        if Library.Unloaded then return end
        local Now = os.clock()
        local Step = (type(dt) == "number" and dt > 0 and dt) or (Now - Last)
        if Step < 0 then Step = 0 end
        if Step > 0.2 then Step = 0.2 end
        Last = Now
        Acc = Acc + Step
        if Acc < M.Backdrop.SyncInterval then return end
        Acc = 0

        local mf = GetMainFrame()
        if not mf then
            DestroyLayers(); BoundMF = nil
            return
        end
        if BoundMF ~= mf then            -- 窗口被重建
            DestroyLayers()
            BoundMF = mf
        end
        if not IsAlive(Base) or not IsAlive(Haze) then
            Build(mf)
        end

        -- 主题 / 配置变化 -> 重建渐变（不做每帧赋值）
        local S2 = ThemeSignature()
        if S2 ~= Sig then
            Sig = S2
            ApplyColors()
        end

        -- 圆角跟随（UI 设置里的圆角滑块）
        pcall(function()
            local R = Radius()
            if BaseCorner and BaseCorner.CornerRadius ~= R then BaseCorner.CornerRadius = R end
            if HazeCorner and HazeCorner.CornerRadius ~= R then HazeCorner.CornerRadius = R end
        end)

        -- 与「显示背景图」互斥
        local Show = true
        if M.Backdrop.ExclusiveWithBackgroundImage then
            Show = not LibBackgroundOn(mf.Parent)
        end
        pcall(function()
            if Base then Base.Visible = Show end
            if Haze then Haze.Visible = Show end
        end)
    end

    function M:Enable()
        M.Backdrop.Enabled = true
        if not Heartbeat or Conn then return self end
        Last = os.clock()
        local Ok, C = pcall(function()
            return Heartbeat:Connect(function(dt) pcall(Tick, dt) end)
        end)
        if Ok then Conn = C end
        local mf = GetMainFrame()
        if mf then
            BoundMF = mf
            Build(mf)
            Sig = ThemeSignature()
        end
        return self
    end

    function M:Disable()
        M.Backdrop.Enabled = false
        if Conn then pcall(function() Conn:Disconnect() end); Conn = nil end
        DestroyLayers()
        BoundMF, Sig = nil, nil
        return self
    end

    -- 运行时可调（参数写进配置表，不需要 UI 控件）
    function M:SetStrength(V)          -- 磨砂层次总强度 0~2
        if type(V) == "number" then M.Backdrop.Strength = math.max(0, math.min(2, V)); Sig = nil end
        return self
    end
    function M:SetThemeMix(V)          -- 强调色混入比例 0~1
        if type(V) == "number" then M.Backdrop.ThemeMix = Clamp01(V); Sig = nil end
        return self
    end
    function M:SetHaze(V)              -- 柔光斑明显度 0~1
        if type(V) == "number" then M.Backdrop.HazeStrength = Clamp01(V); Sig = nil end
        return self
    end
    function M:SetExclusive(V)         -- 与背景图互斥 开/关
        M.Backdrop.ExclusiveWithBackgroundImage = V and true or false
        return self
    end
    function M:Refresh()
        Sig = nil
        return self
    end

    return M
end)(Library)

-- [内嵌] YXGlassBackdrop:Enable() -> 已移至 YXStart() 统一启动
-- ============================================================================
-- 指定 4 组文本 渐变流光   ——   算法 1:1 移植自新版库 Library.lua
-- ============================================================================
local YXLibTextFlow = (function(Library)
    local M = {}

    -- ---------------------- 可调配置 ----------------------
    -- 【库 Library.lua 原生流光字参数对照】下面每项都与库一一对应，改这里 = 改库那个效果：
    --   颜色常量  Violet(148,0,211) / SoftViolet(186,85,255) / PureBlack(0,0,0)   [318-320 行]
    --   关键点    0 / 0.33 / 0.66 / 1                                             [330-333 行]
    --   相位      0 / 1.2 / 2.4 / 3.6（步长 1.2）                                [325-328 行]
    --   颜色速度  标题 os.clock()*0.25 / 页脚 *0.28 / 通知进度条 *0.35            [11053/11245/10715 行]
    --   横向平移  页脚 (Clock*0.28)%2-1                                          [11246 行]
    --   旋转摆动  页脚 sin(Clock*0.85)*16                                        [11247 行]
    --   驱动      RenderStepped 每帧重建 ColorSequence + 每帧 TextColor3=白      [11049/11241 行]
    -- 库把这些系数全部写死，这里提成参数；默认值 = 整体提亮 + 整体加速。
    M.Enabled            = true

    -- ===== 速度（默认约为库 2.7 倍，流光明显加快）=====
    M.Speed              = 0.75      -- ① 颜色循环速度（库 0.25 / 0.28 / 0.35）
    M.OffsetSpeed        = 0.75      -- ② 色带横向平移速度（库 0.28）
    M.SwaySpeed          = 1.70      -- ③ 摆动角速度（库 0.85）
    M.Sway               = 16        -- ④ 摆动幅度，单位度（库 16；0 = 不摆）
    M.Interval           = 1/30      -- ⑤ 流光动画降频到 30fps（人眼对流动无感，CPU 直接减半）；
                                     --    主题/扫描累加器仍每帧跑，响应不受影响。改 0 = 每帧。

    -- ===== 波形（库 MakeVioletBlackGradient 的写死值，照搬为参数）=====
    M.PhaseStep          = 1.2       -- ⑥ 相位步长：0 / 1.2 / 2.4 / 3.6
    M.Key2               = 0.33      -- ⑦ 第 2 关键点位置
    M.Key3               = 0.66      -- ⑧ 第 3 关键点位置

    -- ===== 配色（库三色 + 整体提亮）=====
    M.Brightness         = 0.62      -- ⑨ 整体亮度 0~1：0=强调色原色（偏暗），1=接近纯白
                                     --    三档全部落在亮区间，暗端不再是纯黑/深蓝灰，
                                     --    也不会出现固定纯白中点（"一暗一白"已中和）
    M.UseLibraryPalette  = false     -- ⑩ true=切回库原版紫黑三色，便于和库逐帧对照

    -- ===== 作用范围：所有标签页的 Name / Description / Icon / Tooltip =====
    -- 【不再写死某几个文本】每次补扫都从库的数据结构动态收集：
    --   Library.Tabs      （字典）→ 每个标签页的 Name / Description / Tooltip
    --   Library.TabButtons（数组）→ 每个标签按钮的 .Label 名称文字 + .Icon 图标
    -- 因此「所有标签页」自动覆盖，新增 / 改名标签页无需改配置。
    -- 内容区顶部的当前标签名 / 描述、悬停 Tooltip 浮层，用文本白名单命中。
    -- 其余所有文字与未登记图标一律【不挂渐变、不刷白基底】，交给主题色 Registry。
    M.WindowTexts = {                          -- 窗口级固定文本（Title / Footer）
        ["YX-Loader"] = true,
        ["YX-Loader | 仍在开发中"] = true,
    }
    M.AutoTabs           = true    -- 自动收集所有标签页（关掉则只流光 WindowTexts）
    M.IncludeTabName     = true    -- ① 标签页 Name
    M.IncludeTabDesc     = true    -- ② 标签页 Description
    M.IncludeTabIcon     = true    -- ③ 标签页 Icon（图片 / 字体图标都支持）
    M.IncludeTabTooltip  = true    -- ④ 标签页 Tooltip（悬停浮层）
    M.OnlyTabTooltips    = true    -- Tooltip 浮层为全局单例：只在显示「标签页提示」
                                    -- 时流光，其它控件提示保持主题色（原色自动恢复）
    M.ScanInterval       = 1.0     -- 动态补扫间隔（切换标签 / 通知 / 对话框）。
                                    --   已靠 DescendantAdded 实时捕获新增元素，整树扫描
                                    --   无需太频繁；从 0.5s 提到 1.0s，降低大 UI 下的周期卡顿。
    M.ThemeInterval      = 0.3     -- 主题强调色重取间隔
    M.TakeOverExisting   = true    -- 复用对象上已有的 UIGradient；一个 GuiObject 挂
                                    -- 两条会互相打架，复用同一条才能真流动
    M.WhiteBase          = true    -- 每帧强制白基底（库同款；相乘时白 = 恒等元）
                                    -- 文本刷 TextColor3，图片图标刷 ImageColor3
    M.KeepRichTextColor  = true    -- 含 <font color=...> 的文字保留内联色

    -- ===== 本版新增：所有 Icon 的「液态玻璃 + 流光」=====
    M.IncludeAllIcons    = true    -- 所有图标都流光（不再只限标签按钮 Icon）
    M.IncludeFontIcons   = true    -- 连 lucide 字体图标（带 IconPadding）也一起
    M.IconGlass          = true    -- 图标叠加液态玻璃 112° 斜向高光带
    M.GlassRotation      = 112     -- 库 AddGlassSheen 原版角度
    M.GlassSway          = 6       -- 高光带轻微摆动（度），0 = 固定
    M.GlassMinTrans      = 0.00    -- 高光带两端透明度（0 = 完全清晰）
    M.GlassMaxTrans      = 0.32    -- 高光带中部透明度（越大玻璃感越强、图标越淡）
    M.GlassKey           = 0.42    -- 库 NumberSequence 的中间关键点位置

    M.ExcludeWindowIcon  = true    -- ★ 窗口标题栏 Icon 不加流光 / 不加玻璃
    M.WindowTitle        = "YX-Loader"          -- 用于识别 TitleHolder
    M.WindowIconIds      = { "71400987113958" } -- 主脚本 CreateWindow 的 Icon id

    M.IconMaxSize        = 128     -- 超过此边长视为大图 / 背景图 / 赞助码，跳过
    M.SkipGuiRootImages  = false   -- 默认关：背景图靠上面的尺寸规则挡掉即可，
                                   -- 避免误伤「直接挂在 ScreenGui 根下」的小图标

    -- ---------------------- 内部状态 ----------------------
    local FALLBACK_ACCENT = Color3.fromRGB(130, 200, 248)
    -- 白基底（UIGradient 相乘时白 = 恒等元）：全局复用，避免每帧新建
    local WHITE = Color3.new(1, 1, 1)

    -- 脏标记：记录每个渐变上一次实际写出的 Rotation / Transparency，
    --   值没变就跳过 Roblox 属性写（每帧省掉对全部目标的大量实例写入）。
    local AppliedRot    = setmetatable({}, { __mode = "k" })
    local AppliedTrans  = setmetatable({}, { __mode = "k" })

    local OkRun, RunService = pcall(function() return game:GetService("RunService") end)
    local Heartbeat = (OkRun and RunService and RunService.Heartbeat) or nil

    local Targets   = setmetatable({}, { __mode = "k" })   -- [GuiObject] = UIGradient
    local Seen      = setmetatable({}, { __mode = "k" })   -- 已判定过的对象
    local FontTag   = setmetatable({}, { __mode = "k" })   -- 含 <font color> 的对象
    local BoundRoot = setmetatable({}, { __mode = "k" })   -- 已挂 DescendantAdded 的根
    local OrigColor = setmetatable({}, { __mode = "k" })   -- Tooltip 浮层原始文字色
    local WantedText    = {}                               -- 文本白名单 [string]=true
    local WantedInst    = setmetatable({}, { __mode = "k" }) -- 精确实例（Label / Icon）
    local TabTooltipText = {}                              -- 所有标签 Tooltip 文本
    local IconSet        = setmetatable({}, { __mode = "k" })  -- 图标目标（走玻璃参数）
    local IconOrigColor  = setmetatable({}, { __mode = "k" })  -- 图标原始色，卸载时恢复
    -- 白基底事件驱动：每个流光目标挂一个颜色变化监听，主题色回流瞬间立即重设白。
    --   彻底取代旧版「每帧遍历全部目标读色+比较」的 AssertWhiteBase，平时零开销。
    local WhiteConns     = setmetatable({}, { __mode = "k" })  -- [GuiObject] = RBXScriptConnection
    local HolderCache    = setmetatable({}, { __mode = "k" })  -- [Parent] = 是否 TitleHolder
    local GLASS_TRANS, CLEAR_TRANS = nil, nil

    local Acc, ScanAcc, ThemeAcc = 0, 0, 0
    -- 颜色序列按相位量化缓存，避免每帧 ~5 次表分配造成的 GC 压力
    local LastSeq, LastSeqShift = nil, nil
    local SEQ_STEP = 0.01
    local Conn, Started, FirstFrame = nil, false, true

    local function SafeGet(Object, Key)
        local Ok, Value = pcall(function() return Object[Key] end)
        if Ok then return Value end
        return nil
    end

    local function IsTextObject(Object)
        return Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox")
    end
    local function IsImageObject(Object)
        return Object:IsA("ImageLabel") or Object:IsA("ImageButton")
    end
    -- 库全局唯一的悬停提示浮层 TooltipLabel：ZIndex = 30（全库仅此一处）
    local function IsTooltipLabel(Object)
        return IsTextObject(Object) and SafeGet(Object, "ZIndex") == 30
    end

    -- 玻璃高光 / 背景 / 模糊 / 遮罩 等装饰层不参与
    local SKIP_NAME = {
        "YXLiquidGlassSheen", "YXLibFlowGradient", "Sheen", "Shadow",
        "Blur", "Acrylic", "Backdrop", "Mask",
    }
    local function NameBlocked(Object)
        local Name = Object.Name or ""
        for _, Key in ipairs(SKIP_NAME) do
            if string.find(Name, Key, 1, true) then return true end
        end
        return false
    end

    -- ---------------------- 本版新增：图标识别 / 窗口 Icon 排除 / 玻璃高光 ----------------------
    -- 库的 lucide 字体图标 = 带 IconPadding(UIPadding) 的 TextLabel/TextButton
    local function IsFontIcon(Object)
        if not IsTextObject(Object) then return false end
        local Ok, Pad = pcall(function() return Object:FindFirstChild("IconPadding") end)
        return Ok and Pad ~= nil
    end

    -- 图标尺寸 / 全透明 / ScreenGui 根图层判定（大图、背景、赞助码不参与）
    local function IsDecorative(Object)
        local S = SafeGet(Object, "AbsoluteSize")
        if S and type(S) == "table" or (S and type(S) == "userdata") then
            local W, H = S.X, S.Y
            if type(W) == "number" and type(H) == "number" then
                if W == 0 and H == 0 then return true end   -- 尺寸未就绪，下轮再判
                if math.max(W, H) > (M.IconMaxSize or 128) then return true end
            end
        end
        if M.SkipGuiRootImages and Object.Parent == SafeGet(Library, "ScreenGui") then
            return true
        end
        local T = IsImageObject(Object)
            and SafeGet(Object, "ImageTransparency")
            or  SafeGet(Object, "TextTransparency")
        if T and T >= 0.99 then return true end
        return false
    end

    -- ① 按图标 asset id 精确排除（最稳，不受布局影响）
    local function MatchWindowIconId(Object)
        local Img = SafeGet(Object, "Image")
        if type(Img) ~= "string" or Img == "" then return false end
        for _, Id in ipairs(M.WindowIconIds or {}) do
            if string.find(Img, tostring(Id), 1, true) then return true end
        end
        return false
    end

    -- ② 按父级是 TitleHolder 兜底：该容器里有 UIListLayout + 窗口标题 TextLabel
    local function IsTitleHolder(Parent)
        if not Parent then return false end
        local Cached = HolderCache[Parent]
        if Cached ~= nil then return Cached end
        local HasLayout, HasTitle = false, false
        pcall(function()
            for _, C in ipairs(Parent:GetChildren()) do
                if C:IsA("UIListLayout") then HasLayout = true end
                if C:IsA("TextLabel") and SafeGet(C, "Text") == M.WindowTitle then
                    HasTitle = true
                end
            end
        end)
        local R = HasLayout and HasTitle
        HolderCache[Parent] = R
        return R
    end

    local function IsWindowIcon(Object)
        if not M.ExcludeWindowIcon then return false end
        if MatchWindowIconId(Object) then return true end
        if IsTitleHolder(Object.Parent) then return true end
        return false
    end

    -- 库 AddGlassSheen 的 NumberSequence（两端清晰、中部高光带半透）
    local function BuildGlassTrans()
        local A = math.max(0, math.min(1, M.GlassMinTrans or 0))
        local B = math.max(A, math.min(1, M.GlassMaxTrans or 0.32))
        local K = math.max(0.001, math.min(0.999, M.GlassKey or 0.42))
        local Ok = pcall(function()
            GLASS_TRANS = NumberSequence.new({
                NumberSequenceKeypoint.new(0, A),
                NumberSequenceKeypoint.new(K, B),
                NumberSequenceKeypoint.new(1, A),
            })
            CLEAR_TRANS = NumberSequence.new(0)
        end)
        if not Ok then GLASS_TRANS, CLEAR_TRANS = nil, nil end
    end

    -- ---------------------- 配色（照抄库的 4 关键点 sin + Lerp 结构） ----------------------
    local Pal = {}

    local function ReadAccent()
        local Ok, C = pcall(function()
            return Library.Scheme and Library.Scheme.AccentColor
        end)
        if Ok and typeof(C) == "Color3" then return C end
        return FALLBACK_ACCENT
    end

    local function BuildPalette()
        if M.UseLibraryPalette then
            -- 库 Library.lua 318-320 行三个颜色常量，数值逐字节一致
            Pal.Dark = Color3.fromRGB(0, 0, 0)         -- PureBlackColor
            Pal.Main = Color3.fromRGB(148, 0, 211)     -- VioletColor
            Pal.Lite = Color3.fromRGB(186, 85, 255)    -- SoftVioletColor
            return
        end
        local A = ReadAccent()
        local White = Color3.new(1, 1, 1)
        local B = math.max(0, math.min(1, M.Brightness))
        -- 库的 Black/Violet/SoftViolet 三档 → "亮彩 / 浅色 / 高光" 三档：
        -- 全部由强调色向白 Lerp，最低档也带 B*0.26 提亮，不再压向纯黑/深蓝灰。
        -- 三档亮度约 0.16 / 0.45 / 0.82，四关键点在其间摆动 = 明亮且仍有流动对比。
        Pal.Main = A:Lerp(White, B * 0.26)                    -- 强调色主体（最饱和）
        Pal.Dark = A:Lerp(White, B * 0.72)                    -- 浅色底（取代纯黑）
        Pal.Lite = A:Lerp(White, math.min(B + 0.20, 0.92))   -- 高光（接近白但留色相）
    end

    -- 库 MakeVioletBlackGradient / MakeVioletBlackSequence 原样结构：
    --   c1 = Black:Lerp(Violet,      sin(t*2π)        ...)
    --   c2 = SoftViolet:Lerp(Black,  sin(t*2π + 1.2)  ...)
    --   c3 = Violet:Lerp(Black,      sin(t*2π + 2.4)  ...)
    --   c4 = Black:Lerp(SoftViolet,  sin(t*2π + 3.6)  ...)
    -- 相位步长 / 关键点位置 / 三色都改成上面的 M.* 参数，结构不变、每帧重建。
    local TWO_PI = math.pi * 2
    local function MakeGradient(Shift)
        local t = Shift % 1
        local P = M.PhaseStep
        local S1 = (math.sin(t * TWO_PI)         + 1) * 0.5
        local S2 = (math.sin(t * TWO_PI + P)     + 1) * 0.5
        local S3 = (math.sin(t * TWO_PI + P * 2) + 1) * 0.5
        local S4 = (math.sin(t * TWO_PI + P * 3) + 1) * 0.5
        local D, V, L = Pal.Dark, Pal.Main, Pal.Lite
        -- 夹一下，防止手改参数时关键点乱序导致整条渐变失效（pcall 会静默吞错，
        -- 表现就是"又不流动了"）
        local K2 = math.max(0.001, math.min(0.999, M.Key2))
        local K3 = math.max(K2 + 0.001, math.min(0.999, M.Key3))
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0,    D:Lerp(V, S1)),
            ColorSequenceKeypoint.new(K2,   L:Lerp(D, S2)),
            ColorSequenceKeypoint.new(K3,   V:Lerp(D, S3)),
            ColorSequenceKeypoint.new(1,    D:Lerp(L, S4)),
        })
    end

    -- ---------------------- 目标收集：所有标签页四要素 ----------------------
    local function AddText(T)
        if type(T) == "string" and T ~= "" then WantedText[T] = true end
    end

    -- 每次补扫重建：标签页可能运行时新增 / 改名，必须动态取，不能写死。
    local function RebuildTargets()
        pcall(BuildGlassTrans)          -- 玻璃高光带只构造一次
        for K in pairs(WantedText) do WantedText[K] = nil end
        for K in pairs(WantedInst) do WantedInst[K] = nil end
        for K in pairs(TabTooltipText) do TabTooltipText[K] = nil end

        -- ① 窗口 Title / Footer（固定文本，手填）
        for K, V in pairs(M.WindowTexts or {}) do
            if type(K) == "number" and type(V) == "string" then
                AddText(V)                                 -- 数组写法 { "文本", ... }
            elseif type(K) == "string" and V then
                AddText(K)                                 -- 集合写法 ["文本"] = true
            end
        end

        if not M.AutoTabs then return end

        -- ② 所有标签页：Library.Tabs 是字典（TabKey -> Tab），必须用 pairs
        pcall(function()
            for _, Tab in pairs(Library.Tabs or {}) do
                if type(Tab) == "table" then
                    if M.IncludeTabName then AddText(Tab.Name) end
                    if M.IncludeTabDesc then AddText(Tab.Description) end
                    if M.IncludeTabTooltip and type(Tab.Tooltip) == "string" then
                        AddText(Tab.Tooltip)               -- 也进白名单（双保险）
                        TabTooltipText[Tab.Tooltip] = true
                    end
                end
            end
        end)

        -- ③ 所有标签按钮：Library.TabButtons 是数组，每项含 .Label / .Icon
        pcall(function()
            for _, B in ipairs(Library.TabButtons or {}) do
                if type(B) == "table" then
                    if M.IncludeTabName and B.Label then
                        WantedInst[B.Label] = true         -- Name 名称文字
                        AddText(SafeGet(B.Label, "Text"))
                    end
                    if M.IncludeTabIcon and B.Icon then
                        WantedInst[B.Icon] = true          -- Icon 图标实例
                    end
                end
            end
        end)
    end

    local function Eligible(Object)
        if not M.Enabled or Seen[Object] then return false end
        if NameBlocked(Object) then return false end

        -- 父级链同判（避免玻璃高光容器下的东西被误挂）
        local Parent, Depth = Object.Parent, 0
        while Parent and Depth < 4 do
            if NameBlocked(Parent) then return false end
            Parent = Parent.Parent
            Depth = Depth + 1
        end

        local IsText = IsTextObject(Object)
        local IsIcon = IsImageObject(Object)
        if not (IsText or IsIcon) then return false end

        -- ① 全局 Tooltip 浮层（ZIndex=30）：单独放行，由 Tick 按内容决定亮灭
        if IsTooltipLabel(Object) then
            return M.IncludeTabTooltip and true or false
        end

        -- ② ★ 窗口 Icon 例外：优先级最高，流光 / 玻璃都不加
        local IsFont = M.IncludeFontIcons and IsFontIcon(Object) or false
        if (IsIcon or IsFont) and IsWindowIcon(Object) then return false end

        -- ③ 精确实例：所有标签按钮的 Name 文字 / Icon 图标
        if WantedInst[Object] then return true end

        -- ④ ★ 本版新增：所有 Icon（图片图标 + lucide 字体图标）
        --    窗口 Icon 已在 ② 排除；大图 / 背景 / 全透明由 IsDecorative 挡掉
        if M.IncludeAllIcons and (IsIcon or IsFont) then
            if IsDecorative(Object) then return false end
            return true
        end

        -- ⑤ 文本白名单：内容区当前标签名 / 描述、窗口 Title / Footer、Tooltip 文案
        if not IsText then return false end
        local Tx = SafeGet(Object, "Text")
        if type(Tx) ~= "string" or Tx == "" then return false end
        if not WantedText[Tx] then return false end
        local Tr = SafeGet(Object, "TextTransparency")
        if Tr and Tr >= 0.99 then return false end          -- 全透明占位
        return true
    end

    local function Attach(Object)
        if not Eligible(Object) then return end
        Seen[Object] = true

        local Ok, Grad = pcall(function()
            local G = Object:FindFirstChildOfClass("UIGradient")
            if G then
                -- 已有渐变：默认不动，避免与旧模块 SyncDynamicGradients 互相覆盖
                if not M.TakeOverExisting then return nil end
            else
                G = Instance.new("UIGradient")
                G.Name = "YXLibFlowGradient"
                G.Rotation = 0
                G.Parent = Object
            end
            return G
        end)
        if not Ok or not Grad then return end

        Targets[Object] = Grad

        local Tx = IsTextObject(Object) and SafeGet(Object, "Text") or nil
        local HasFont = (Tx ~= nil and string.find(Tx, "<font", 1, true) ~= nil) or false
        FontTag[Object] = HasFont

        -- 白基底：挂上时一次性铺白（库每帧刷白的目的只是对抗主题色回流）。
        --   含内联 <font color> 的富文本保留原色，跳过。
        if M.WhiteBase and not (M.KeepRichTextColor and HasFont) then
            pcall(function()
                if IsImageObject(Object) then Object.ImageColor3 = WHITE
                else Object.TextColor3 = WHITE end
            end)
            -- 事件驱动白基底：仅在主题色回流改写颜色时重设白，不再每帧遍历复核。
            --   Tooltip 浮层由 Tick 按内容单独管理（非标签页提示要恢复主题色），不挂此监听。
            if not IsTooltipLabel(Object) and not WhiteConns[Object] then
                local Prop = IsImageObject(Object) and "ImageColor3" or "TextColor3"
                local OkSig, Sig = pcall(function() return Object:GetPropertyChangedSignal(Prop) end)
                if OkSig and Sig then
                    local OkC, C = pcall(function()
                        return Sig:Connect(function()
                            if M.Enabled and Object[Prop] ~= WHITE then
                                Object[Prop] = WHITE
                            end
                        end)
                    end)
                    if OkC and C then
                        WhiteConns[Object] = C
                        if Library and Library.GiveSignal then
                            pcall(function() Library:GiveSignal(C) end)
                        end
                    end
                end
            end
        end

        -- 记录图标目标：Tick 里要走「液态玻璃高光」分支，卸载时恢复原始颜色
        if IsImageObject(Object) or (M.IncludeFontIcons and IsFontIcon(Object)) then
            IconSet[Object] = true
            if IconOrigColor[Object] == nil then
                IconOrigColor[Object] = IsImageObject(Object)
                    and SafeGet(Object, "ImageColor3") or SafeGet(Object, "TextColor3")
            end
        end
        -- 记下 Tooltip 浮层原本的文字色，显示非标签页提示时恢复
        if IsTooltipLabel(Object) and OrigColor[Object] == nil then
            OrigColor[Object] = SafeGet(Object, "TextColor3")
        end
    end

    -- 白基底已改为事件驱动（Attach 里挂 GetPropertyChangedSignal），
    --   主题色回流瞬间由监听回调重设白，不再需要每帧遍历复核。

    -- ---------------------- 扫描范围 ----------------------
    -- 主 ScreenGui + CoreGui 下所有以 "Obsidian" 开头的 ScreenGui
    -- （下拉菜单 / 颜色选择器 / 对话框 / 通知等运行时新建的独立 ScreenGui 也能覆盖）
    local function CollectRoots(Out)
        local function Add(R)
            if R and typeof(R) == "Instance" then
                Out[#Out + 1] = R
            end
        end
        Add(SafeGet(Library, "ScreenGui"))
        Add(SafeGet(Library, "Floats"))
        Add(SafeGet(Library, "KeybindFrame"))
        local Ok, CoreGui = pcall(function() return game:GetService("CoreGui") end)
        if Ok and CoreGui then
            pcall(function()
                for _, Child in ipairs(CoreGui:GetChildren()) do
                    if Child:IsA("ScreenGui") and string.sub(Child.Name or "", 1, 8) == "Obsidian" then
                        Add(Child)
                    end
                end
            end)
        end
        return Out
    end

    local function Scan()
        if Library.Unloaded then return end
        RebuildTargets()                -- 标签页可能运行时新增，每次补扫重新收集
        local Roots = CollectRoots({})
        for _, Root in ipairs(Roots) do
            if not BoundRoot[Root] then
                BoundRoot[Root] = true
                pcall(function()
                    Library:GiveSignal(Root.DescendantAdded:Connect(function(Object)
                        pcall(Attach, Object)
                    end))
                end)
            end
            pcall(function()
                for _, Object in ipairs(Root:GetDescendants()) do
                    pcall(Attach, Object)
                end
            end)
            pcall(Attach, Root)
        end
    end

    -- ---------------------- 每帧驱动（库同款：每帧重建 ColorSequence） ----------------------
    -- WHITE 已在模块顶部统一定义（白基底恒等元），此处不再重复声明

    local function Tick(dt)
        if Library.Unloaded or not M.Enabled then return end

        ThemeAcc = ThemeAcc + dt
        if ThemeAcc >= M.ThemeInterval then
            ThemeAcc = 0
            pcall(BuildPalette)
        end
        ScanAcc = ScanAcc + dt
        if ScanAcc >= M.ScanInterval then
            ScanAcc = 0
            pcall(Scan)
        end

        Acc = Acc + dt
        -- 首帧强制执行（不等降频间隔），首帧立刻铺上流光，不闪
        if not FirstFrame and M.Interval > 0 and Acc < M.Interval then return end
        FirstFrame = false
        Acc = 0

        -- ★ 库的核心：每帧重新构造整个 ColorSequence，颜色本身在流动
        local Clock = os.clock()
        local Shift = Clock * M.Speed
        -- 相位没推进够就不重建，省掉每帧 ~5 次表分配（肉眼无差，GC 压力大降）
        if (LastSeqShift == nil) or (math.abs(Shift - LastSeqShift) >= SEQ_STEP) then
            LastSeq = MakeGradient(Shift)
            LastSeqShift = Shift
        end
        local Seq = LastSeq
        local Off = Vector2.new((Clock * M.OffsetSpeed) % 2 - 1, 0)
        local Rot = (M.Sway ~= 0) and (math.sin(Clock * M.SwaySpeed) * M.Sway) or 0

        for Object, Grad in pairs(Targets) do
            if Object.Parent == nil then
                Targets[Object] = nil
            else
                pcall(function()
                    -- ① Tooltip 浮层是全局单例：只在显示「标签页 Tooltip」时流光，
                    --    其它控件的提示保持主题色，并恢复原始文字色。
                    if M.OnlyTabTooltips and IsTooltipLabel(Object) then
                        local Tx = SafeGet(Object, "Text")
                        if not (type(Tx) == "string" and TabTooltipText[Tx]) then
                            if Grad.Enabled then Grad.Enabled = false end
                            if OrigColor[Object] ~= nil then
                                Object.TextColor3 = OrigColor[Object]
                            end
                            return
                        end
                    end
                    -- Tooltip 浮层显示「标签页提示」时需白基底才能正确流光；
                    --   它全局只有一个实例，每帧写一次白基底开销可忽略
                    --   （与「全部目标」每帧强刷白基底有本质区别）。
                    if IsTooltipLabel(Object) then
                        pcall(function() Object.TextColor3 = WHITE end)
                    end
                    -- ② 旧模块的 SyncDynamicGradients 每帧可能把复用的渐变
                    --    Enabled 关掉，这里每帧最后写回 true，保证流光盖住它；
                    --    只在它被改掉时才写，避免无谓的属性写。
                    if not Grad.Enabled then Grad.Enabled = true end

                    -- ③ 旋转 / 透明度：用脏标记（AppliedRot / AppliedTrans），
                    --    值没变就跳过 Roblox 属性写。非玻璃目标这两项本就是常数，
                    --    每目标只写一次；玻璃目标的透明度也是常数，只有旋转随摆动变。
                    local nRot, nTrans
                    if IconSet[Object] and M.IconGlass and GLASS_TRANS then
                        -- 图标级液态玻璃：库 AddGlassSheen 的 112° 斜向高光带，
                        -- 与每帧重建的流光 ColorSequence 叠在同一条 UIGradient 上
                        -- （一个 GuiObject 只留一条渐变，绝不互抢）
                        nRot   = (M.GlassRotation or 112)
                                 + math.sin(Clock * M.SwaySpeed) * (M.GlassSway or 0)
                        nTrans = GLASS_TRANS
                    else
                        nRot   = Rot
                        nTrans = CLEAR_TRANS   -- 关玻璃 / 目标是文字时复位（可能为 nil）
                    end
                    if AppliedRot[Grad] ~= nRot then
                        Grad.Rotation = nRot; AppliedRot[Grad] = nRot
                    end
                    if nTrans and AppliedTrans[Grad] ~= nTrans then
                        Grad.Transparency = nTrans; AppliedTrans[Grad] = nTrans
                    end

                    -- ④ 颜色流光 + 横向平移：流动效果本身，仅在 30fps 降频帧写
                    Grad.Color  = Seq
                    Grad.Offset = Off
                    -- ⑤ 白基底由 Attach 里的事件监听负责（主题回流即重设白），
                    --    本循环完全不再触碰 TextColor3 / ImageColor3。
                end)
            end
        end
    end

    -- ---------------------- 开关 ----------------------
    function M:Enable()
        M.Enabled = true
        FirstFrame = true
        pcall(BuildPalette)
        pcall(Scan)
        if not Started and Heartbeat then
            Started = true
            local Ok = pcall(function()
                Conn = Heartbeat:Connect(function(dt) pcall(Tick, dt) end)
                Library:GiveSignal(Conn)   -- 交给库统一断开，卸载不残留
            end)
            if not Ok then Started = false end
        end
        pcall(Tick, 0)   -- 首帧立刻铺上，不等第一个 Interval
        return self
    end

    function M:Disable()
        M.Enabled = false
        if Conn then
            pcall(function() Conn:Disconnect() end)
            Conn, Started = nil, false
        end
        for Object, Grad in pairs(Targets) do
            pcall(function()
                if Grad.Name == "YXLibFlowGradient" then Grad:Destroy() end
            end)
            Targets[Object] = nil
        end
        -- 断开所有白基底事件监听
        for Object, C in pairs(WhiteConns) do
            pcall(function() C:Disconnect() end)
            WhiteConns[Object] = nil
        end
        for K in pairs(Seen) do Seen[K] = nil end
        for K in pairs(FontTag) do FontTag[K] = nil end
        for K in pairs(WantedInst) do WantedInst[K] = nil end
        for K in pairs(IconSet) do IconSet[K] = nil end
        for K in pairs(HolderCache) do HolderCache[K] = nil end
        -- 恢复图标被白基底改掉的原色（Registry 不一定登记 ImageColor3）
        for Object, C in pairs(IconOrigColor) do
            if C ~= nil then
                pcall(function()
                    if IsImageObject(Object) then Object.ImageColor3 = C
                    else Object.TextColor3 = C end
                end)
            end
            IconOrigColor[Object] = nil
        end
        for Object, C in pairs(OrigColor) do
            pcall(function() Object.TextColor3 = C end)
            OrigColor[Object] = nil
        end
        pcall(function() Library:UpdateColorsUsingRegistry() end)
        return self
    end

    -- 运行时改配置（数值都对应上面的「库参数对照表」）
    function M:SetSpeed(V)          -- 一键整体调速：颜色 / 平移 / 摆动按比例联动
        if type(V) ~= "number" or V <= 0 then return self end
        local R = V / 0.75
        M.Speed       = V
        M.OffsetSpeed = 0.75 * R
        M.SwaySpeed   = 1.70 * R
        return self
    end
    function M:SetBrightness(V)     -- 0=强调色原色（偏暗），1=接近纯白
        if type(V) ~= "number" then return self end
        M.Brightness = math.max(0, math.min(1, V))
        pcall(BuildPalette)
        return self
    end
    function M:SetPalette(UseLibrary)
        M.UseLibraryPalette = UseLibrary and true or false
        pcall(BuildPalette)
        return self
    end
    function M:SetWindowTexts(T)    -- 运行时换窗口 Title / Footer
        if type(T) ~= "table" then return self end
        M.WindowTexts = T
        pcall(RebuildTargets)
        for K in pairs(Seen) do Seen[K] = nil end
        pcall(Scan)
        return self
    end
    M.SetTargets = M.SetWindowTexts   -- 兼容旧调用名

    -- ===== 本版新增的运行时开关 =====
    function M:SetAllIcons(V)           -- 所有图标流光 开/关
        M.IncludeAllIcons = V and true or false
        for K in pairs(Seen) do Seen[K] = nil end
        pcall(Scan)
        return self
    end
    function M:SetIconGlass(V)          -- 图标液态玻璃高光 开/关
        M.IconGlass = V and true or false
        if M.IconGlass then pcall(BuildGlassTrans) end
        return self
    end
    function M:SetGlassStrength(V)      -- 玻璃感强度 0~1（0=清晰，1=很淡）
        if type(V) ~= "number" then return self end
        M.GlassMaxTrans = math.max(0, math.min(1, V))
        pcall(BuildGlassTrans)
        return self
    end
    function M:SetExcludeWindowIcon(V)  -- 窗口 Icon 排除 开/关
        M.ExcludeWindowIcon = V and true or false
        for K in pairs(HolderCache) do HolderCache[K] = nil end
        for K in pairs(Seen) do Seen[K] = nil end
        pcall(Scan)
        return self
    end

    return M
end)(Library)

-- [内嵌] YXLibTextFlow:Enable() -> 已移至 YXStart() 统一启动
-- ============================================================================

-- ============================================================================
-- YX 内嵌启动器：由 Library:CreateWindow 在窗口与标签页就绪后调用（仅一次）
-- ============================================================================
local YXStarted = false
local function YXStart()
    if YXStarted then return end
    YXStarted = true
    pcall(function() Bg:Enable() end)
    pcall(function() YXGradientBorder:Enable() end)
    pcall(function() YXLiquidGlass:Enable() end)
    pcall(function() YXGlassBackdrop:Enable() end)
    pcall(function() YXLibTextFlow:Enable() end)
end

local function YXStop()
    pcall(function() YXLibTextFlow:Disable() end)
    pcall(function() YXGlassBackdrop:Disable() end)
    pcall(function() YXLiquidGlass:Disable() end)
    pcall(function() YXGradientBorder:Disable() end)
    pcall(function() Bg:Disable() end)
end
table.insert(Library.UnloadSignals, YXStop)

-- 暴露控制接口：主脚本可用 Library.YX.* 运行时调整，或 Library.YX.Background:SetThemeManager(tm)
Library.YX = {
    Background = Bg,
    Border     = YXGradientBorder,
    Glass      = YXLiquidGlass,
    Backdrop   = YXGlassBackdrop,
    TextFlow   = YXLibTextFlow,
    Start      = YXStart,
    Stop       = YXStop,
}

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Vector2.new(math.min(WindowInfo.MinContainerWidth, MaxX), Library.OriginalMinSize.Y)

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)

    local TabButtonsStyle = WindowInfo.TabButtonsStyle

    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64 + TabButtonsStyle.Padding * 2, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(40 + TabButtonsStyle.Padding * 2, WindowInfo.CompactWidthActivation)
    WindowInfo.SnapDistance = math.max(0, WindowInfo.SnapDistance)
    WindowInfo.SnapMargin = math.max(0, WindowInfo.SnapMargin)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch

    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local HasBackgroundImage = false
    local BottomBackground
    local BottomBackgroundCorner
    local FooterLabel
    local TopBar
    local WindowSnapConfig = {
        Enabled = WindowInfo.Snapping,
        Distance = WindowInfo.SnapDistance,
        Margin = WindowInfo.SnapMargin,
        AvoidCoreGui = WindowInfo.SnapAvoidCoreGui,
    }

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth
    local RefreshWindowTitleSize

    do
        local KeybindFrame, KeybindContainer, _, KeybindDivider, KeybindLabelPadding = Library:AddDraggableMenu("Keybinds")
        KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        KeybindFrame.Visible = false
        KeybindLabelPadding.PaddingRight = UDim.new(0, 34)

        local HeaderButtons = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -8, 0, 17),
            Size = UDim2.fromOffset(0, 22),
            ZIndex = 2,
            Parent = KeybindFrame,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            Parent = HeaderButtons,
        })

        local SettingsButton = Library:CreateIcon(SettingsIcon, {
            ImageColor3 = "FontColor",
            LayoutOrder = 1,
            Size = UDim2.fromOffset(18, 18),
            Visible = false,
            ZIndex = 2,
            Parent = HeaderButtons,
        }, true)

        local CollapseButton = Library:CreateIcon(ArrowIcon, {
            ImageColor3 = "FontColor",
            LayoutOrder = 2,
            Rotation = 180,
            Size = UDim2.fromOffset(18, 18),
            ZIndex = 2,
            Parent = HeaderButtons,
        }, true)

        local SettingsFrame, SettingsContainer, _, _, SettingsLabelPadding = Library:AddDraggableMenu("Visible Keybinds")
        SettingsFrame.Visible = false
        SettingsLabelPadding.PaddingRight = UDim.new(0, 34)

        local CloseSettingsButton = Library:CreateIcon(CloseIcon, {
            AnchorPoint = Vector2.new(1, 0.5),
            ImageColor3 = "FontColor",
            Position = UDim2.new(1, -8, 0, 17),
            Size = UDim2.fromOffset(18, 18),
            ZIndex = 2,
            Parent = SettingsFrame,
        }, true)

        local KeybindMenu = {
            VisibilityControl = false,
            Collapsed = false,
            SettingsOpen = false,
            Frame = KeybindFrame,
            Container = KeybindContainer,
            SettingsFrame = SettingsFrame,
            SettingsContainer = SettingsContainer,
        }

        function KeybindMenu:RefreshSettings()
            for _, Child in SettingsContainer:GetChildren() do
                if Child:IsA("GuiObject") and not Child:IsA("UIListLayout") and not Child:IsA("UIPadding") then
                    Child:Destroy()
                end
            end

            for Idx, Option in Options do
                if Option.Type ~= "KeyPicker" or Option.NoUI == true then
                    continue
                end

                local Holder = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = "",
                    Parent = SettingsContainer,
                })

                local Visible = Option.MenuVisible ~= false
                New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(22, 0),
                    Size = UDim2.fromScale(0, 1),
                    Text = ("[%s] %s (%s)"):format(
                        Option.DisplayValue or Option.Value or "None",
                        Option.Text or tostring(Idx),
                        Option.Mode or "Toggle"
                    ),
                    TextSize = 14,
                    TextTransparency = Visible and 0 or 0.5,
                    Parent = Holder,
                })

                local Checkbox = New("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = "MainColor",
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(14, 14),
                    Parent = Holder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                        Parent = Checkbox,
                    })
                )
                New("UIStroke", {
                    Color = "OutlineColor",
                    Parent = Checkbox,
                })

                Library:CreateIcon(CheckIcon, {
                    ImageColor3 = "FontColor",
                    ImageTransparency = Visible and 0 or 1,
                    Position = UDim2.fromOffset(2, 2),
                    Size = UDim2.new(1, -4, 1, -4),
                    Parent = Checkbox,
                })

                Holder.MouseButton1Click:Connect(function()
                    local Picker = Options[Idx]
                    if not (Picker and Picker.Type == "KeyPicker" and Picker.SetMenuVisibility) then
                        return
                    end

                    Picker:SetMenuVisibility(Picker.MenuVisible == false)
                end)
            end
        end

        function KeybindMenu:SetCollapsed(Collapsed: boolean)
            Collapsed = Collapsed == true
            KeybindMenu.Collapsed = Collapsed

            KeybindContainer.Visible = not Collapsed
            KeybindDivider.Visible = not Collapsed

            if Collapsed then
                local Width = math.max(160, KeybindFrame.AbsoluteSize.X / Library.DPIScale)
                KeybindFrame.AutomaticSize = Enum.AutomaticSize.None
                KeybindFrame.Size = UDim2.fromOffset(Width, 34)
                CollapseButton.Rotation = 0
            else
                KeybindFrame.AutomaticSize = Enum.AutomaticSize.XY
                KeybindFrame.Size = UDim2.fromOffset(0, 0)
                CollapseButton.Rotation = 180
            end
        end

        function KeybindMenu:ToggleCollapsed()
            KeybindMenu:SetCollapsed(not KeybindMenu.Collapsed)
        end

        function KeybindMenu:SetSettingsOpen(Open: boolean)
            Open = Open == true
            if Open and not KeybindMenu.VisibilityControl then
                return
            end

            KeybindMenu.SettingsOpen = Open
            SettingsFrame.Visible = Open

            if Open then
                KeybindMenu:RefreshSettings()

                local Bounds = Floats.AbsoluteSize
                local Pos = KeybindFrame.AbsolutePosition - Floats.AbsolutePosition
                local Size = KeybindFrame.AbsoluteSize
                local SettingsSize = SettingsFrame.AbsoluteSize

                local X = Pos.X + Size.X + 8
                if X + SettingsSize.X > Bounds.X then
                    X = Pos.X - SettingsSize.X - 8
                end

                SettingsFrame.Position = UDim2.fromOffset(
                    math.clamp(X, 0, math.max(0, Bounds.X - SettingsSize.X)),
                    math.clamp(Pos.Y, 0, math.max(0, Bounds.Y - SettingsSize.Y))
                )
            end
        end

        function KeybindMenu:ToggleSettings()
            KeybindMenu:SetSettingsOpen(not KeybindMenu.SettingsOpen)
        end

        function KeybindMenu:SetVisibilityControl(Enabled: boolean)
            Enabled = Enabled == true
            KeybindMenu.VisibilityControl = Enabled
            SettingsButton.Visible = Enabled
            KeybindLabelPadding.PaddingRight = UDim.new(0, Enabled and 56 or 34)

            if not Enabled then
                KeybindMenu:SetSettingsOpen(false)
            end
        end

        function KeybindMenu:Destroy()
            local DraggableIndex = table.find(Library.DraggableElements, SettingsFrame)
            if DraggableIndex then
                table.remove(Library.DraggableElements, DraggableIndex)
            end

            SettingsFrame:Destroy()
            KeybindMenu.SettingsFrame = nil
            KeybindMenu.SettingsContainer = nil
            KeybindMenu.SettingsOpen = false
            Library.KeybindMenu = nil
        end

        SettingsButton.MouseButton1Click:Connect(function()
            KeybindMenu:ToggleSettings()
        end)
        CollapseButton.MouseButton1Click:Connect(function()
            KeybindMenu:ToggleCollapsed()
        end)
        CloseSettingsButton.MouseButton1Click:Connect(function()
            KeybindMenu:SetSettingsOpen(false)
        end)

        Library.KeybindFrame = KeybindFrame
        Library.KeybindContainer = KeybindContainer
        Library.KeybindMenu = KeybindMenu

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        HasBackgroundImage = BackgroundIcon ~= nil
        BackgroundImage = New("ImageLabel", {
            Active = false,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = Overlay.ZIndex + 1,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = false,
            Parent = ScreenGui,
        })
        FillInstance(ImageContent(BackgroundIcon), BackgroundImage)

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        Library:GiveSignal(RunService.RenderStepped:Connect(function()
            if not (BackgroundImage and MainFrame) then
                return
            end

            local ShouldShow = HasBackgroundImage and MainFrame.Visible
            BackgroundImage.Visible = ShouldShow

            if not ShouldShow then
                return
            end

            BackgroundImage.Position = UDim2.fromOffset(
                MainFrame.AbsolutePosition.X,
                MainFrame.AbsolutePosition.Y
            )
            BackgroundImage.Size = UDim2.fromOffset(
                MainFrame.AbsoluteSize.X,
                MainFrame.AbsoluteSize.Y
            )
        end))

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        --// Top Bar \\-
        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true, WindowSnapConfig)

        --// Title \\--
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            WindowIcon = Library:CreateIcon(Library:GetCustomIcon(WindowInfo.Icon), {
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(0, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = TitleHolder,
        })

        RefreshWindowTitleSize = function()
            local IconWidth = 0
            if WindowIcon and WindowIcon.Visible then
                IconWidth = WindowIcon.Size.X.Offset + 6
            end

            local MaxWidth = math.max(0, (TitleHolder.AbsoluteSize.X / Library.DPIScale) - IconWidth - 12)
            local NaturalWidth = Library:GetTextBounds(WindowTitle.Text, Library.Scheme.Font, WindowTitle.TextSize)
            WindowTitle.Size = UDim2.new(0, math.min(NaturalWidth, MaxWidth), 1, 0)
        end
        RefreshWindowTitleSize()

        --// Top Right Bar \\--
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -49, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 57 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        local SearchBoxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        Library:GiveSignal(SearchBox.Focused:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "AccentColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.AccentColor,
            }):Play()
        end))

        Library:GiveSignal(SearchBox.FocusLost:Connect(function()
            Library.Registry[SearchBoxStroke].Color = "OutlineColor"
            TweenService:Create(SearchBoxStroke, Library.TweenInfo, {
                Color = Library.Scheme.OutlineColor,
            }):Play()
        end))

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            Library:CreateIcon(SearchIcon, {
                ImageColor3 = "FontColor",
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
        end

        if MoveIcon then
            Library:CreateIcon(MoveIcon, {
                AnchorPoint = Vector2.new(1, 0.5),
                ImageColor3 = "OutlineColor",
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 28),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TopBar,
            })
        end

        --// Bottom Bar \\--
        local BottomClip = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 3,
            Parent = MainFrame,
        })

        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, math.max(20, WindowInfo.CornerRadius * 2)),
            ZIndex = 3,
            Parent = BottomClip,
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 3,
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 4,
            Parent = MainFrame,
        })
        BottomBackgroundCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
            BottomRightRadius = UDim.new(0, WindowInfo.CornerRadius),
            Parent = BottomBackground,
        })

        --// Footer \\-
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        --// Resize Button \\--
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
            end)
        end

        Library:CreateIcon(ResizeIcon, {
            ImageColor3 = "FontColor",
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        })

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, TabButtonsStyle.Gap),
            Parent = Tabs,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, TabButtonsStyle.Padding),
            PaddingLeft = UDim.new(0, TabButtonsStyle.Padding),
            PaddingRight = UDim.new(0, TabButtonsStyle.Padding),
            PaddingTop = UDim.new(0, TabButtonsStyle.Padding),
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            ClipsDescendants = true,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })

        Library.WindowContainer = Container
    end

    --// Window Table \\--
    local Window = {}
    local Fading = false

    local function SetUICorner(UICorner, Corner, HalfValue)
        local Current = UICorner[Corner]
        if Current.Offset == 0 and Current.Scale == 0 then
            return
        end

        UICorner[Corner] = HalfValue
    end

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
        RefreshWindowTitleSize()
    end

    function Window:RefreshTitleSize()
        RefreshWindowTitleSize()
    end

    function Window:SetBackgroundImage(Image: string)
        local ValidIcon = false

        if typeof(Image) == "string" then
            local BackgroundIcon = Library:GetCustomIcon(Image)

            if BackgroundIcon then
                ValidIcon = true

                FillInstance(ImageContent(BackgroundIcon), BackgroundImage)
            elseif Image:match("http://") or Image:match("https://") then
                local RawFileName = Image:match("(.+)%..+$")
                local _, Domain = Image:match("^(https?://)([^/]+)");

                if RawFileName and Domain then
                    local Extention = string.sub(Image, #RawFileName + 1, #Image)
                    local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                    local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                    if FileName then
                        ValidIcon = true

                        local AssetName = Domain .. FileName
                        if #AssetName > 255 then
                            local NewLength = 255 - #Domain - #Extention
                            if NewLength < 0 then
                                AssetName = Domain .. Extention
                            else
                                AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                            end
                        end

                        if CustomImageManagerAssets[FileName] == nil then
                            CustomImageManager.AddAsset(FileName, 0, Image)
                        else
                            CustomImageManager.DownloadAsset(FileName, true)
                        end

                        FillInstance(ImageContent({ Url = CustomImageManager.GetAsset(FileName) }), BackgroundImage)
                    end
                end
            end
        end

        if not ValidIcon then
            FillInstance(ImageContent(nil), BackgroundImage)
        end

        HasBackgroundImage = ValidIcon
        WindowInfo.BackgroundImage = Image
    end

    function Window:SetFooter(Footer: string)
        assert(typeof(Footer) == "string", "Expected string for footer got: " .. typeof(Footer))

        FooterLabel.Text = Footer
        WindowInfo.Footer = Footer
    end

    function Window:SetAlwaysOnTop(Enabled: boolean)
        WindowInfo.AlwaysOnTop = Enabled == true
        SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
    end

    function Window:SetSnapping(Enabled: boolean, Distance: number?, Margin: number?, AvoidCoreGui: boolean?)
        WindowInfo.Snapping = Enabled == true
        WindowSnapConfig.Enabled = WindowInfo.Snapping

        if Distance then
            WindowInfo.SnapDistance = math.max(0, Distance)
            WindowSnapConfig.Distance = WindowInfo.SnapDistance
        end

        if Margin then
            WindowInfo.SnapMargin = math.max(0, Margin)
            WindowSnapConfig.Margin = WindowInfo.SnapMargin
        end

        if AvoidCoreGui ~= nil then
            WindowInfo.SnapAvoidCoreGui = AvoidCoreGui == true
            WindowSnapConfig.AvoidCoreGui = WindowInfo.SnapAvoidCoreGui
        end
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        Radius = math.min(Radius, 20)

        local RadiusHalf = UDim.new(0, Radius / 2)
        local RadiusUDim = UDim.new(0, Radius)
        local HalfCurrent = Library.CornerRadius / 2

        for _, UICorner in Library.Corners do
            if math.abs(UICorner.CornerRadius.Offset - HalfCurrent) < 0.001 then
                UICorner.CornerRadius = RadiusHalf
            else
                UICorner.CornerRadius = RadiusUDim
            end
        end

        for _, UICorner in Library.SpecificCorners do
            SetUICorner(UICorner, "TopRightRadius", RadiusHalf)
            SetUICorner(UICorner, "TopLeftRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomRightRadius", RadiusHalf)
            SetUICorner(UICorner, "BottomLeftRadius", RadiusHalf)
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        if ResizeButton then
            ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0)
        end
        if BottomBackgroundCorner then
            BottomBackground.Size = UDim2.new(1, 0, 0, math.max(20, Radius * 2))
            BottomBackgroundCorner.BottomLeftRadius = RadiusUDim
            BottomBackgroundCorner.BottomRightRadius = RadiusUDim
        end

        for _, Menu in Library.ContextMenus do
            if Menu.Destroyed then
                continue
            end

            if typeof(Menu.ActiveCallback) ~= "function" then
                continue
            end

            if not Menu.Active then
                local HolderActive = false
                for _, Other in Library.ContextMenus do
                    if Other == Menu then 
                        continue
                    end
   
                    if Other.Active and Other.Holder == Menu.Holder then
                        HolderActive = true
                        break
                    end
                end

                if HolderActive then
                    continue
                end

                Menu.ActiveCallback(false)
                continue
            end

            Menu.ActiveCallback(true)
        end

        for _, Option in Options do
            if Option.Type == "Dropdown" and Option.RefreshPool then
                Option:RefreshPool()
            end
        end

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
        if typeof(Animations) == "table" then
            WindowInfo.Animations = Animations
            Library.Animations = Animations
        end

        if typeof(TabTransitionTime) == "number" then
            local TweenInfo = TweenInfo.new(
                math.max(0, TabTransitionTime or 0.22),
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            WindowInfo.TabTransitionInfo = TweenInfo
            Library.TabTransitionInfo = TweenInfo
        end

        if typeof(TabSwipeOffset) == "number" then
            TabSwipeOffset = math.max(1, TabSwipeOffset)

            WindowInfo.TabSwipeOffset = TabSwipeOffset
            Library.TabSwipeOffset = TabSwipeOffset
        end

        if typeof(TabSwipeFrom) == "string" then
            TabSwipeFrom = string.lower(TabSwipeFrom)

            WindowInfo.TabSwipeFrom = TabSwipeFrom
            Library.TabSwipeFrom = TabSwipeFrom
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            if not Button.Icon then
                continue
            end

            Button.Label.Visible = not IsCompact
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        Width = math.clamp(Width, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 57 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
    
        RefreshWindowTitleSize()
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description or ""
        CurrentTabDescription.Visible = typeof(Description) == "string" and Description ~= ""

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end

    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

    local function CreateTab(ParentTab, ...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil
        local HasSubTabs = false

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
            HasSubTabs = Info.SubTabs == true and ParentTab == nil
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = if ParentTab then ParentTab.SubTabCount + 1 else #Tabs:GetChildren()
        end

        local TabKey = if ParentTab then ParentTab.Name .. "/" .. Name else Name

        local TabButton: TextButton
        local TabIndicator
        local TabStroke
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight

        local SubTabBar
        local SubTabHolder

        Icon = Library:GetCustomIcon(Icon)
        if ParentTab then
            TabButton = New("TextButton", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = "MainColor",
                LayoutOrder = Order,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                Parent = ParentTab.SubTabBar,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = TabButton,
                })
            )

            TabStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = TabButton,
            })
            Library:AddToRegistry(TabStroke, {
                Color = function()
                    return if ParentTab.ActiveSubTab and ParentTab.ActiveSubTab.Button == TabButton then Library.Scheme.AccentColor else Library.Scheme.OutlineColor
                end,
            })

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = TabButton,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    LayoutOrder = 1,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = TabButton,
                })
            end

            TabLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.fromOffset(0, 16),
                Text = Name,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = TabButton,
            })
        else
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })
            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })
        end

        --// Tab Container \\--
        TabContainer = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = if ParentTab then ParentTab.SubTabHolder else Container,
        })

        if HasSubTabs then
            SubTabBar = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromOffset(2, 5),
                ScrollBarThickness = 0,
                ScrollingDirection = Enum.ScrollingDirection.X,
                Size = UDim2.new(1, -4, 0, 30),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SubTabBar,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                PaddingTop = UDim.new(0, 3),
                Parent = SubTabBar,
            })

            Library:MakeLine(TabContainer, {
                Position = UDim2.fromOffset(-6, 40),
                Size = UDim2.new(1, 12, 0, 1),
            })

            SubTabHolder = New("Frame", {
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Position = UDim2.fromOffset(0, 41),
                Size = UDim2.new(1, 0, 1, -41),
                Parent = TabContainer,
            })
        else
            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            ParentTab = ParentTab,
            IsSubTab = ParentTab ~= nil,

            Button = TabButton,
            Container = TabContainer,
            Sides = {
                TabLeft,
                TabRight,
            },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "WARNING",
                Text = "",
            },

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},

            --// Sub Tabs \\--
            HasSubTabs = HasSubTabs,
            SubTabBar = SubTabBar,
            SubTabHolder = SubTabHolder,

            SubTabs = {},
            SubTabCount = 0,
            ActiveSubTab = nil,
            PreviousSubTab = nil,
        }

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = Color3.fromRGB(127, 0, 0),
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            Library:AddToRegistry(WarningBox, {
                BackgroundColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                end
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)
            Library:AddToRegistry(WarningBoxOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                end
            })
            Library:AddToRegistry(WarningBoxShadowOutline, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                end
            })

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })
            Library:AddToRegistry(WarningTitle, {
                TextColor3 = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                end
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })
            Library:AddToRegistry(WarningStroke, {
                Color = function()
                    return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                end
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = GetTextStrokeColor,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Handlers \\--
        function Tab:UpdateWarningBox(Info)
            if HasSubTabs then
                error(string.format("Tab '%s' uses SubTabs, update the warning box of a subtab instead", Name))
            end

            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Library.Registry[WarningBox].BackgroundColor3()
            WarningBoxShadowOutline.Color = Library.Registry[WarningBoxShadowOutline].Color()
            WarningBoxOutline.Color = Library.Registry[WarningBoxOutline].Color()
            WarningTitle.TextColor3 = Library.Registry[WarningTitle].TextColor3()
            WarningStroke.Color = Library.Registry[WarningStroke].Color()
        end

        function Tab:RefreshSides()
            if HasSubTabs then
                if Tab.ActiveSubTab then
                    Tab.ActiveSubTab:RefreshSides()
                end

                return
            end

            local Offset = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
            local Width = TabContainer.AbsoluteSize.X / Library.DPIScale
            local LeftWidth = math.floor(Width / 2 - 3)

            TabLeft.Position = UDim2.fromOffset(0, Offset)
            TabLeft.Size = UDim2.new(0, LeftWidth, 1, -Offset)

            TabRight.Position = UDim2.new(1, 0, 0, Offset)
            TabRight.Size = UDim2.new(0, Width - LeftWidth - 6, 1, -Offset)
        end
        table.insert(Tab.Connections, TabContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Tab:RefreshSides() end))

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor((TabContainer.AbsoluteSize.Y / Library.DPIScale) / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X / Library.DPIScale
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        local function AddTabbox(self, Info)
            Info = Library:Validate(Info, Templates.Tabbox)
            local ParentObj = self
            local IsNested = ParentObj.Type == "Groupbox" or ParentObj.Type == "SubTab"

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = if IsNested then ParentObj.Container else (Info.Side == 1 and TabLeft or TabRight),
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalTabs = 0
            local FirstTab
            local LastTab

            local Tabbox: any = {
                Type = "Tabbox",

                Connections = {},
                Destroyed = false,

                Visible = true,
                ActiveTab = nil,
                MaxHeight = Info.MaxHeight,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {},

                ParentBox = if IsNested then ParentObj else nil,
            }

            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:Resize()
                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
            end

            function Tabbox:SetMaxHeight(MaxHeight: number?)
                if MaxHeight ~= nil then
                    assert(typeof(MaxHeight) == "number", "MaxHeight must be a number or nil")
                    assert(MaxHeight > 0, "MaxHeight must be higher than 0")
                end

                Tabbox.MaxHeight = MaxHeight
                Tabbox:Resize()
            end

            function Tabbox:AddTab(Name, IconName, MaxHeight)
                TotalTabs = TotalTabs + 1
                local TabIndex = TotalTabs

                LastTab = TabIndex
                if not FirstTab then
                    FirstTab = TabIndex
                end

                local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                local Button = New("TextButton", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 0,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonCorner = New("UICorner", {
                    TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                    TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                    BottomRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, 0),
                    Parent = Button,
                }); table.insert(Library.SpecificCorners, ButtonCorner)

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                local BoxIcon = Library:GetCustomIcon(IconName)
                if BoxIcon then
                    ButtonIcon = Library:CreateIcon(BoxIcon, {
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageTransparency = 0.5,
                        Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                        Parent = ButtonContent,
                    })
                end

                local ButtonLabel
                if not IsNameEmpty then
                    ButtonLabel = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 16),
                        Text = Name,
                        TextSize = 15,
                        TextTransparency = 0.5,
                        Parent = ButtonContent,
                    })
                end

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.None,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromOffset(0, 0),
                    Position = UDim2.fromOffset(0, 35),
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    ScrollingEnabled = false,
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local Tab = {
                    Type = "SubTab",
                    Name = Name,
                    MaxHeight = MaxHeight,

                    Connections = {},
                    Destroyed = false,

                    ButtonHolder = Button,
                    Container = Container,
                    ButtonCorner = ButtonCorner,

                    Tab = Tab,
                    Tabbox = Tabbox,

                    Elements = {},
                    DependencyBoxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    Button.BackgroundTransparency = 1

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0
                    end
                    if ButtonIcon then
                        SetIconProperties(ButtonIcon, { ImageTransparency = 0 })
                    end

                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                    Tabbox:RefreshPopOutPlaceholder()
                end

                function Tab:Hide()
                    Button.BackgroundTransparency = 0

                    if ButtonLabel then
                        ButtonLabel.TextTransparency = 0.5
                    end
                    if ButtonIcon then
                        SetIconProperties(ButtonIcon, { ImageTransparency = 0.5 })
                    end
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    local ContentSize = (List.AbsoluteContentSize.Y / Library.DPIScale) + 14
                    local FrameSize = ContentSize
                    local TabMaxHeight = Tab.MaxHeight or Tabbox.MaxHeight
                    if Tabbox.PoppedOut then
                        FrameSize = math.min(ContentSize, GetPopOutBodyMaxHeight(Tabbox, 35))
                    elseif typeof(TabMaxHeight) == "number" then
                        FrameSize = math.min(ContentSize, math.max(TabMaxHeight - 35, 0))
                    end

                    local NeedsScroll = ContentSize > FrameSize + 1
                    Container.CanvasSize = UDim2.fromOffset(0, if NeedsScroll then ContentSize else 0)
                    Container.ScrollingEnabled = NeedsScroll
                    TabboxHolder.Size = UDim2.new(1, 0, 0, FrameSize + 35)

                    if IsNested then
                        ParentObj:Resize()
                    end
                end

                function Tab:SetMaxHeight(NewMaxHeight: number?)
                    if NewMaxHeight ~= nil then
                        assert(typeof(NewMaxHeight) == "number", "MaxHeight must be a number or nil")
                        assert(NewMaxHeight > 0, "MaxHeight must be higher than 0")
                    end

                    Tab.MaxHeight = NewMaxHeight
                    Tab:Resize()
                end

                function Tab:UpdateCorners()
                    local Radius = WindowInfo.CornerRadius

                    ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                    ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Element in Tab.Elements do
                        if Element.Destroy then
                            Element:Destroy()
                        end
                    end

                    for _, SubDepbox in Tab.DependencyBoxes do
                        if SubDepbox.Destroy then
                            SubDepbox:Destroy()
                        end
                    end

                    if Container then
                        Container:Destroy()
                    end

                    if Button then
                        Button:Destroy()
                    end
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                Tab.AddTabbox = AddTabbox
                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[TabStoringIndex] = Tab
                Tabbox:UpdateCorners()

                return Tab, TabStoringIndex
            end

            Library:MakeBoxPopOut(Tabbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = TabboxButtons,
                Children = function()
                    return { TabboxHolder }
                end,

                After = function()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Resize()
                    end
                    if IsNested then
                        ParentObj:Resize()
                    end
                end,
            })

            function Tabbox:Destroy()
                if Tabbox.PoppedOut then
                    Tabbox:SetPoppedOut(false)
                end

                Tabbox.Destroyed = true

                if Tabbox.Connections then
                    for _, Connection in Tabbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Tab in Tabbox.Tabs do
                    if Tab.Destroy then
                        Tab:Destroy()
                    end
                end

                if TabboxHolder then
                    TabboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

            return Tabbox
        end

        Tab.AddTabbox = function(self, Info)
            if HasSubTabs then
                error(string.format("Tab '%s' uses SubTabs, add tabboxes to a subtab instead", Name))
            end

            return AddTabbox(self, Info)
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        --// Deprecated - Use Tab:AddTabbox instead.
        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:AddGroupbox(Info)
            if HasSubTabs then
                error(string.format("Tab '%s' uses SubTabs, add groupboxes to a subtab instead", Name))
            end

            Info = Library:Validate(Info, Templates.Groupbox)

            if typeof(Info.Side) == "string" then
                local lowerSide = string.lower(Info.Side)
                if not SideIndex[lowerSide] then
                    error(string.format("Invalid side: %s", Info.Side))
                end

                Info.Side = SideIndex[lowerSide]
            end

            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = (Info.Side == 1) and TabLeft or TabRight,
            })
            local BoxHolderList = New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder

            local GroupboxTop
            local GroupboxLabel
            local GroupboxDescription

            local GroupboxContainer
            local GroupboxList

            local GroupboxCollapseArrow
            local GroupboxLine

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                New("UIListLayout", {
                    Parent = GroupboxHolder,
                })
                Library:AddOutline(GroupboxHolder)

                GroupboxTop = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    Parent = GroupboxTop,
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    Library:CreateIcon(BoxIcon, {
                        AnchorPoint = Vector2.new(0, 0.5),
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxTop,
                    })
                end

                local RightInset = if Info.DisableCollapsing ~= true then 22 else 0
                local TextsFrame = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -RightInset - (BoxIcon and 24 or 0), 0, 0),
                    Parent = GroupboxTop,
                })
                New("UIListLayout", {
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 3),
                    Parent = TextsFrame,
                })

                GroupboxLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Name,
                    TextSize = 15,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextsFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 1),
                    Parent = GroupboxLabel,
                })

                GroupboxDescription = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    Text = Info.Description or "",
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = (Info.Description ~= nil),
                    Parent = TextsFrame,
                })

                GroupboxCollapseArrow = Library:CreateIcon(ArrowIcon, {
                    Visible = Info.DisableCollapsing ~= true,
                    AnchorPoint = Vector2.new(1, 0.5),
                    ImageColor3 = "WhiteColor",
                    Position = UDim2.fromScale(1, 0.5),
                    Rotation = 180,
                    Size = UDim2.fromOffset(22, 22),
                    Parent = GroupboxTop,
                }, true)

                GroupboxLine = Library:MakeLine(GroupboxHolder, {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 1),
                })

                GroupboxContainer = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.None,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromOffset(0, 0),
                    LayoutOrder = 2,
                    ScrollBarImageTransparency = 1,
                    ScrollBarThickness = 0,
                    ScrollingEnabled = false,
                    Size = UDim2.fromScale(1, 0),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })
            end

            local Groupbox: any = {
                Type = "Groupbox",

                Name = Info.Name,
                Description = Info.Description,

                Connections = {},
                Destroyed = false,

                Visible = true,
                Collapsed = false,
                MaxHeight = Info.MaxHeight,

                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,

                Tab = Tab,
                DependencyBoxes = {},
                Elements = {}
            }

            local ResizeTween
            local CollapseArrowTween

            local function RefreshBoxHolderLayout()
                BoxHolder.AutomaticSize = Enum.AutomaticSize.None
                BoxHolder.Size = UDim2.new(1, 0, 0, BoxHolderList.AbsoluteContentSize.Y / Library.DPIScale + 8)
                BoxHolder.AutomaticSize = Enum.AutomaticSize.Y
            end
            Groupbox.RefreshBoxHolderLayout = RefreshBoxHolderLayout

            function Groupbox:Resize()
                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                local TopSize = (GroupboxTop.AbsoluteSize.Y / Library.DPIScale)
                local ContentSize = (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 14
                local ContainerSize = ContentSize
                if Groupbox.PoppedOut then
                    ContainerSize = math.min(ContainerSize, GetPopOutBodyMaxHeight(Groupbox, TopSize + 1))
                elseif typeof(Groupbox.MaxHeight) == "number" then
                    ContainerSize = math.min(ContainerSize, math.max(Groupbox.MaxHeight - TopSize - 1, 0))
                end

                local NeedsScroll = ContentSize > ContainerSize + 1
                GroupboxContainer.CanvasSize = UDim2.fromOffset(0, if NeedsScroll then ContentSize else 0)
                GroupboxContainer.ScrollingEnabled = NeedsScroll

                local TargetSize = UDim2.new(1, 0, 0, if Groupbox.Collapsed then TopSize else (TopSize + 1 + ContainerSize))
                GroupboxContainer.Size = UDim2.new(1, 0, 0, ContainerSize)
                GroupboxLine.Visible = not Groupbox.Collapsed

                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxHolder, TweenInfo, { Size = TargetSize })
                    ResizeTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Once(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if ResizeTween == Tween then
                            StopTween(ResizeTween, true)
                            ResizeTween = nil
                        end

                        RefreshBoxHolderLayout()
                    end))

                    Tween:Play()
                else
                    GroupboxHolder.Size = TargetSize
                    RefreshBoxHolderLayout()
                end
            end

            table.insert(Groupbox.Connections, GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Groupbox.Visible == false or Groupbox.Destroyed then
                    return
                end

                Groupbox:Resize()
            end))

            function Groupbox:SetDescription(Description: string | nil)
                Groupbox.Description = Description
                GroupboxDescription.Text = Description or ""
                GroupboxDescription.Visible = (Description ~= nil)

                Groupbox:Resize()
            end

            function Groupbox:SetCollapsed(Collapsed: boolean)
                if Info.DisableCollapsing == true then return end
                Groupbox.Collapsed = Collapsed

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                local TargetRotation = if Collapsed then 0 else 180

                GroupboxContainer.Visible = not Collapsed
                if Library.Animations and Library.Animations.Groupbox then
                    local TweenInfo = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    local Tween = TweenService:Create(GroupboxCollapseArrow, TweenInfo, { Rotation = TargetRotation })
                    CollapseArrowTween = Tween

                    local Connection; Connection = Library:GiveSignal(Tween.Completed:Connect(function()
                        if Connection then
                            Connection:Disconnect()
                        end

                        if CollapseArrowTween == Tween then
                            StopTween(CollapseArrowTween, true)
                            CollapseArrowTween = nil
                        end
                    end))

                    Tween:Play()
                else
                    GroupboxCollapseArrow.Rotation = TargetRotation
                end

                Groupbox:Resize()
            end

            function Groupbox:ToggleCollapsed()
                if Info.DisableCollapsing == true then return end
                Groupbox:SetCollapsed(not Groupbox.Collapsed)
            end

            function Groupbox:SetMaxHeight(MaxHeight: number?)
                if MaxHeight ~= nil then
                    assert(typeof(MaxHeight) == "number", "MaxHeight must be a number or nil")
                    assert(MaxHeight > 0, "MaxHeight must be higher than 0")
                end

                Groupbox.MaxHeight = MaxHeight
                Groupbox:Resize()
            end

            Library:MakeBoxPopOut(Groupbox, {
                Enabled = Info.PopOut ~= false,
                MaxPopOutHeight = Info.MaxPopOutHeight,
                PopOutWidth = Info.PopOutWidth,

                Header = GroupboxTop,
                Children = function()
                    local Children = {}
                    for _, Child in BoxHolder:GetChildren() do
                        if Child:IsA("GuiObject") and Child ~= Groupbox.PopOutPlaceholder then
                            table.insert(Children, Child)
                        end
                    end
                    return Children
                end,

                Before = function()
                    GroupboxCollapseArrow.Visible = false
                end,
                After = function()
                    GroupboxCollapseArrow.Visible = Info.DisableCollapsing ~= true
                    Groupbox:Resize()
                end
            })

            function Groupbox:Destroy()
                if Groupbox.PoppedOut then
                    Groupbox:SetPoppedOut(false)
                end

                Groupbox.Destroyed = true

                if ResizeTween then
                    StopTween(ResizeTween, true)
                    ResizeTween = nil
                end

                if CollapseArrowTween then
                    StopTween(CollapseArrowTween, true)
                    CollapseArrowTween = nil
                end

                if Groupbox.Connections then
                    for _, Connection in Groupbox.Connections do
                        Connection:Disconnect()
                    end
                end

                for _, Element in Groupbox.Elements do
                    if Element.Destroy then
                        Element:Destroy()
                    end
                end
                table.clear(Groupbox.Elements)

                for _, SubDepbox in Groupbox.DependencyBoxes do
                    if SubDepbox.Destroy then
                        SubDepbox:Destroy()
                    end
                end
                table.clear(Groupbox.DependencyBoxes)

                if GroupboxHolder then
                    GroupboxHolder:Destroy()
                end

                if BoxHolder then
                    BoxHolder:Destroy()
                end
            end

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                BoxHolder.Visible = Visible
                SyncPopOutVisibility(Groupbox)

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            if Info.DisableCollapsing ~= true then
                GroupboxCollapseArrow.MouseButton1Click:Connect(function()
                    Groupbox:ToggleCollapsed()
                end)
            end

            Groupbox.AddTabbox = AddTabbox
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            if Info.Visible == false then
                Groupbox:Hide()
            end

            if Info.DisableCollapsing ~= true and Info.Collapsed == true then
                Groupbox:SetCollapsed(true)
            end

            return Groupbox
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        --// Deprecated - Use Tab:AddGroupbox instead.
        function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
        end

        local function IsActive()
            if ParentTab then
                return ParentTab.ActiveSubTab == Tab
            end

            return Library.ActiveTab == Tab
        end

        function Tab:Hover(Hovering)
            if IsActive() then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Hovering and 0.25 or 0.5 })
            end
        end

        function Tab:UpdateTabInfo()
            local SubTab = Tab.ActiveSubTab
            if SubTab then
                local Title = string.format('<font transparency="0.5">%s /</font> <b>%s</b>', Name, SubTab.Name)
                Window:ShowTabInfo(Title, SubTab.Description or Description)
            elseif Description then
                Window:ShowTabInfo(Name, Description)
            else
                Window:HideTabInfo()
            end
        end

        local function SetButtonActive(Active: boolean)
            if TabStroke then
                TweenService:Create(TabStroke, Library.TweenInfo, {
                    Color = Active and Library.Scheme.AccentColor or Library.Scheme.OutlineColor,
                }):Play()
            else
                TweenService:Create(TabButton, Library.TweenInfo, {
                    BackgroundTransparency = Active and 0 or 1,
                }):Play()
            end
            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = Active and 0 or 1,
                }):Play()
            end
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Active and 0 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Active and 0 or 0.5 })
            end
        end

        function Tab:Show(KeepParent: boolean?)
            if ParentTab then
                if ParentTab.ActiveSubTab == Tab then
                    if not KeepParent and Library.ActiveTab ~= ParentTab then
                        ParentTab:Show()
                    end

                    return
                end

                local ParentActive = Library.ActiveTab == ParentTab
                if ParentTab.ActiveSubTab then
                    ParentTab.ActiveSubTab:Hide()
                end

                ParentTab.ActiveSubTab = Tab
                ParentTab.Sides = Tab.Sides
                SetButtonActive(true)

                if ParentActive then
                    Library:PlayTabAnimation(Tab, true, nil, ParentTab.PreviousSubTab)
                    Tab:RefreshSides()
                    ParentTab:UpdateTabInfo()

                    if Library.Searching then
                        Library:UpdateSearch(Library.SearchText)
                    end
                else
                    TabContainer.Position = UDim2.fromScale(0, 0)
                    TabContainer.Visible = true
                    Tab:RefreshSides()

                    if not KeepParent then
                        ParentTab:Show()
                    end
                end

                return
            end

            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            SetButtonActive(true)
            Tab:UpdateTabInfo()

            Library:PlayTabAnimation(Tab, true)
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            SetButtonActive(false)

            if ParentTab then
                Library:PlayTabAnimation(Tab, false)

                ParentTab.PreviousSubTab = Tab
                if ParentTab.ActiveSubTab == Tab then
                    ParentTab.ActiveSubTab = nil
                    ParentTab.Sides = {}
                end

                return
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if Visible or not IsActive() then
                return
            end

            Tab:Hide()

            if ParentTab then
                for _, SubTab in ParentTab.SubTabs do
                    if SubTab ~= Tab and SubTab.Button.Visible then
                        SubTab:Show()
                        break
                    end
                end
            end
        end

        function Tab:AddSubTab(...)
            if not HasSubTabs then
                error(string.format("Tab '%s' was not created with SubTabs = true", Name))
            end

            local SubTab = CreateTab(Tab, ...)
            Tab.SubTabCount += 1
            table.insert(Tab.SubTabs, SubTab)

            if not Tab.ActiveSubTab then
                SubTab:Show(true)
            end

            return SubTab
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            for _, Groupbox in Tab.Groupboxes do
                if Groupbox.Destroy then
                    Groupbox:Destroy()
                end
            end
            table.clear(Tab.Groupboxes)

            for _, Tabbox in Tab.Tabboxes do
                if Tabbox.Destroy then
                    Tabbox:Destroy()
                end
            end
            table.clear(Tab.Tabboxes)

            for _, DepGroupbox in Tab.DependencyGroupboxes do
                if DepGroupbox.Destroy then
                    DepGroupbox:Destroy()
                end
            end

            for Index = #Tab.SubTabs, 1, -1 do
                local SubTab = Tab.SubTabs[Index]
                if SubTab and not SubTab.Destroyed then
                    SubTab:Destroy()
                end
            end
            table.clear(Tab.SubTabs)

            if ParentTab then
                local SubIndex = table.find(ParentTab.SubTabs, Tab)
                if SubIndex then
                    table.remove(ParentTab.SubTabs, SubIndex)
                end

                if ParentTab.ActiveSubTab == Tab then
                    ParentTab.ActiveSubTab = nil
                    ParentTab.Sides = {}

                    local NextSubTab = ParentTab.SubTabs[1]
                    if NextSubTab then
                        NextSubTab:Show(true)
                    end

                    if Library.ActiveTab == ParentTab then
                        ParentTab:UpdateTabInfo()
                    end
                end
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[TabKey] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not ParentTab and not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(function()
            Tab:Show()
        end)

        Library.Tabs[TabKey] = Tab

        return Tab
    end

    function Window:AddTab(...)
        return CreateTab(nil, ...)
    end

    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Description = Description,
            IsKeyTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Elements = {},

            Window = Window,
            Button = TabButton,
            Container = TabContainer
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })
            local BoxStroke = New("UIStroke", {
                Color = "OutlineColor",
                Parent = Box,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Box,
                })
            )

            Box.Focused:Connect(function()
                Library.Registry[BoxStroke].Color = "AccentColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.AccentColor,
                }):Play()
            end)

            Box.FocusLost:Connect(function()
                Library.Registry[BoxStroke].Color = "OutlineColor"
                TweenService:Create(BoxStroke, Library.TweenInfo, {
                    Color = Library.Scheme.OutlineColor,
                }):Play()
            end)

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                TextTransparency = 0.4,
                Parent = Holder,
            })
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                })
            )

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0,
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, Library.TweenInfo, {
                    TextTransparency = 0.4,
                }):Play()
            end)

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:Destroy()
            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Hovering and 0.25 or 0.5 })
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0 })
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0.5 })
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.MouseButton1Click:Connect(Tab.Show)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end

    function Window:AddCustomTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local Tooltip = nil
        local Order = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            Tooltip = Info.Tooltip
            Order = Info.Order
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
            Order = select(4, ...)
        end

        if not tonumber(Order) then
            Order = #Tabs:GetChildren()
        end

        local TabButton: TextButton
        local TabIndicator
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                LayoutOrder = Order,
                Parent = Tabs,
            })
            New("UICorner", {
                CornerRadius = UDim.new(0, TabButtonsStyle.CornerRadius),
                Parent = TabButton,
            })

            if TabButtonsStyle.Indicator then
                TabIndicator = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(TabButtonsStyle.IndicatorWidth, TabButtonsStyle.IndicatorHeight),
                    Parent = TabButton,
                })

                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = TabIndicator,
                })
            end

            local ButtonHolder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Parent = TabButton,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = ButtonHolder,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(30, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = ButtonHolder,
            })

            if Icon then
                TabIcon = Library:CreateIcon(Icon, {
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = ButtonHolder,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,
            IsCustomTab = true,

            Tooltip = Tooltip,
            TooltipTable = nil,

            Connections = {},
            Destroyed = false,

            Window = Window,
            Button = TabButton,
            Container = TabContainer,
            Sides = {},

            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
        }

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = Hovering and 0.25 or 0.5 })
            end
        end

        function Tab:Show()
            if Library.ActiveTab == Tab then
                return
            end

            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 0,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0 })
            end

            Library:PlayTabAnimation(Tab, true)

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()

            if TabIndicator then
                TweenService:Create(TabIndicator, Library.TweenInfo, {
                    BackgroundTransparency = 1,
                }):Play()
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()

            if TabIcon then
                TweenIcon(TabIcon, { ImageTransparency = 0.5 })
            end

            Library:PlayTabAnimation(Tab, false)
            Window:HideTabInfo()

            Library.PreviousTab = Tab
            Library.ActiveTab = nil
        end

        function Tab:SetVisible(Visible: boolean)
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(NewOrder: number)
            Order = NewOrder
            TabButton.LayoutOrder = Order
        end

        function Tab:SetTooltip(Text: string?)
            Tab.Tooltip = Text

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if typeof(Text) == "string" then
                Tab.TooltipTable = Library:AddTooltip(Text, nil, TabButton)
            end
        end

        function Tab:Destroy()
            Tab.Destroyed = true

            if Tab.Connections then
                for _, Connection in Tab.Connections do
                    Connection:Disconnect()
                end
            end

            if Tab.TooltipTable then
                Tab.TooltipTable:Destroy()
                Tab.TooltipTable = nil
            end

            if Library.ActiveTab == Tab then
                Tab:Hide()
            end

            if TabContainer then
                TabContainer:Destroy()
            end

            if TabButton then
                for Index, Entry in Library.TabButtons do
                    if typeof(Entry) == "table" and Entry.Button == TabButton then
                        table.remove(Library.TabButtons, Index)
                        break
                    end
                end

                TabButton:Destroy()
            end

            Library.Tabs[Name] = nil
        end

        --// Execution \\--
        if typeof(Tooltip) == "string" then
            Tab.TooltipTable = Library:AddTooltip(Tooltip, nil, TabButton)
        end

        if not Library.ActiveTab then
            Tab:Show()
        end

        table.insert(Tab.Connections, TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end))
        table.insert(Tab.Connections, TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end))
        table.insert(Tab.Connections, TabButton.MouseButton1Click:Connect(Tab.Show))

        Library.Tabs[Name] = Tab

        return TabContainer, Tab
    end

    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)

        local DialogFrame
        local DialogOverlay
        local DialogContainer
        local ButtonsHolder
        local FooterButtonsList = {}

        DialogOverlay = New("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = "DarkColor",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Active = false,
            ZIndex = 9000,
            Visible = true,
            Parent = MainFrame,
        })
        TweenService:Create(DialogOverlay, Library.TweenInfo, {
            BackgroundTransparency = 0.5,
        }):Play()

        DialogFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1,
            Parent = DialogOverlay,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = DialogFrame,
            })
        )
        Library:AddOutline(DialogFrame)

        local InnerContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = DialogFrame,
        })
        local DialogScale = New("UIScale", {
            Scale = 0.95,
            Parent = DialogFrame,
        })
        TweenService:Create(DialogScale, Library.TweenInfo, {
            Scale = 1
        }):Play()
        local _InnerPadding = New("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            Parent = InnerContainer,
        })
        local _InnerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = InnerContainer,
        })

        local HeaderContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = HeaderContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = HeaderContainer,
        })

        local TitleRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = HeaderContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 6),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TitleRow,
        })

        if Info.Icon then
            local ParsedIcon = Library:GetCustomIcon(Info.Icon)
            if ParsedIcon then
                Library:CreateIcon(ParsedIcon, {
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Info.TitleColor or "FontColor",
                    LayoutOrder = 1,
                    ZIndex = 2,
                    Parent = TitleRow,
                })
            end
        end

        local TitleLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Title,
            TextSize = 18,
            TextColor3 = Info.TitleColor or "FontColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = TitleRow,
        })

        local DescriptionLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = Info.Description,
            TextSize = 14,
            TextTransparency = Info.DescriptionColor and 0 or 0.2,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Info.DescriptionColor or "FontColor",
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = HeaderContainer,
        })

        DialogContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        local _DialogContainerLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DialogContainer,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 5),
            Parent = DialogContainer,
        })

        local _Sep2 = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 5,
            ZIndex = 2,
            Parent = InnerContainer,
        })

        ButtonsHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 6,
            ZIndex = 2,
            Parent = InnerContainer,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonsHolder,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            Parent = ButtonsHolder,
        })

        local Dialog = {
            Destroyed = false,
            Elements = {},
            Container = DialogContainer,
            OutsideClickDismiss = Info.OutsideClickDismiss,
        }

        function Dialog:Resize()
            local MaxWidth = (MainFrame.AbsoluteSize.X / Library.DPIScale) * 0.75
            local MinWidth = 400

            local TotalButtonWidth = 0
            local ButtonCount = 0
            local HasButtons = false

            for _, BtnWrap in FooterButtonsList do
                HasButtons = true
                ButtonCount = ButtonCount + 1
                TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
            end

            local TargetWidth = MinWidth
            if HasButtons then
                local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
            end

            DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

            local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
            DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

            local HasElements = false
            for _, v in DialogContainer:GetChildren() do
                if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                    HasElements = true
                    break
                end
            end
            DialogContainer.Visible = HasElements

            ButtonsHolder.Visible = HasButtons
            _Sep2.Visible = HasButtons
        end

        function Dialog:SetTitle(Title)
            TitleLabel.Text = Title
            Dialog:Resize()
        end

        function Dialog:SetDescription(Description)
            DescriptionLabel.Text = Description
            Dialog:Resize()
        end

        function Dialog:Dismiss()
            if Dialog.Destroyed then
                return
            end

            Dialog.Destroyed = true

            if Library.ActiveDialog == Dialog then
                Library.ActiveDialog = nil
            end

            for Index = #Dialog.Elements, 1, -1 do
                local Element = Dialog.Elements[Index]
                if Element and Element.Destroy then
                    Element:Destroy()
                end
            end
            table.clear(Dialog.Elements)

            local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
            TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            CloseTween:Play()

            task.delay(Library.TweenInfo.Time, function()
                DialogOverlay:Destroy()
            end)
            Library.Dialogues[Idx] = nil
        end

        DialogOverlay.MouseButton1Click:Connect(function()
            if Info.OutsideClickDismiss then
                Dialog:Dismiss()
            end
        end)

        function Dialog:RemoveFooterButton(ButtonIdx)
            if FooterButtonsList[ButtonIdx] then
                FooterButtonsList[ButtonIdx].Container:Destroy()
                FooterButtonsList[ButtonIdx] = nil
            end
        end

        function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
            if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
            end
        end

        function Dialog:SetButtonOrder(ButtonIdx, Order)
            if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
            end
        end

        function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
            Dialog:RemoveFooterButton(ButtonIdx)

            local WaitTime = ButtonInfo.WaitTime or 0

            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                LayoutOrder = ButtonInfo.Order or 0,
                ZIndex = 2,
                Parent = ButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            local _BtnPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or ButtonIdx,
                TextColor3 = TextColor,
                TextTransparency = WaitTime > 0 and 0.5 or 0,
                TextSize = 14,
                ZIndex = 2,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ProgressBar
            if WaitTime > 0 then
                ProgressBar = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -2),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 2,
                    Parent = TextBtn,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, Library.CornerRadius),
                        Parent = ProgressBar
                    })
                )
            end

            local IsActive = WaitTime <= 0

            local ButtonWrap = {
                Container = ButtonContainer,
                SetDisabled = function(self, Disabled)
                    IsActive = not Disabled
                    if Disabled then
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                    else
                        TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    end
                end
            }

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                if not IsActive then return end
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if not IsActive then return end
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Dialog)
                end
                if Info.AutoDismiss then
                    Dialog:Dismiss()
                end
            end)

            if WaitTime > 0 then
                TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(1, 0, 0, 2)
                }):Play()

                task.delay(WaitTime, function()
                    ButtonWrap:SetDisabled(false)
                    if ProgressBar then
                        TweenService:Create(ProgressBar, Library.TweenInfo, {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end)
            end

            FooterButtonsList[ButtonIdx] = ButtonWrap
        end

        for BIdx, BInfo in Info.FooterButtons do
            if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
            Dialog:AddFooterButton(BIdx, BInfo)
        end

        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog

        Dialog:Resize()

        Library.ActiveDialog = Dialog
        return Dialog
    end

    function Window:Toggle(Value: boolean?)
        if Fading then
            return
        end

        if Library.ActiveLoading then
            if Value == true then
                return
            end

            if not Library.Toggled then
                return
            end
        end

        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Animations and Library.Animations.ToggleWindow == true then
            local Toggled = Library.Toggled
            Fading = true

            local FadeGroup = New("CanvasGroup", {
                BackgroundTransparency = 1,
                GroupTransparency = Toggled and 1 or 0,
                Name = "MainFade",
                Size = UDim2.fromScale(1, 1),
                ZIndex = MainFrame.ZIndex,
                Parent = ScreenGui,
            })

            MainFrame.Visible = true
            MainFrame.Parent = FadeGroup

            task.spawn(function()
                RunService.Heartbeat:Wait()
                RunService.Heartbeat:Wait()

                TweenService:Create(FadeGroup, Library.WindowAnimationInfo, { GroupTransparency = Toggled and 0 or 1 }):Play()
                task.wait(Library.WindowAnimationInfo.Time)

                Fading = false
                if Library.Unloaded then
                    return
                end

                MainFrame.Visible = Library.Toggled
                MainFrame.Parent = ScreenGui
                FadeGroup:Destroy()
            end)
        else
            MainFrame.Visible = Library.Toggled
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Library.Toggled and not Library.IsMobile then
            local ShowCursorBinding = Library.ShowCursorBinding
            Library.OriginalMouseIconEnabled = UserInputService.MouseIconEnabled

            pcall(function() RunService:UnbindFromRenderStep(ShowCursorBinding) end)
            RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                Cursor.Visible = Library.ShowCustomCursor

                if Library.Unloaded == true or not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                    RestoreMouseIcon()
                end
            end)
        elseif not Library.Toggled then
            RestoreMouseIcon()
            TooltipLabel.Visible = false

            CloseMenus()
        end
    end

    function Library:Toggle(Value: boolean?)
        return Window:Toggle(Value)
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end

    Window:SetAlwaysOnTop(WindowInfo.AlwaysOnTop)
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow and not Library.ActiveLoading then
        task.spawn(Library.Toggle)
    end

    if Library.IsMobile then
        local ToggleButton = Library:AddDraggableButton("Toggle", function()
            Library:Toggle()
        end, true)

        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
            ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
            LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
        else
            ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
            ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

            LockButton.Button.AnchorPoint = Vector2.new(0, 0)
            LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
        end

        if WindowInfo.ShowMobileButtons == false then
            ToggleButton.Button.Visible = false
            LockButton.Button.Visible = false
        end
    end

    --// Execution \\--
    Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end))

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            -- Releasing focus from a text input takes priority and never toggles the window --
            local FocusedBox = UserInputService:GetFocusedTextBox()
            if FocusedBox then
                FocusedBox:ReleaseFocus()
                return
            end

            -- Dismiss the topmost dialog before closing any open menu --
            if Library.ActiveDialog and Library.ActiveDialog.OutsideClickDismiss ~= false then
                Library.ActiveDialog:Dismiss()
                return
            end

            if CurrentMenu then
                CurrentMenu:Close()
                return
            end

            return
        end

        if UserInputService:GetFocusedTextBox() then
            return
        end

        if Input.KeyCode == Library.ToggleKeybind then
            Library:Toggle()
        end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
    end))

    Window.MainFrame = MainFrame
    Library.Window = Window

    --// YX 美化：窗口与标签页就绪后统一启动（内部保证只启动一次）
    if YXStart then pcall(YXStart) end

    return Window
end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        AlwaysOnTop = LoadingInfo.AlwaysOnTop,

        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        task.defer(function()
            if Instance.Parent and Instance:IsDescendantOf(ScreenGui) then
                return
            end

            Library:RemoveFromRegistry(Instance)
        end)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))

    local MainScale = New("UIScale", {
        Scale = Library.IsMobile and 0.8 or 1,
        Parent = MainFrame
    })
    table.insert(Library.Scales, MainScale)
    Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)

    Library:AddOutline(SideBar)

    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        Library:CreateIcon(Library:GetCustomIcon(LoadingInfo.Icon), {
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
    else
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local LoadingIconWidth = LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0
    local LoadingMaxWidth = math.max(0, (TitleHolder.AbsoluteSize.X / Library.DPIScale) - LoadingIconWidth - 12)
    local LoadingTitleWidth = math.min(
        Library:GetTextBounds(LoadingInfo.Title, Library.Scheme.Font, 20),
        LoadingMaxWidth
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, LoadingTitleWidth, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoadingIcon = Library:CreateIcon(Library:GetCustomIcon(LoadingInfo.LoadingIcon), {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = GetTextStrokeColor,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},

        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,

        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight

        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight =
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        local Replacement = Library:ApplyIcon(LoadingIcon, IconData)
        if Replacement ~= LoadingIcon then
            LoadingIcon = Replacement
            Loading:SetLoadingIconTweenTime(LoadingInfo.LoadingIconTweenTime)
        end
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        LoadingInfo.LoadingIconTweenTime = TweenTime

        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        SetIconProperties(LoadingIcon, { ImageColor3 = Color })
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then
                button:Destroy()
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })

            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"

            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = TextBtn
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })

            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    Library.Unloaded = true

    --// Disconnect connections
    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)

        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    --// Run Unload Callbacks
    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)

        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    --// Destroy elements
    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)

        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)

        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if Library.KeybindMenu then
        Library.KeybindMenu:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    --// Clear tables
    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.ContextMenus)

    table.clear(Library.Notifications)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(ActiveTabTweens)

    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.Floats = nil
    Library.Overlay = nil
    Library.WindowContainer = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil
    Library.KeybindMenu = nil

    getgenv().Library = nil
end

getgenv().Library = Library
return Library
