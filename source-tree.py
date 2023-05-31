import os
import subprocess

# Set the installation path and URL for SourceTree
sourcetree_path = "C:\\Program Files (x86)\\Atlassian\\SourceTree\\SourceTree.exe"
sourcetree_url = "https://product-downloads.atlassian.com/software/sourcetree/windows/ga/SourceTreeSetup-3.3.9.exe"

# Set the registry keys for SourceTree and Bitbucket Server
# registry_key_path = "HKCU:\\Software\\Atlassian\\SourceTree"
# subprocess.run(["reg", "add", registry_key_path, "/v", "UserEmail", "/t", "REG_SZ", "/d", "sudarshan.damahe@rampgroup.com", "/f"], check=True)
# subprocess.run(["reg", "add", registry_key_path, "/v", "UserName", "/t", "REG_SZ", "/d", "Sudarshan Damahe", "/f"], check=True)
# subprocess.run(["reg", "add", registry_key_path, "/v", "UseSystemGit", "/t", "REG_DWORD", "/d", "0", "/f"], check=True)
# subprocess.run(["reg", "add", registry_key_path + "\\Git", "/v", "UseCredentialManager", "/t", "REG_DWORD", "/d", "1", "/f"], check=True)
# subprocess.run(["reg", "add", registry_key_path + "\\Profiles\\Bitbucket", "/v", "BaseUrl", "/t", "REG_SZ", "/d", "https://bitbucket.rampgroup.com", "/f"], check=True)
# subprocess.run(["reg", "add", registry_key_path + "\\Accounts\\Bitbucket", "/v", "Username", "/t", "REG_SZ", "/d", "sudarshan.damahe@rampgroup.com", "/f"], check=True)
# subprocess.run(["reg", "add", registry_key_path + "\\Accounts\\Bitbucket", "/v", "Password", "/t", "REG_SZ", "/d", "Sumo@1999", "/f"], check=True)

# Download and install SourceTree
subprocess.run(["powershell.exe", "Invoke-WebRequest", sourcetree_url, "-OutFile", "sourcetree-installer.exe"], check=True)
subprocess.run(["sourcetree-installer.exe", "/VERYSILENT", "/SUPPRESSMSGBOXES"], check=True)

# Launch SourceTree
os.startfile(sourcetree_path)

# import subprocess

# # Replace with the path to the downloaded SourceTree installer
# installer_path = "C:\Temp\SourceTreeSetup-3.4.12.exe"

# # Run the installer with the desired command-line arguments
# subprocess.run([installer_path, "/SILENT", "/COMPONENTS=SourceTree,Mercurial,Git,WindowsExplorerIntegration", "/DIR=C:\\Program Files\\SourceTree"])

