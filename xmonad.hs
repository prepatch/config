------------------------------------------------------------------------
-- IMPORTS
------------------------------------------------------------------------

import XMonad
import XMonad.ManageHook
import Data.Monoid
import Data.Tree
import System.Exit
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Layout.NoBorders (noBorders, smartBorders)

import XMonad.Actions.CycleWS (nextWS, prevWS, shiftToNext, shiftToPrev)
import XMonad.Actions.Submap
import XMonad.Actions.TreeSelect as TS

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WorkspaceHistory

import XMonad.Util.EZConfig (mkKeymap)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

------------------------------------------------------------------------
-- VARIABLES
------------------------------------------------------------------------
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal :: String
myTerminal = "xfce4-terminal"

myBrowser :: String
myBrowser = "firefox"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth :: Dimension
myBorderWidth = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask :: KeyMask
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor :: String
myNormalBorderColor = "#282a36"

myFocusedBorderColor :: String
myFocusedBorderColor = "#bd93f9"

------------------------------------------------------------------------
-- KEY BINDINGS
------------------------------------------------------------------------

myKeys = \conf -> mkKeymap conf $

    -- launch a terminal
    [ ("M-<Return>", spawn $ XMonad.terminal conf)

    -- launch rofi
    , ("M-r", spawn "rofi -show run")

    -- change windows
    , ("M-w", spawn "rofi -show window")

    -- launch a browser
    , ("M-b", spawn myBrowser)

    -- close focused window
    , ("M-c", kill)

     -- Rotate through the available layout algorithms
    , ("M-<Space>", sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ("M-S-<Space>", setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ("M-n", refresh)

    -- Move focus to the next window
    , ("M-j", windows W.focusDown)

    -- Move focus to the previous window
    , ("M-k", windows W.focusUp  )

    -- Move focus to the master window
    , ("M-m", windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ("M-S-<Return>", windows W.swapMaster)

    -- Swap the focused window with the next window
    , ("M-S-j", windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ("M-S-k", windows W.swapUp    )

    -- Shrink the master area
    , ("M-h", sendMessage Shrink)

    -- Expand the master area
    , ("M-l", sendMessage Expand)

    -- Push window back into tiling
    , ("M-t", withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ("M-.", sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ("M-,", sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    -- , ("M-f", sendMessage ToggleStruts)

    -- Quit xmonad
    , ("M-S-q", io (exitWith ExitSuccess))

    -- Restart xmonad
    , ("M-S-r", spawn "xmonad --recompile; xmonad --restart")

    -- Lock Screen
    , ("M-S-l", spawn "betterlockscreen -l blur")

    -- Workspace navigation
    , ("M-C-l", nextWS)
    , ("M-C-h", prevWS)
    , ("M-M1-l", shiftToNext)
    , ("M-M1-h", shiftToPrev)

    -- Scratchpads
    , ("M-C-<Return>", namedScratchpadAction myScratchpads "terminal")
    , ("M-C-m", namedScratchpadAction myScratchpads "music")
    , ("M-C-v", namedScratchpadAction myScratchpads "vlc")

    -- Cmus controls
    , ("M-u p", spawn "cmus-remote -p")
    , ("M-u u", spawn "cmus-remote -u")
    , ("M-u n", spawn "cmus-remote -n")
    , ("M-u r", spawn "cmus-remote -r")

    -- Treeselect
    ,("M-S-t", tsAction tsConfig)

    -- Show time and date
    ,("M-x d", spawn "notify-send \"$(date +\"%+4Y/%m/%d %a %H:%M\")\"")

    -- Show battery information
    ,("M-x b", spawn "notify-send \"$(acpi)\"")
    -- Pulse Audio controls
    ,("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume 0 +5%")
    ,("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume 0 -5%")
    ,("<XF86AudioMute>", spawn "pactl set-sink-mute 0 toggle")
    ]

------------------------------------------------------------------------
-- MOUSE BINDINGS
------------------------------------------------------------------------

myMouseBindings conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- LAYOUTS
------------------------------------------------------------------------

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = smartBorders tiled ||| Mirror tiled ||| noBorders Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- WINDOW RULES
------------------------------------------------------------------------

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"                --> doFloat
    , className =? "Gimp"                   --> doFloat
    , resource  =? "desktop_window"         --> doIgnore
    , resource  =? "desktop"                --> doIgnore
    , className =? "VirtualBox Manager"     --> doFloat
    , className =? "Anki"                   --> doFloat
    ]<+> namedScratchpadManageHook myScratchpads

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
    spawnOnce "~/.fehbg &"
    spawnOnce "picom &"
    spawnOnce "nm-applet &"
    spawnOnce "xfce4-power-manager"
    spawnOnce "/home/hb/.config/xkbrc"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--

main = do
    xmonad $ ewmh defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

------------------------------------------------------------------------
-- SCRATCHPADS
------------------------------------------------------------------------

myScratchpads :: [NamedScratchpad]
myScratchpads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "music" spawnMusicPlayer findMusicPlayer manageMusicPlayer
                ]
    where
      spawnTerm  = myTerminal ++ " -T scratchpadTerminal"
      findTerm   = title =? "scratchpadTerminal"
      manageTerm = customFloating $ W.RationalRect l t w h
                 where
                   h = 0.9
                   w = 0.9
                   t = 0.95 -h
                   l = 0.95 -w
      spawnMusicPlayer  = myTerminal ++ " -T scratchpadMusic -e cmus"
      findMusicPlayer   = title =? "scratchpadMusic"
      manageMusicPlayer = customFloating $ W.RationalRect l t w h
                        where
                          h = 0.9
                          w = 0.9
                          t = 0.95 -h
                          l = 0.95 -w

------------------------------------------------------------------------
-- TREESELECT
------------------------------------------------------------------------

tsAction :: TS.TSConfig (X ()) -> X ()
tsAction a = TS.treeselectAction a
   [ Node (TS.TSNode "System" "" (return()))
       [ Node (TS.TSNode "Suspend" "" (spawn "betterlockscreen -s blur")) []
       , Node (TS.TSNode "Lock Screen" "" (spawn "betterlockscreen -l blur")) []
       ]
   , Node (TS.TSNode "Night Light" "" (spawn "redshift")) [] 
   ]

tsConfig :: TS.TSConfig a
tsConfig = TS.TSConfig { TS.ts_hidechildren = True
                              , TS.ts_background   = 0xc0282a36
                              , TS.ts_font         = "xft:mononoki-12"
                              , TS.ts_node         = (0xfff8f8f2, 0xff282a36)
                              , TS.ts_nodealt      = (0xfff8f8f2, 0xff282a36)
                              , TS.ts_highlight    = (0xfff1fa8c, 0xff44475a)
                              , TS.ts_extra        = 0xffbd93f9
                              , TS.ts_node_width   = 200
                              , TS.ts_node_height  = 30
                              , TS.ts_originX      = 0
                              , TS.ts_originY      = 0
                              , TS.ts_indent       = 80
                              , TS.ts_navigate     = myTreeNavigation
                              }

myTreeNavigation = M.fromList
    [ ((0, xK_Escape), TS.cancel)
    , ((0, xK_Return), TS.select)
    , ((0, xK_space),  TS.select)
    , ((0, xK_Up),     TS.movePrev)
    , ((0, xK_Down),   TS.moveNext)
    , ((0, xK_Left),   TS.moveParent)
    , ((0, xK_Right),  TS.moveChild)
    , ((0, xK_k),      TS.movePrev)
    , ((0, xK_j),      TS.moveNext)
    , ((0, xK_h),      TS.moveParent)
    , ((0, xK_l),      TS.moveChild)
    , ((0, xK_o),      TS.moveHistBack)
    , ((0, xK_i),      TS.moveHistForward)
    ]
