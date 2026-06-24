## CONTRIBUTING WITH GIT

If you wish to contribute patches to the game you will need to use git.

1. Create a fork of the TranscendenceDev repo
2. Clone your fork to your harddrive

If you are downloading the repos in order to submit future pull requests, it is 
worthwhile to keep repositories synced with kronosaur:

[How to sync a fork on github](https://help.github.com/articles/syncing-a-fork/)

General help on using git is available through official sources:

[Github](https://help.github.com)

Once you have made a patch you can make a pull request against the official
repo.

# BUILDING FROM SOURCE

You may build your own copies of the game from source. These versions will not
have the code to access the Kronosaur Multiverse however, but you can still
use one of the Kronosaur-provided binaries to access the multiverse.

## PREREQUISITES

- **Visual Studio 2022** (Community or higher) with the **Desktop development with C++** workload
- **February 2010 DirectX SDK** — later versions omit libraries required by the engine

Run the setup script to verify (and optionally install) prerequisites:

    setup.bat

Or directly in PowerShell:

    .\setup.ps1

## DEVELOPMENT ENVIRONMENT SETUP

Install the February 2010 DirectX SDK. The correct version can be downloaded here:

[Archive.org - 2010 DirectX SDK](https://archive.org/details/dxsdk_feb10)

Install it to the default path when prompted:
`C:\Program Files (x86)\Microsoft DirectX SDK (February 2010)\`

> **Note:** If the installer exits with error **S1023**, a newer Visual C++ Redistributable
> is blocking the install. See [KB2728613](http://support.microsoft.com/kb/2728613) for the fix.

## BUILDING FROM THE COMMAND LINE

Once prerequisites are installed, build from the repo root:

**PowerShell:**

    .\build.ps1               # Debug For Contributors (recommended)
    .\build.ps1 -Release      # Release build

**Command Prompt:**

    build.bat                 # Debug For Contributors (recommended)
    build.bat release         # Release build

Output is placed in `Transcendence\Game\Transcendence.exe`.

## BUILDING WITH VISUAL STUDIO

Install Visual Studio 2022 (Community or higher). Open `File > Open > Project/Solution`
and select `<Repo Root>/Transcendence/Transcendence.sln`.

The following warnings, if shown under `Output` from Solution, may be safely ignored:

    <Repo Root>\Alchemy\zlib-1.2.7\contrib\vstudio\vc10\zlibstat.vcxproj : 
    warning  : Platform 'Itanium' referenced in the project file 'zlibstat' 
    cannot be found.

    <Repo Root>\TransCore\TransCore.vcxproj : error  : Project 
    "...\TransCore\TransCore.vcxproj" could not be found.

Go to `View > Solution Explorer`. Right-click `Transcendence` and select
`Set as Startup Project`. `Transcendence` should now be bold in the Solution Explorer.

In the configuration dropdown (second toolbar), select **`Debug For Contributors`**
and set the platform dropdown to **`Win32`**.

> **Why "Debug For Contributors"?** The `Debug For Contributors` configuration builds with
> `CHexarcServiceStub.cpp` instead of `CHexarcService.cpp`, which requires private Kronosaur
> cloud service files not included in this repo. Always use `Debug For Contributors` (or
> `Preview For Contributors`) when building from this public repo.

Ensure the DirectX SDK include and library paths are set correctly. Right-click
`Transcendence` (under the Transcendence solution) and select `Properties`:

    Configuration Properties > VC++ Directories > General > Include Directories
    Configuration Properties > VC++ Directories > General > Library Directories
    
Always point the Library Directories to the `\Lib\x86` folder of the SDK.

Build the solution. Executables are placed in `Transcendence/Game/`.

The game can optionally be launched from Visual Studio using the `Local Windows Debugger`
button in the toolbar.

## Recommended Editor Configuration

To enable whitesmith indentation style in Visual Studio, open `Tools > Options`:

Then select `Text Editor > C/C++ > Tabs` and ensure that:

    Tab size = 4
    Indent size = 4
    Keep Tabs = True

Then select `Text Editor > C/C++ > Code Style > Formatting > Indentation` and
ensure that:

    Indent braces = True
    Indent each line relatively to = `Innermost paranthesis`
    Within parenthesis, align new lines when I type them = `Indent new lines`
    Indent case contents = True
    Indent braces following a case statement = True
    Indent braces of lambdas = True
    
Then select `Text Editor > C/C++ > Code Style > Formatting > Spacing` and ensure
that:

    `Spacing for operators > Pointer/reference Alignment > Leave unchanged` = True

If you find additional settings that should be changed to provide for an easier
editing experience, please update this readme with them.

# DEVELOPMENT ENVIRONMENT FOR GAME DATA ONLY

It is possible to use a precompiled version of Transcendence to develop game
data patches without needing a full development environment. This is useful if
your computer is unable to run Visual Studio but you still want to contribute
patches to the game's XML.

Be aware that:
* This is a more limited solution but allows people to contribute patches to
    the gamedata without needing a setup able to compile the game from source
* It only works if the branch you are patching is on the same API version as
    the current public builds of Transcendence

## GAME DATA DEV ENVIRONMENT SETUP

1. Download https://downloads.kronosaur.com/TranscendenceNext.zip
(this link has the latest alpha or beta version)
2. Extract TranscendenceNext.zip
3. Copy Transcendence.exe to `TranscendenceDev/Transcendence/Game`
4. You can now run the game and it will use the XML in `TranscendenceDev/Transcendence/TransCore`

Optionally you can configure the game to search an existing install of Transcendence's
Collection and Extension folders. To do this:

1. Create a folder `Collection` in `TranscendenceDev/Transcendence/Game`
2. Create a folder `Extensions` in `TranscendenceDev/Transcendence/Game`
3. Create a symlink inside `TranscendenceDev/Transcendence/Game/Collection` to
the `Collection` folder of the existing Transcendence installation
    * `mklink /D "{location of repo}/TranscendenceDev/Transcendence/Game/Collection/ExternalCollection" "{location of external transcendence}/Transcendence/Collection"`
        * Replace the text in `{}` with appropriate file paths.
        * An admin cmd prompt should not be necessary unless the folder permissions require it.
4. Create a symlink inside `TranscendenceDev/Transcendence/Game/Extensions` to
the `Extensions` folder of the existing Transcendence installation
    * `mklink /D "{location of repo}/TranscendenceDev/Transcendence/Game/Extensions/ExternalExtensions" "{location of external transcendence}/Transcendence/Extensions"`

Notes:
* For windows a basic `.lnk` shortcut is not yet supported.
* This has not been tested on Linux but it should still work
* If the game says that the API version of the Transcendence Universe is too high you need
    to download a new copy of TranscendenceNext.zip and follow the setup instructions again
    to update it.
