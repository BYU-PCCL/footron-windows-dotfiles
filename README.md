# Footron Windows Setup

Base system is Windows Enterprise.

- Install Windows Enterprise
- Install Python from python.org (I think that's a better way to do it than using the Microsoft store based on past experience, but this might not be true)
  - Enable "Add Python 3.x to PATH"
  - Use custom install and enable "Install for all users"
  - On "Setup was successful" page, click "Disable PATH limit" (this just seems like a good idea)
- Install [Git Bash](https://git-scm.com/download/win)
  - The defaults should be fine
- Clone this repository into `remote`'s root. Most of the operations after this will make most sense if executed in the root of the cloned repository.
- Enable script execution by `remote` in PowerShell:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- Set up OpenSSH server by running `.\setup-openssh.ps1` in an administrator PowerShell
- Create a new user `ft` and set its password using `cmd` (The password doesn't matter but it shouldn't be an existing password because we'll have to put it in plaintext in the registry. We should agree on a password though.):
  ```
  net user /add ft
  net user ft *
  ```
- Log into `ft` and change some settings:
  - Disable screen timeout (System -> Power & sleep)
  - Set background to pure black (#000000) (Personalization -> Background)
  - Set default Windows mode and app mode to Dark (Personalization -> Colors)
- Enable autologin for `ft` by running `.\setup-autologin.ps1 <password>` in an administrator PowerShell
- Set up custom shell for `ft` by running `.\setup-custom-shell.ps1` in an administrator PowerShell
- SSH into `ft`'s account and install `footron-windows` by cloning the repository and installing with `pip install --upgrade .`
  - Edit BASE_EXPERIENCE_PATH in app.py to wherever you end up putting experiences (we should be doing this dynamically with an environmental variable, but we haven't really experimented with setting environmental variables for a custom Windows shell launcher)
- Create the path you specified in BASE_EXPERIENCE_PATH and fill it with experiences. We should document the structure required here better, but it will probably be easiest to just do a Windows network copy from an existing working copy if one exists.
- Setup and pair controllers
- In Settings -> Power & sleep, set both "Screen" and "Sleep" timeouts to "never" (side note: this is unbelievably important and the solution to an issue we spent months debugging)
- Enable VSync:
  - Open NVIDIA Control Panel (right click on desktop)
  - Manage 3D settings -> Vertical sync -> Set it to "On"
- Try manually running every experience executable and installing prerequisites as prompted
- This should hopefully work after a restart. But it probably won't. So you'll likely have to debug things.
- Once the `ft` user has logged in automatically, launch every experience and set them to fullscreen using in-game menus where applicable
- (This should be updated to be better) Once you've setup capture, set the display resolution to 2736x1216, then go to advanced adapter settings and click "show all modes" and change to the 59hz variant of the resolution


## TODO

- We could move some of this PowerShell stuff into either a script or a series of scripts that we just run all at once. Might be good to see if this actually works.
  - Would further be curious how hard it would be to automate installation of things like Git Bash and Python. But this isn't strictly necessary.
